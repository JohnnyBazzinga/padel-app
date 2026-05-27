import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../../core/access/app_roles.dart';
import '../../core/api/api_client.dart';
import '../../core/services/storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final StorageService _storage = StorageService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  List<String> get roles => _user?.roles ?? const [];
  Set<String> get normalizedRoles => AppRoles.normalizeRoles(roles);

  @Deprecated('Use canAccessAdminArea')
  bool get isPlatformAdmin => AppRoles.canAccessAdminArea(roles);

  bool get canAccessAdminArea => AppRoles.canAccessAdminArea(roles);
  bool get isOrganizer => AppRoles.isOrganizer(roles);
  bool get canCreateTournaments => AppRoles.canCreateTournaments(roles);
  bool get canInviteOrganizer => AppRoles.canInviteOrganizer(roles);
  bool get canCreateMatches => true;

  bool hasRole(String role) {
    return AppRoles.hasRole(roles, role);
  }

  AuthProvider() {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final hasTokens = await _storage.hasTokens();
      if (!hasTokens) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      final response = await _api.get('/users/me');
      _user = User.fromJson(response.data['data']);
      await _storage.saveUser(_user!.toJson());
      _status = AuthStatus.authenticated;
    } catch (e) {
      await _storage.clearTokens();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data['data'];
      await _storage.saveTokens(data['accessToken'], data['refreshToken']);
      _user = User.fromJson(data['user']);
      await _storage.saveUser(_user!.toJson());
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Email ou password incorretos';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? skillLevel,
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post('/auth/register', data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'city': city,
        'skillLevel': skillLevel,
      });

      final data = response.data['data'];
      await _storage.saveTokens(data['accessToken'], data['refreshToken']);
      _user = User.fromJson(data['user']);
      await _storage.saveUser(_user!.toJson());
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao criar conta. Email já registado?';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearTokens();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    try {
      final response = await _api.get('/users/me');
      _user = User.fromJson(response.data['data']);
      await _storage.saveUser(_user!.toJson());
      notifyListeners();
    } catch (e) {
      // Ignore
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final sanitizedData = _cleanProfilePayload(data);
    final attempts = _buildUpdateProfileAttempts(sanitizedData);
    for (final payload in attempts) {
      try {
        final response = await _api.patch('/users/me', data: payload);
        _user = User.fromJson(response.data['data']);
        await _storage.saveUser(_user!.toJson());
        notifyListeners();
        return true;
      } catch (e) {
        // Try next payload variant for compatibility.
      }
    }
    return false;
  }

  List<Map<String, dynamic>> _buildUpdateProfileAttempts(Map<String, dynamic> data) {
    final base = Map<String, dynamic>.from(data);
    final status = base['availabilityStatus'];
    if (status == null) return [base];

    final String? parsedStatus = status.toString();
    final statusPayload = Map<String, dynamic>.from(base)
      ..remove('status')
      ..remove('availability')
      ..['availabilityStatus'] = parsedStatus;

    final aliasStatusPayload = Map<String, dynamic>.from(base)
      ..remove('availabilityStatus')
      ..remove('availability')
      ..['status'] = parsedStatus;

    final aliasAvailabilityPayload = Map<String, dynamic>.from(base)
      ..remove('availabilityStatus')
      ..remove('status')
      ..['availability'] = parsedStatus;

    return _dedupePayloadAttempts([
      base,
      statusPayload,
      aliasStatusPayload,
      aliasAvailabilityPayload,
    ]);
  }

  List<Map<String, dynamic>> _dedupePayloadAttempts(List<Map<String, dynamic>> attempts) {
    final deduped = <Map<String, dynamic>>[];
    for (final attempt in attempts) {
      final isDuplicate = deduped.any((existing) => _payloadsEqual(existing, attempt));
      if (!isDuplicate) {
        deduped.add(attempt);
      }
    }
    return deduped;
  }

  bool _payloadsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      if (!b.containsKey(entry.key) || b[entry.key] != entry.value) return false;
    }
    return true;
  }

  Map<String, dynamic> _cleanProfilePayload(Map<String, dynamic> data) {
    final cleaned = <String, dynamic>{};
    data.forEach((key, value) {
      if (value != null) {
        cleaned[key] = value;
      }
    });
    return cleaned;
  }
}
