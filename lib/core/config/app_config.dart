class AppConfig {
  static const String appName = 'Padel App';

  // API
  static const String apiBaseUrl = 'https://padel-backend-production-5eca.up.railway.app/api';
  static const String wsBaseUrl = 'wss://padel-backend-production-5eca.up.railway.app';

  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
}
