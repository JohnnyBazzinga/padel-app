import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (success && mounted) {
      final next = GoRouterState.of(context).uri.queryParameters['next'];
      final target = (next != null && next.isNotEmpty)
          ? Uri.decodeComponent(next)
          : '/home';
      context.go(target);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Erro ao fazer login'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: AppDecorations.borderRadiusMd,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo
                _Logo().animate().fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

                const SizedBox(height: 40),

                // Welcome Text
                Text(
                  'Bem-vindo de volta!',
                  style: AppTypography.h1,
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                Text(
                  'Entra na tua conta para continuar',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                const SizedBox(height: 48),

                // Email Input
                CustomTextField(
                  label: 'Email',
                  hint: 'exemplo@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Introduz o teu email';
                    }
                    if (!value.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 400.ms)
                    .slideX(begin: -0.1, end: 0),

                const SizedBox(height: 20),

                // Password Input
                CustomTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.lock_outlined,
                  onSubmitted: (_) => _login(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Introduz a tua password';
                    }
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 500.ms)
                    .slideX(begin: -0.1, end: 0),

                const SizedBox(height: 12),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Forgot password
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: Text(
                      'Esqueceste a password?',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                const SizedBox(height: 32),

                // Login Button
                PrimaryButton(
                  label: 'Entrar',
                  isLoading: _isLoading,
                  onPressed: _login,
                )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 700.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 32),

                // Divider
                DividerWithText(text: 'ou')
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 800.ms),

                const SizedBox(height: 32),

                // Social Login Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialButton(
                      icon: Icons.g_mobiledata_rounded,
                      onTap: () {},
                    ),
                    AppSpacing.horizontalLg,
                    _SocialButton(
                      icon: Icons.apple_rounded,
                      onTap: () {},
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 900.ms),

                const SizedBox(height: 48),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não tens conta? ',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final next = GoRouterState.of(context).uri.queryParameters['next'];
                        final target = next != null && next.isNotEmpty
                            ? '/register?next=${Uri.encodeComponent(next)}'
                            : '/register';
                        context.push(target);
                      },
                      child: Text(
                        'Criar conta',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 1000.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Image.asset(
          'assets/images/logo.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: AppDecorations.borderRadiusMd,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDecorations.borderRadiusMd,
          child: Center(
            child: Icon(
              icon,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
