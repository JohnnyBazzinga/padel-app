import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  StorageService._internal();

  // Tokens
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: AppConfig.accessTokenKey, value: accessToken);
    await _storage.write(key: AppConfig.refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConfig.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConfig.refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConfig.accessTokenKey);
    await _storage.delete(key: AppConfig.refreshTokenKey);
    await _storage.delete(key: AppConfig.userKey);
  }

  // User
  Future<void> saveUser(Map<String, dynamic> user) async {
    await _storage.write(key: AppConfig.userKey, value: jsonEncode(user));
  }

  Future<Map<String, dynamic>?> getUser() async {
    final data = await _storage.read(key: AppConfig.userKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  Future<bool> hasTokens() async {
    final token = await getAccessToken();
    return token != null;
  }
}
