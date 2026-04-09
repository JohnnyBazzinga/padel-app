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
    return AppNotification(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      message: json['message'],
      data: json['data'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
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
      _notifications = (response.data['data']['data'] as List)
          .map((n) => AppNotification.fromJson(n))
          .toList();
      _unreadCount = response.data['data']['meta']['unreadCount'] ?? 0;
    } catch (e) {
      _error = 'Erro ao carregar notificações';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _api.get('/notifications/unread-count');
      _unreadCount = response.data['data']['count'] ?? 0;
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
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      // Ignore
    }
  }
}
