import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';
import '../models/social_post.dart';

class SocialFeedProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Post> _posts = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _page = 1;
  bool _hasMore = true;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  Future<void> fetchFeed({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _hasMore = true;
      _posts = [];
    }

    if (_isLoading || _isLoadingMore || (!_hasMore && !refresh)) return;

    _isLoading = refresh;
    if (!refresh) _isLoadingMore = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/posts/feed', queryParameters: {
        'page': _page,
        'limit': 12,
      });
      final responseData = _unwrapPayload(response.data);
      final list = _extractPosts(responseData);
      final hasMore = _extractHasMore(responseData);

      if (refresh) {
        _posts = list;
      } else {
        _posts.addAll(list);
      }
      _page += 1;
      _hasMore = hasMore;
    } catch (e) {
      _error = 'Erro ao carregar feed social';
      if (_posts.isEmpty) {
        _hasMore = false;
      }
    }

    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<Post?> createPost({
    required String content,
    List<String>? mediaUrls,
  }) async {
    final urls = <String>[];
    if (mediaUrls != null) {
      for (final url in mediaUrls) {
        final safe = url.trim();
        if (safe.isNotEmpty) {
          urls.add(safe);
        }
      }
    }

    if (urls.length > 3) urls.length = 3;
    if (content.trim().isEmpty && urls.isEmpty) return null;

    try {
      final response = await _api.post('/posts', data: {
        'content': content.trim(),
        if (urls.isNotEmpty) 'mediaUrls': urls,
      });
      final created = _extractSinglePost(_unwrapPayload(response.data));
      if (created != null) {
        _posts.insert(0, created);
        notifyListeners();
        return created;
      }
    } catch (e) {
      _error = 'Erro ao publicar post';
      notifyListeners();
    }

    return null;
  }

  Future<bool> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index < 0) return false;

    final current = _posts[index];
    final nextLiked = !current.isLikedByMe;
    final nextLikesCount = nextLiked
        ? current.likesCount + 1
        : (current.likesCount > 0 ? current.likesCount - 1 : 0);

    _posts[index] = current.copyWith(
      isLikedByMe: nextLiked,
      likesCount: nextLikesCount,
    );
    notifyListeners();

    try {
      final response = await _api.post('/posts/$postId/like');
      final responseData = response.data['data'];
      if (responseData is Map<String, dynamic>) {
        final isLiked = _toBool(responseData['isLiked']) ?? nextLiked;
        final likes = _toInt(responseData['likesCount']);
        _posts[index] = _posts[index].copyWith(
          isLikedByMe: isLiked,
          likesCount: likes ?? nextLikesCount,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _posts[index] = current;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addComment(String postId, String text) async {
    if (text.trim().isEmpty) return false;

    final index = _posts.indexWhere((p) => p.id == postId);
    if (index < 0) return false;

    try {
      final response = await _api.post('/posts/$postId/comment', data: {
        'text': text.trim(),
      });
      final responseData = _unwrapPayload(response.data);

      if (responseData is Map<String, dynamic>) {
        final comment = PostComment.fromJson(
          responseData['comment'] is Map<String, dynamic>
              ? responseData['comment']
              : responseData,
        );
        final existing = _posts[index];
        final updatedComments = [...existing.latestComments, comment];
        final commentsCount = updatedComments.length;
        _posts[index] = existing.copyWith(
          latestComments: updatedComments,
          commentsCount: responseData['commentsCount'] is int
              ? responseData['commentsCount']
              : commentsCount,
        );
      } else {
        _posts[index] = _posts[index].copyWith(
          commentsCount: _posts[index].commentsCount + 1,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao comentar';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleFollow(String targetUserId) async {
    final authorId = targetUserId.trim();
    if (authorId.isEmpty) return false;

    final affected = <int>[];
    for (var i = 0; i < _posts.length; i++) {
      if (_posts[i].author?.id == authorId) {
        affected.add(i);
      }
    }
    if (affected.isEmpty) return false;

    final currentState = _posts[affected.first].isFollowingAuthor;
    final nextState = !currentState;

    final previousStateByIndex = <int, bool>{};
    for (final index in affected) {
      previousStateByIndex[index] = _posts[index].isFollowingAuthor;
      _posts[index] = _posts[index].copyWith(isFollowingAuthor: nextState);
    }
    notifyListeners();

    try {
      final primaryPath = nextState ? '/users/$authorId/follow' : '/users/$authorId/unfollow';
      final payload = await _api.post(primaryPath);
      final payloadData = _unwrapPayload(payload.data);
      final serverValue = _extractFollowState(payloadData);
      if (serverValue != null) {
        for (final index in affected) {
          _posts[index] = _posts[index].copyWith(isFollowingAuthor: serverValue);
        }
      }
      notifyListeners();
      return true;
    } catch (primaryError) {
      try {
        final fallback = '/users/$authorId/follow-toggle';
        final payload = await _api.post(fallback);
        final payloadData = _unwrapPayload(payload.data);
        final serverValue = _extractFollowState(payloadData);
        if (serverValue != null) {
          for (final index in affected) {
            _posts[index] = _posts[index].copyWith(isFollowingAuthor: serverValue);
          }
        } else {
          for (final index in affected) {
            _posts[index] = _posts[index].copyWith(isFollowingAuthor: !nextState ? currentState : nextState);
          }
        }
        notifyListeners();
        return true;
      } catch (secondaryError) {
        for (final index in affected) {
          _posts[index] = _posts[index].copyWith(
            isFollowingAuthor: previousStateByIndex[index] ?? currentState,
          );
        }
        _error = 'Erro ao atualizar seguimento.';
        notifyListeners();
        return false;
      }
    }
  }

  List<Post> _extractPosts(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
    }

    if (data is Map<String, dynamic> && data['data'] is List) {
      final list = data['data'];
      return list.whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
    }

    return [];
  }

  Post? _extractSinglePost(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) return Post.fromJson(nested);
      return Post.fromJson(data);
    }
    return null;
  }

  bool _extractHasMore(dynamic data) {
    if (data is Map<String, dynamic> && data['totalPages'] is int) {
      final page = data['page'];
      final totalPages = data['totalPages'];
      if (page is int && totalPages is int) {
        return page < totalPages;
      }
    }
    if (data is Map<String, dynamic> &&
        data['page'] is String &&
        data['totalPages'] is String) {
      final page = int.tryParse(data['page']);
      final totalPages = int.tryParse(data['totalPages']);
      if (page != null && totalPages != null) {
        return page < totalPages;
      }
    }

    if (data is Map<String, dynamic> && data['hasMore'] is bool) {
      return data['hasMore'];
    }
    return true;
  }

  dynamic _unwrapPayload(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic> && data['data'] != null) {
      return data['data'];
    }
    return data;
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }

  bool? _extractFollowState(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final candidate = payload['isFollowingAuthor'] ??
          payload['isFollowing'] ??
          payload['following'] ??
          payload['follows'];
      if (candidate != null) {
        if (candidate is bool) return candidate;
        if (candidate is num) return candidate != 0;
        if (candidate is String) {
          final lower = candidate.toLowerCase();
          if (lower == 'true' || lower == '1' || lower == 'yes') return true;
          if (lower == 'false' || lower == '0' || lower == 'no') return false;
        }
      }
    }

    return null;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
