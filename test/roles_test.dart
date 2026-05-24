import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/core/access/app_roles.dart';

void main() {
  test('normalizes roles with different casing', () {
    final roles = AppRoles.normalizeRoles(['player', 'Organizer', 'guest']);
    expect(roles.contains('PLAYER'), isTrue);
    expect(roles.contains('ORGANIZER'), isTrue);
    expect(roles.contains('GUEST'), isTrue);
  });

  test('admin has create tournament permission', () {
    final roles = ['admin'];
    expect(AppRoles.canCreateTournaments(roles), isTrue);
    expect(AppRoles.canInviteOrganizer(roles), isTrue);
  });

  test('player cannot invite organizers', () {
    final roles = ['PLAYER'];
    expect(AppRoles.canInviteOrganizer(roles), isFalse);
    expect(AppRoles.canCreateTournaments(roles), isFalse);
  });

  test('platform admin has all admin permissions', () {
    final roles = [AppRoles.platformAdmin];
    expect(AppRoles.canCreateTournaments(roles), isTrue);
    expect(AppRoles.canInviteOrganizer(roles), isTrue);
    expect(AppRoles.isPlatformAdministrator(roles), isTrue);
    expect(AppRoles.isOrganizer(roles), isTrue);
  });

  test('admin can access admin area but does not need platform_admin', () {
    final roles = [AppRoles.admin];
    expect(AppRoles.canAccessAdminArea(roles), isTrue);
    expect(AppRoles.isPlatformAdministrator(roles), isFalse);
  });

  test('club owner and club manager are treated as organizer-level users', () {
    final roles = [AppRoles.clubOwner];
    expect(AppRoles.isOrganizer(roles), isTrue);
    expect(AppRoles.canCreateMatches(roles), isTrue);

    final rolesWithManager = [AppRoles.clubManager];
    expect(AppRoles.isOrganizer(rolesWithManager), isTrue);
    expect(AppRoles.canCreateMatches(rolesWithManager), isTrue);
  });
}
