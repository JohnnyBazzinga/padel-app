import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) {
      context.go('/home');
    } else if (!auth.isLoading) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background tone
          Positioned.fill(
            child: Container(
              color: AppColors.background,
            ),
          ),

          // Animated background circles
          ..._buildBackgroundCircles(),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                _AnimatedLogo(),

                const SizedBox(height: 24),

                // Tagline
                Text(
                  'Joga. Conecta. Vence.',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 3,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 600.ms),

                const SizedBox(height: 60),

                // Loading indicator
                _LoadingIndicator()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 800.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBackgroundCircles() {
    return [
      Positioned(
        top: -100,
        right: -100,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withOpacity(0.08),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              duration: 3.seconds,
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(1.2, 1.2),
              end: const Offset(0.8, 0.8),
              duration: 3.seconds,
              curve: Curves.easeInOut,
            ),
      ),
      Positioned(
        bottom: -150,
        left: -100,
        child: Container(
          width: 400,
          height: 400,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary.withOpacity(0.06),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.3, 1.3),
              duration: 4.seconds,
              curve: Curves.easeInOut,
            )
            .then()
            .scale(
              begin: const Offset(1.3, 1.3),
              end: const Offset(1, 1),
              duration: 4.seconds,
              curve: Curves.easeInOut,
            ),
      ),
    ];
  }
}

class _AnimatedLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 60,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 800.ms,
          curve: Curves.elasticOut,
        );
  }
}

class _LoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary.withOpacity(0.3),
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
              strokeCap: StrokeCap.round,
            )
                .animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 1.seconds),
          ),
        ],
      ),
    );
  }
}
