import 'package:flutter/material.dart';

class PostAuthor {
  final String id;
  final String? name;
  final String? avatarUrl;
  final String? city;
  final String? skillLevel;
  final double? reputation;
  final String? availabilityStatus;

  const PostAuthor({
    required this.id,
    this.name,
    this.avatarUrl,
    this.city,
    this.skillLevel,
    this.reputation,
    this.availabilityStatus,
  });

  factory PostAuthor.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PostAuthor(id: '');
    }

    final firstName = json['firstName'];
    final lastName = json['lastName'];
    final repSource = json['reputation'];
    final fullName = '${firstName ?? ''} ${lastName ?? ''}'.trim();

    return PostAuthor(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? (fullName.isNotEmpty ? fullName : null),
      avatarUrl: json['avatarUrl']?.toString(),
      city: json['city']?.toString(),
      skillLevel: json['skillLevel']?.toString(),
      reputation: _parseReputation(json['reputation']),
      availabilityStatus: _extractAvailabilityStatus(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'city': city,
      'skillLevel': skillLevel,
      'reputation': reputation,
      'availabilityStatus': availabilityStatus,
    };
  }
}

class PostMedia {
  final String id;
  final String? url;
  final String type;

  const PostMedia({
    required this.id,
    this.url,
    this.type = 'image',
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      id: json['id']?.toString() ?? '',
      url: json['url']?.toString(),
      type: json['type']?.toString() ?? 'image',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'url': url, 'type': type};
  }
}

class PostComment {
  final String id;
  final String? postId;
  final String? text;
  final PostAuthor? author;
  final DateTime createdAt;

  const PostComment({
    required this.id,
    this.postId,
    this.text,
    this.author,
    required this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id']?.toString() ?? '',
      postId: json['postId']?.toString(),
      text: json['text']?.toString(),
      author: PostAuthor.fromJson(_extractAuthor(json)),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'text': text,
      'author': author?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Post {
  final String id;
  final String? content;
  final PostAuthor? author;
  final List<PostMedia> media;
  final int likesCount;
  final int commentsCount;
  final bool isLikedByMe;
  final bool isFollowingAuthor;
  final List<PostComment> latestComments;
  final DateTime createdAt;

  const Post({
    required this.id,
    this.content,
    this.author,
    this.media = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLikedByMe = false,
    this.isFollowingAuthor = false,
    this.latestComments = const [],
    required this.createdAt,
  });

  String get authorName => author?.name?.trim().isNotEmpty == true
      ? author!.name!.trim()
      : 'Jogador';

  Post copyWith({
    int? likesCount,
    int? commentsCount,
    bool? isLikedByMe,
    bool? isFollowingAuthor,
    List<PostMedia>? media,
    List<PostComment>? latestComments,
  }) {
    return Post(
      id: id,
      content: content,
      author: author,
      media: media ?? this.media,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isFollowingAuthor: isFollowingAuthor ?? this.isFollowingAuthor,
      latestComments: latestComments ?? this.latestComments,
      createdAt: createdAt,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    final mediaList = <PostMedia>[];
    final mediaSource = json['media'];
    if (mediaSource is List) {
      mediaList.addAll(
        mediaSource
            .whereType<Map<String, dynamic>>()
            .map((media) => PostMedia.fromJson(media))
            .toList(),
      );
    } else if (json['mediaUrl'] != null) {
      mediaList.add(PostMedia(id: 'primary', url: json['mediaUrl']?.toString()));
    }

    final commentList = <PostComment>[];
    if (json['comments'] is List) {
      commentList.addAll(
        (json['comments'] as List)
            .whereType<Map<String, dynamic>>()
            .map((comment) => PostComment.fromJson(comment))
            .toList(),
      );
    }

    return Post(
      id: json['id']?.toString() ?? '',
      content: json['content']?.toString(),
      author: PostAuthor.fromJson(_extractAuthor(json)),
      media: mediaList,
      likesCount: _toInt(json['likesCount']),
      commentsCount: _toInt(json['commentsCount']),
      isLikedByMe: _toBool(json['isLikedByMe'] ?? json['liked']),
      isFollowingAuthor: _toBool(json['isFollowingAuthor'] ?? json['isFollowing']),
      latestComments: commentList,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'author': author?.toJson(),
      'media': media.map((item) => item.toJson()).toList(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isLikedByMe': isLikedByMe,
      'isFollowingAuthor': isFollowingAuthor,
      'comments': latestComments.map((comment) => comment.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

double? _parseDouble(dynamic value) {
  if (value is int) return value.toDouble();
  if (value is double) return value;
  if (value == null) return null;
  return double.tryParse(value.toString());
}

double? _parseReputation(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  if (value is Map<String, dynamic>) {
    return _parseDouble(value['score']) ??
        _parseDouble(value['value']) ??
        _parseDouble(value['rating']);
  }
  return null;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final lowered = value.toLowerCase();
    if (lowered == 'true' || lowered == '1' || lowered == 'yes' || lowered == 'y') {
      return true;
    }
    if (lowered == 'false' || lowered == '0' || lowered == 'no' || lowered == 'n') {
      return false;
    }
  }
  return false;
}

Map<String, dynamic>? _extractAuthor(Map<String, dynamic> json) {
  if (json['author'] is Map<String, dynamic>) return json['author'];
  if (json['user'] is Map<String, dynamic>) return json['user'];
  return null;
}

String? _extractAvailabilityStatus(Map<String, dynamic> json) {
  final status = json['availabilityStatus'] ??
      json['status'] ??
      json['availability'] ??
      json['state'];

  if (status is String) {
    final trimmed = status.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }

  return null;
}
