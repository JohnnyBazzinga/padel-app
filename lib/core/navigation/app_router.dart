import 'package:go_router/go_router.dart';

import '../../shared/providers/auth_provider.dart';
import '../../shared/models/social_post.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/home/screens/social_feed_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/clubs/screens/clubs_screen.dart';
import '../../features/clubs/screens/club_detail_screen.dart';
import '../../features/bookings/screens/booking_screen.dart';
import '../../features/bookings/screens/my_bookings_screen.dart';
import '../../features/matches/screens/matches_screen.dart';
import '../../features/matches/screens/match_detail_screen.dart';
import '../../features/matches/screens/create_match_screen.dart';
import '../../features/rankings/screens/rankings_screen.dart';
import '../../features/chat/screens/conversations_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/need_one/screens/need_one_screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider auth) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: auth,
      redirect: (context, state) {
        final isLoggedIn = auth.isAuthenticated;
        final isLoading = auth.isLoading;
        final isAuthRoute = state.matchedLocation == '/login' ||
            state.matchedLocation == '/register' ||
            state.matchedLocation == '/';
        final isCreateMatchRoute = state.matchedLocation == '/create-match';

        return AppRouteGuard.resolve(
          isLoading: isLoading,
          isLoggedIn: isLoggedIn,
          isAuthRoute: isAuthRoute,
          location: state.matchedLocation,
          isCreateMatchRoute: isCreateMatchRoute,
          canCreateMatches: auth.canCreateMatches,
        );
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainScreen(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const SocialFeedScreen(),
            ),
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: '/matches',
              builder: (context, state) => const MatchesScreen(),
            ),
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationsScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
            GoRoute(
              path: '/profile/:userId',
              builder: (context, state) => ProfileScreen(
                profileUserId: state.pathParameters['userId'],
                previewAuthor:
                    state.extra is PostAuthor ? state.extra as PostAuthor : null,
              ),
            ),
            GoRoute(
              path: '/need-1',
              builder: (context, state) => const NeedOneScreen(),
            ),
            GoRoute(
              path: '/clubs',
              builder: (context, state) => const ClubsScreen(),
            ),
            GoRoute(
              path: '/rankings',
              builder: (context, state) => const RankingsScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/clubs/:id',
          builder: (context, state) => ClubDetailScreen(
            clubId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/booking/:courtId',
          builder: (context, state) => BookingScreen(
            courtId: state.pathParameters['courtId']!,
            date: state.uri.queryParameters['date'],
          ),
        ),
        GoRoute(
          path: '/my-bookings',
          builder: (context, state) => const MyBookingsScreen(),
        ),
        GoRoute(
          path: '/matches/:id',
          builder: (context, state) => MatchDetailScreen(
            matchId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/create-match',
          builder: (context, state) => const CreateMatchScreen(),
        ),
        GoRoute(
          path: '/chat',
          builder: (context, state) => const ConversationsScreen(),
        ),
        GoRoute(
          path: '/chat/:id',
          builder: (context, state) => ChatScreen(
            conversationId: state.pathParameters['id']!,
          ),
        ),
        GoRoute(
          path: '/edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
      ],
    );
  }
}

class AppRouteGuard {
  static String? resolve({
    required bool isLoading,
    required bool isLoggedIn,
    required bool isAuthRoute,
    required String location,
    required bool isCreateMatchRoute,
    required bool canCreateMatches,
  }) {
    if (isLoading) return null;

    if (!isLoggedIn && !isAuthRoute) {
      return '/login';
    }

    if (isLoggedIn && isAuthRoute && location != '/') {
      return '/home';
    }

    if (isCreateMatchRoute && !canCreateMatches) {
      return '/matches';
    }

    return null;
  }
}
