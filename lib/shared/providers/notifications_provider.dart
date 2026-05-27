import 'package:flutter/material.dart';

import '../../core/api/api_client.dart';

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value, bool fallback) {
      if (value is bool) return value;
      if (value is String) {
        return switch (value.toLowerCase().trim()) {
          'true' || '1' || 'yes' || 'y' => true,
          'false' || '0' || 'no' || 'n' => false,
          _ => fallback,
        };
      }
      if (value is num) return value != 0;
      return fallback;
    }

    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
      isRead: parseBool(json['isRead'], false),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  AppNotification copyWith({
    bool? isRead,
    String? id,
    String? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class NotificationsProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/notifications');
      final payload = _unwrapPayload(response.data);
      final list = _extractList(payload);
      _notifications = list.map(AppNotification.fromJson).toList();
      _unreadCount = _extractUnreadCount(payload);
    } catch (e) {
      _error = 'Erro ao carregar notificaÃ§Ãµes';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _api.get('/notifications/unread-count');
      _unreadCount = _extractUnreadCount(response.data['data']?['count']);
      notifyListeners();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _api.post('/notifications/$id/read');
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount = (_unreadCount - 1).clamp(0, _unreadCount);
      }
      notifyListeners();
    } catch (e) {
      // Ignore
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.post('/notifications/read-all');
      _notifications = _notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      // Ignore
    }
  }

  dynamic _unwrapPayload(dynamic data) {
    if (data == null) return null;
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      return nested ?? data;
    }
    return data;
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data == null) return [];
    if (data is List) return data.whereType<Map<String, dynamic>>().toList();

    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is List) return nested.whereType<Map<String, dynamic>>().toList();
      if (nested is Map<String, dynamic>) {
        final inner = nested['data'];
        if (inner is List) return inner.whereType<Map<String, dynamic>>().toList();
      }
    }
    return [];
  }

  int _extractUnreadCount(dynamic value) {
    if (value == null) return 0;

    if (value is Map<String, dynamic>) {
      if (value['unreadCount'] != null) {
        return _extractUnreadCount(value['unreadCount']);
      }
      final meta = value['meta'];
      if (meta is Map<String, dynamic> && meta['unreadCount'] != null) {
        return _extractUnreadCount(meta['unreadCount']);
      }
    }

    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

