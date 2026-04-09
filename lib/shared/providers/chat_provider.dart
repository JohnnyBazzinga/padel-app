import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class Conversation {
  final String id;
  final Map<String, dynamic>? otherUser;
  final Map<String, dynamic>? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  Conversation({
    required this.id,
    this.otherUser,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  String get otherUserName {
    if (otherUser == null) return '';
    return '${otherUser!['firstName'] ?? ''} ${otherUser!['lastName'] ?? ''}'.trim();
  }

  String? get otherUserAvatar => otherUser?['avatarUrl'];
  String get otherUserId => otherUser?['id'] ?? '';

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      otherUser: json['otherUser'],
      lastMessage: json['lastMessage'],
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}

class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic>? sender;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    required this.status,
    required this.createdAt,
    this.sender,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      content: json['content'],
      status: json['status'] ?? 'SENT',
      createdAt: DateTime.parse(json['createdAt']),
      sender: json['sender'],
    );
  }
}

class ChatProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<Conversation> _conversations = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/chat/conversations');
      _conversations = (response.data['data'] as List)
          .map((c) => Conversation.fromJson(c))
          .toList();
    } catch (e) {
      _error = 'Erro ao carregar conversas';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMessages(String conversationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('/chat/conversations/$conversationId/messages');
      _messages = (response.data['data']['data'] as List)
          .map((m) => ChatMessage.fromJson(m))
          .toList();
    } catch (e) {
      _error = 'Erro ao carregar mensagens';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<ChatMessage?> sendMessage(String receiverId, String content) async {
    try {
      final response = await _api.post('/chat/messages', data: {
        'receiverId': receiverId,
        'content': content,
      });
      final message = ChatMessage.fromJson(response.data['data']);
      _messages.add(message);
      notifyListeners();
      return message;
    } catch (e) {
      return null;
    }
  }

  Future<Conversation?> getOrCreateConversation(String userId) async {
    try {
      final response = await _api.post('/chat/conversations/$userId');
      return Conversation.fromJson(response.data['data']);
    } catch (e) {
      return null;
    }
  }

  Future<void> markAsRead(String conversationId) async {
    try {
      await _api.post('/chat/conversations/$conversationId/read');
    } catch (e) {
      // Ignore
    }
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }
}
