import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class Friend {
  final String id;
  final Map<String, dynamic> friend;
  final DateTime since;

  Friend({
    required this.id,
    required this.friend,
    required this.since,
  });

  String get friendId => friend['id'];
  String get name => '${friend['firstName'] ?? ''} ${friend['lastName'] ?? ''}'.trim();
  String? get avatarUrl => friend['avatarUrl'];
  String get city => friend['city'] ?? '';
  String get skillLevel => friend['skillLevel'] ?? 'BEGINNER';

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      id: json['id'],
      friend: json['friend'],
      since: DateTime.parse(json['since']),
    );
  }
}

class FriendRequest {
  final String id;
  final Map<String, dynamic> initiator;
  final DateTime createdAt;

  FriendRequest({
    required this.id,
    required this.initiator,
    required this.createdAt,
  });

  String get name => '${initiator['firstName'] ?? ''} ${initiator['lastName'] ?? ''}'.trim();
  String? get avatarUrl => initiator['avatarUrl'];
  String get userId => initiator['id'];

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      id: json['id'],
      initiator: json['initiator'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class FriendsProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Friend> _friends = [];
  List<FriendRequest> _pendingRequests = [];
  bool _isLoading = false;
  String? _error;

  List<Friend> get friends => _friends;
  List<FriendRequest> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get pendingCount => _pendingRequests.length;

  Future<void> fetchFriends() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/friends');
      _friends = (response.data['data'] as List)
          .map((f) => Friend.fromJson(f))
          .toList();
    } catch (e) {
      _error = 'Erro ao carregar amigos';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchPendingRequests() async {
    try {
      final response = await _api.get('/friends/requests/pending');
      _pendingRequests = (response.data['data'] as List)
          .map((r) => FriendRequest.fromJson(r))
          .toList();
      notifyListeners();
    } catch (e) {
      // Ignore
    }
  }

  Future<bool> sendRequest(String userId) async {
    try {
      await _api.post('/friends/request/$userId');
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> acceptRequest(String friendshipId) async {
    try {
      await _api.post('/friends/accept/$friendshipId');
      _pendingRequests.removeWhere((r) => r.id == friendshipId);
      await fetchFriends();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectRequest(String friendshipId) async {
    try {
      await _api.post('/friends/reject/$friendshipId');
      _pendingRequests.removeWhere((r) => r.id == friendshipId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFriend(String userId) async {
    try {
      await _api.delete('/friends/$userId');
      _friends.removeWhere((f) => f.friendId == userId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
