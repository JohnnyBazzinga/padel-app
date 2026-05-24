import 'package:flutter_test/flutter_test.dart';

import 'package:padel_app/shared/providers/chat_provider.dart';
import 'package:padel_app/shared/providers/notifications_provider.dart';

void main() {
  test('parses notification identifiers and bool string values safely', () {
    final notification = AppNotification.fromJson({
      'id': 1234,
      'type': 'INFO',
      'title': 'Nova notificação',
      'message': 'Mensagem',
      'data': {'foo': 'bar'},
      'isRead': 'true',
      'createdAt': '2026-01-01T00:00:00.000Z',
    });

    expect(notification.id, '1234');
    expect(notification.isRead, isTrue);
  });

  test('parses ids and unread count from mixed payloads', () {
    final notification = AppNotification.fromJson({
      'id': 'n1',
      'type': 'INFO',
      'title': 'X',
      'message': 'Y',
      'isRead': false,
      'createdAt': null,
    });

    expect(notification.createdAt, isNotNull);

    final conversation = Conversation.fromJson({
      'id': 555,
      'otherUser': {'firstName': 'Ana', 'lastName': 'L'},
      'lastMessage': {'content': 'hi'},
      'lastMessageAt': null,
      'unreadCount': '12',
    });

    expect(conversation.id, '555');
    expect(conversation.unreadCount, 12);
  });

  test('parses message model safely with mixed types', () {
    final message = ChatMessage.fromJson({
      'id': 999,
      'conversationId': 7,
      'senderId': 11,
      'content': 'Ola',
      'status': null,
      'createdAt': null,
      'sender': {'name': 'Ana'},
    });

    expect(message.id, '999');
    expect(message.conversationId, '7');
    expect(message.senderId, '11');
    expect(message.status, 'SENT');
  });
}
