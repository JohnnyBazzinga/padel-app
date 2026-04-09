import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/providers/auth_provider.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/home/screens/main_screen.dart';
import '../../features/clubs/screens/clubs_screen.dart';
import '../../features/clubs/screens/club_detail_screen.dart';
import '../../features/bookings/screens/booking_screen.dart';
import '../../features/bookings/screens/my_bookings_screen.dart';
import '../../features/matches/screens/matches_screen.dart';
import '../../features/matches/screens/match_detail_screen.dart';
import '../../features/matches/screens/create_match_screen.dart';
import '../../features/tournaments/screens/tournaments_screen.dart';
import '../../features/tournaments/screens/tournament_detail_screen.dart';
import '../../features/rankings/screens/rankings_screen.dart';
import '../../features/chat/screens/conversations_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/friends/screens/friends_screen.dart';

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

        if (isLoading) return null;

        if (!isLoggedIn && !isAuthRoute) {
          return '/login';
        }

        if (isLoggedIn && isAuthRoute && state.matchedLocation != '/') {
          return '/home';
        }

        return null;
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
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/clubs',
              builder: (context, state) => const ClubsScreen(),
            ),
            GoRoute(
              path: '/matches',
              builder: (context, state) => const MatchesScreen(),
            ),
            GoRoute(
              path: '/rankings',
              builder: (context, state) => const RankingsScreen(),
            ),
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
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
          path: '/tournaments',
          builder: (context, state) => const TournamentsScreen(),
        ),
        GoRoute(
          path: '/tournaments/:id',
          builder: (context, state) => TournamentDetailScreen(
            tournamentId: state.pathParameters['id']!,
          ),
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
        GoRoute(
          path: '/friends',
          builder: (context, state) => const FriendsScreen(),
        ),
      ],
    );
  }
}
