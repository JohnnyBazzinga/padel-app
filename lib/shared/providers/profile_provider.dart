import 'package:flutter/material.dart';

import '../models/social_post.dart';
import '../models/user_model.dart';
import '../../core/api/api_client.dart';

class ProfileProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  final Map<String, User> _profiles = {};
  final Set<String> _loadingIds = {};
  final Map<String, String> _errors = {};

  User? getProfile(String userId) {
    final id = _normalizeId(userId);
    if (id == null) return null;
    return _profiles[id];
  }

  bool isLoading(String userId) {
    final id = _normalizeId(userId);
    if (id == null) return false;
    return _loadingIds.contains(id);
  }

  String? error(String userId) {
    final id = _normalizeId(userId);
    if (id == null) return null;
    return _errors[id];
  }

  Future<User?> loadProfile({
    required String userId,
    PostAuthor? fallbackAuthor,
    bool force = false,
  }) async {
    final id = _normalizeId(userId);
    if (id == null) return null;

    if (_loadingIds.contains(id)) return _profiles[id];
    if (!force && _profiles[id] != null) return _profiles[id];
    if (_profiles[id] == null && fallbackAuthor != null) {
      _profiles[id] = _userFromAuthor(fallbackAuthor, id);
    }

    _loadingIds.add(id);
    _errors.remove(id);
    notifyListeners();

    User? loadedUser;
    final fallbackProfile = _profiles[id];
    try {
      final response = await _api.get('/users/$id');
      loadedUser = _extractUserFromPayload(_unwrapPayload(response.data));
      if (loadedUser == null) throw Exception('Payload inválido');
      _profiles[id] = _forceProfileId(loadedUser, id);
    } catch (e) {
      try {
        final response = await _api.get('/users/public/$id');
        loadedUser = _extractUserFromPayload(_unwrapPayload(response.data));
        if (loadedUser != null) {
          _profiles[id] = _forceProfileId(loadedUser, id);
        }
      } catch (secondaryError) {
        if (fallbackProfile == null && fallbackAuthor != null) {
          _profiles[id] = _userFromAuthor(fallbackAuthor, id);
        } else if (fallbackProfile == null) {
          _profiles[id] = _emptyUser(id);
        }
        _errors[id] = 'Não foi possível carregar perfil completo.';
      }
    }

    if (_errors[id] == null && _profiles[id] == null && fallbackProfile != null) {
      _profiles[id] = fallbackProfile;
    }

    _loadingIds.remove(id);
    notifyListeners();
    return _profiles[id];
  }

  User _emptyUser(String id) {
    return User(
      id: id,
      email: '',
      firstName: 'Utilizador',
      skillLevel: 'BEGINNER',
      avatarUrl: null,
      city: null,
      reputationScore: 0,
      reputationSignals: 0,
      matchesPlayed: 0,
      matchesWon: 0,
      totalPoints: 0,
      availabilityStatus: null,
      roles: const [],
    );
  }

  User _userFromAuthor(PostAuthor author, String fallbackId) {
    final name = author.name?.trim() ?? '';
    final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();

    return User(
      id: author.id.isNotEmpty ? author.id : fallbackId,
      email: '',
      firstName: parts.isNotEmpty ? parts.first : null,
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : null,
      avatarUrl: author.avatarUrl,
      city: author.city,
      skillLevel: author.skillLevel ?? 'BEGINNER',
      reputationScore: author.reputation ?? 0,
      reputationSignals: 0,
      roles: const [],
      availabilityStatus: author.availabilityStatus,
      matchesPlayed: 0,
      matchesWon: 0,
      totalPoints: 0,
    );
  }

  User _forceProfileId(User user, String forcedId) {
    if (user.id == forcedId) return user;
    return User(
      id: forcedId,
      email: user.email,
      firstName: user.firstName,
      lastName: user.lastName,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      bio: user.bio,
      city: user.city,
      country: user.country,
      skillLevel: user.skillLevel,
      preferredHand: user.preferredHand,
      preferredSide: user.preferredSide,
      yearsPlaying: user.yearsPlaying,
      matchesPlayed: user.matchesPlayed,
      matchesWon: user.matchesWon,
      reputationScore: user.reputationScore,
      reputationSignals: user.reputationSignals,
      reputationLabel: user.reputationLabel,
      totalPoints: user.totalPoints,
      availabilityStatus: user.availabilityStatus,
      roles: user.roles,
    );
  }

  User? _extractUserFromPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final candidate = payload['user'];
      if (candidate is Map<String, dynamic>) {
        return User.fromJson(candidate);
      }
      if (_looksLikeUser(payload)) {
        return User.fromJson(payload);
      }
      return User.fromJson(payload);
    }
    return null;
  }

  bool _looksLikeUser(Map<String, dynamic> value) {
    const keys = <String>{'email', 'firstName', 'lastName', 'id', 'name', 'avatarUrl'};
    return value.keys.any((key) => keys.contains(key));
  }

  String? _normalizeId(String userId) {
    final id = userId.trim();
    return id.isEmpty ? null : id;
  }

  dynamic _unwrapPayload(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested != null) return nested;
    }
    return data;
  }
}
