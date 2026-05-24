import 'package:flutter_test/flutter_test.dart';

import 'package:padel_app/shared/models/role_invitation.dart';

void main() {
  test('parses invitation from inviter object', () {
    final model = RoleInvitation.fromJson({
      'id': 'inv_1',
      'email': 'admin@club.pt',
      'role': 'ORGANIZER',
      'status': 'PENDING',
      'invitedBy': {
        'email': 'creator@club.pt',
      },
      'token': 'abc',
      'createdAt': '2025-01-01T10:00:00.000Z',
      'updatedAt': '2025-01-01T10:00:00.000Z',
    });

    expect(model.invitedBy, 'creator@club.pt');
    expect(model.displayRole, 'ORGANIZER');
    expect(model.isPending, isTrue);
  });

  test('defaults invitedBy to Sistema when omitted', () {
    final model = RoleInvitation.fromJson({
      'id': 'inv_2',
      'email': 'guest@club.pt',
      'status': 'PENDING',
      'token': 'abc2',
      'createdAt': '2025-01-01T10:00:00.000Z',
      'updatedAt': '2025-01-01T10:00:00.000Z',
    });

    expect(model.invitedBy, 'Sistema');
    expect(model.displayRole, 'PLAYER');
    expect(model.isPending, isTrue);
  });
}
