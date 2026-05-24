import 'package:flutter/material.dart';

import '../models/user_model.dart';
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
    try {
      final response = await _api.patch('/users/me', data: data);
      _user = User.fromJson(response.data['data']);
      await _storage.saveUser(_user!.toJson());
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
