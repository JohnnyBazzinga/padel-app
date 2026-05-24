import 'package:flutter_test/flutter_test.dart';

import 'package:padel_app/shared/models/user_model.dart';

void main() {
  test('parses roles from both string and object forms', () {
    final user = User.fromJson({
      'id': 123,
      'email': 'test@padel.pt',
      'roles': [
        'PLAYER',
        {'role': 'ORGANIZER'},
        {'role': 7},
      ],
    });

    expect(user.id, '123');
    expect(user.email, 'test@padel.pt');
    expect(user.roles, contains('PLAYER'));
    expect(user.roles, contains('ORGANIZER'));
    expect(user.roles, isNot(contains('7')));
  });

  test('uses defaults when optional user fields are missing', () {
    final user = User.fromJson({
      'id': null,
      'email': null,
      'matchesPlayed': '10',
      'matchesWon': '2',
      'yearsPlaying': '5',
      'totalPoints': '100',
    });

    expect(user.id, '');
    expect(user.email, '');
    expect(user.matchesPlayed, 10);
    expect(user.matchesWon, 2);
    expect(user.yearsPlaying, 5);
    expect(user.totalPoints, 100);
    expect(user.skillLevel, 'BEGINNER');
    expect(user.roles, isEmpty);
  });
}
