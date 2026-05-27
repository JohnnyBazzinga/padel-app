import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/clubs_provider.dart';
import 'shared/providers/bookings_provider.dart';
import 'shared/providers/matches_provider.dart';
import 'shared/providers/rankings_provider.dart';
import 'shared/providers/chat_provider.dart';
import 'shared/providers/notifications_provider.dart';
import 'shared/providers/social_feed_provider.dart';
import 'shared/providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Portuguese locale
  await initializeDateFormatting('pt_PT', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const PadelApp());
}

class PadelApp extends StatelessWidget {
  const PadelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ClubsProvider()),
        ChangeNotifierProvider(create: (_) => BookingsProvider()),
        ChangeNotifierProvider(create: (_) => MatchesProvider()),
        ChangeNotifierProvider(create: (_) => RankingsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => SocialFeedProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
      return MaterialApp.router(
            title: 'Padel App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            routerConfig: AppRouter.router(auth),
          );
        },
      ),
    );
  }
}
