import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../services/storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  final StorageService _storage = StorageService();

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: AppConfig.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              final opts = error.requestOptions;
              final token = await _storage.getAccessToken();
              opts.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${AppConfig.apiBaseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        await _storage.saveTokens(
          response.data['data']['accessToken'],
          response.data['data']['refreshToken'],
        );
        return true;
      }
    } catch (e) {
      await _storage.clearTokens();
    }
    return false;
  }

  // GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  // POST
  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  // PATCH
  Future<Response> patch(String path, {dynamic data}) {
    return _dio.patch(path, data: data);
  }

  // DELETE
  Future<Response> delete(String path, {dynamic data}) {
    return _dio.delete(path, data: data);
  }
}
