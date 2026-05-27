import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/core/navigation/app_router.dart';

void main() {
  group('AppRouteGuard.resolve', () {
    test('returns null while auth is loading', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: true,
        isLoggedIn: false,
        isAuthRoute: false,
        location: '/home',
        isCreateMatchRoute: false,
        canCreateMatches: false,
      );

      expect(redirect, isNull);
    });

    test('redirects unauthenticated users to login', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: false,
        isAuthRoute: false,
        location: '/matches',
        isCreateMatchRoute: false,
        canCreateMatches: false,
      );

      expect(redirect, '/login');
    });

    test('allows token invite route without auth', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: false,
        isAuthRoute: false,
        location: '/roles/invitations',
        isCreateMatchRoute: false,
        canCreateMatches: false,
      );

      expect(redirect, isNull);
    });

    test('moves authenticated users away from auth screens', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: true,
        isAuthRoute: true,
        location: '/login',
        isCreateMatchRoute: false,
        canCreateMatches: false,
      );

      expect(redirect, '/home');
    });

    test('blocks admin area for non-admin users', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: true,
        isAuthRoute: false,
        location: '/admin/invite-organizer',
        isCreateMatchRoute: false,
        canCreateMatches: false,
      );

      expect(redirect, '/home');
    });

    test('allows admin routes for authorized admin users', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: true,
        isAuthRoute: false,
        location: '/admin/invite-organizer',
        isCreateMatchRoute: false,
        canCreateMatches: false,
      );

      expect(redirect, isNull);
    });

    test('blocks match creation when role is not organizer', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: true,
        isAuthRoute: false,
        location: '/create-match',
        isCreateMatchRoute: true,
        canCreateMatches: false,
      );

      expect(redirect, '/matches');
    });

    test('allows match creation for organizer/admin roles', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: true,
        isAuthRoute: false,
        location: '/create-match',
        isCreateMatchRoute: true,
        canCreateMatches: true,
      );

      expect(redirect, isNull);
    });

    test('blocks tournament creation when role lacks organizer permission', () {
      final redirect = AppRouteGuard.resolve(
        isLoading: false,
        isLoggedIn: true,
        isAuthRoute: false,
        location: '/tournaments/create',
        isCreateMatchRoute: false,
        canCreateMatches: false,
      );

      expect(redirect, '/tournaments');
    });
  });
}
