import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/core/navigation/app_router.dart';

void main() {
  group('AppRouteGuard.resolve', () {
    test('returns null while auth is loading', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: true,
        isLoggedIn: false,
        isAuthRoute: false,
        isInviteRoute: false,
        location: '/home',
        isAdminArea: false,
        isCreateMatchRoute: false,
        isTournamentCreatorRoute: false,
        canAccessAdminArea: false,
        canCreateMatches: false,
        canCreateTournaments: false,
      );

      expect(redirect, isNull);
    });

    test('redirects unauthenticated users to login', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: false,
        isAuthRoute: false,
        isInviteRoute: false,
        location: '/matches',
        isAdminArea: false,
        isCreateMatchRoute: false,
        isTournamentCreatorRoute: false,
        canAccessAdminArea: false,
        canCreateMatches: false,
        canCreateTournaments: false,
      );

      expect(redirect, '/login');
    });

    test('allows token invite route without auth', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: false,
        isAuthRoute: false,
        isInviteRoute: true,
        location: '/roles/invitations',
        isAdminArea: false,
        isCreateMatchRoute: false,
        isTournamentCreatorRoute: false,
        canAccessAdminArea: false,
        canCreateMatches: false,
        canCreateTournaments: false,
      );

      expect(redirect, isNull);
    });

    test('moves authenticated users away from auth screens', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: true,
        isAuthRoute: true,
        isInviteRoute: false,
        location: '/login',
        isAdminArea: false,
        isCreateMatchRoute: false,
        isTournamentCreatorRoute: false,
        canAccessAdminArea: false,
        canCreateMatches: false,
        canCreateTournaments: false,
      );

      expect(redirect, '/home');
    });

    test('blocks admin area for non-admin users', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: true,
        isAuthRoute: false,
        isInviteRoute: false,
        location: '/admin/invite-organizer',
        isAdminArea: true,
        isCreateMatchRoute: false,
        isTournamentCreatorRoute: false,
        canAccessAdminArea: false,
        canCreateMatches: false,
        canCreateTournaments: false,
      );

      expect(redirect, '/home');
    });

    test('allows admin routes for authorized admin users', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: true,
        isAuthRoute: false,
        isInviteRoute: false,
        location: '/admin/invite-organizer',
        isAdminArea: true,
        isCreateMatchRoute: false,
        isTournamentCreatorRoute: false,
        canAccessAdminArea: true,
        canCreateMatches: false,
        canCreateTournaments: false,
      );

      expect(redirect, isNull);
    });

    test('blocks match creation when role is not organizer', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: true,
        isAuthRoute: false,
        isInviteRoute: false,
        location: '/create-match',
        isAdminArea: false,
        isCreateMatchRoute: true,
        isTournamentCreatorRoute: false,
        canAccessAdminArea: false,
        canCreateMatches: false,
        canCreateTournaments: false,
      );

      expect(redirect, '/matches');
    });

    test('allows match creation for organizer/admin roles', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: true,
        isAuthRoute: false,
        isInviteRoute: false,
        location: '/create-match',
        isAdminArea: false,
        isCreateMatchRoute: true,
        isTournamentCreatorRoute: false,
        canAccessAdminArea: false,
        canCreateMatches: true,
        canCreateTournaments: false,
      );

      expect(redirect, isNull);
    });

    test('blocks tournament creation when role lacks organizer permission', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: true,
        isAuthRoute: false,
        isInviteRoute: false,
        location: '/tournaments/create',
        isAdminArea: false,
        isCreateMatchRoute: false,
        isTournamentCreatorRoute: true,
        canAccessAdminArea: false,
        canCreateMatches: false,
        canCreateTournaments: false,
      );

      expect(redirect, '/tournaments');
    });
  });
}
