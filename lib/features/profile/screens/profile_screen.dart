import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/friends_provider.dart';
import '../../../shared/providers/notifications_provider.dart';
import '../../../shared/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final friends = context.watch<FriendsProvider>();
    final notifications = context.watch<NotificationsProvider>();
    final user = auth.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            children: [
              // Header with edit button
              Padding(
                padding: AppSpacing.screenPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Perfil', style: AppTypography.h1),
                    AppIconButton(
                      icon: Icons.edit_outlined,
                      variant: AppIconButtonVariant.glass,
                      onPressed: () => context.push('/edit-profile'),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalXl,

              // Profile Card
              _ProfileHeader(user: user)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

              AppSpacing.verticalXxl,

              // Stats
              Padding(
                padding: AppSpacing.screenPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        value: '${user.matchesPlayed}',
                        label: 'Jogos',
                        icon: Icons.sports_tennis_rounded,
                        accentColor: AppColors.primary,
                      ),
                    ),
                    AppSpacing.horizontalMd,
                    Expanded(
                      child: StatCard(
                        value: '${user.matchesWon}',
                        label: 'Vitórias',
                        icon: Icons.emoji_events_rounded,
                        accentColor: AppColors.accent,
                      ),
                    ),
                    AppSpacing.horizontalMd,
                    Expanded(
                      child: StatCard(
                        value: '${user.winRate.toStringAsFixed(0)}%',
                        label: 'Win Rate',
                        icon: Icons.trending_up_rounded,
                        accentColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),

              AppSpacing.verticalXxl,

              // Progress to next level
              Padding(
                padding: AppSpacing.screenPadding,
                child: _LevelProgress(
                  currentLevel: user.skillLevel,
                  progress: 0.7, // TODO: Calculate actual progress
                  pointsToNext: 8,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 150.ms),

              AppSpacing.verticalXxl,

              // Menu Items
              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONTA',
                      style: AppTypography.overline.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    AppSpacing.verticalMd,
                    _MenuCard(
                      items: [
                        _MenuItem(
                          icon: Icons.calendar_today_rounded,
                          label: 'Minhas Reservas',
                          onTap: () => context.push('/my-bookings'),
                        ),
                        if (auth.canInviteOrganizer)
                          _MenuItem(
                            icon: Icons.admin_panel_settings_rounded,
                            label: 'Convidar organizador',
                            onTap: () => context.push('/admin/invite-organizer'),
                          ),
                        _MenuItem(
                          icon: Icons.people_rounded,
                          label: 'Amigos',
                          badge: friends.pendingCount > 0 ? friends.pendingCount.toString() : null,
                          onTap: () => context.push('/friends'),
                        ),
                        _MenuItem(
                          icon: Icons.leaderboard_rounded,
                          label: 'Meu Ranking',
                          onTap: () => context.push('/rankings'),
                        ),
                        _MenuItem(
                          icon: Icons.history_rounded,
                          label: 'Histórico de Jogos',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms),

              AppSpacing.verticalXl,

              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PREFERÊNCIAS',
                      style: AppTypography.overline.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    AppSpacing.verticalMd,
                    _MenuCard(
                      items: [
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          label: 'Notificações',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.settings_outlined,
                          label: 'Definições',
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.help_outline_rounded,
                          label: 'Ajuda & Suporte',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 250.ms),

              AppSpacing.verticalXl,

              // Logout
              Padding(
                padding: AppSpacing.screenPadding,
                child: _LogoutButton(
                  onTap: () async {
                    await auth.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: GradientCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar with gradient border
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: AppDecorations.shadowGlow(AppColors.primary, intensity: 0.3),
              ),
              child: UserAvatar(
                imageUrl: user.avatarUrl,
                name: user.fullName.isNotEmpty ? user.fullName : user.email,
                size: 90,
                showBorder: true,
                borderColor: AppColors.surface,
                showGradient: false,
              ),
            ),
            AppSpacing.verticalLg,

            // Name
            Text(
              user.fullName.isNotEmpty ? user.fullName : user.email,
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSm,

            // Level badge
            LevelBadge(level: _getDisplayLevel(user.skillLevel)),

            if (user.city != null) ...[
              AppSpacing.verticalMd,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    user.city!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],

            if (user.roles.isNotEmpty) ...[
              AppSpacing.verticalMd,
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: user.roles
                    .map(
                      (role) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: AppDecorations.borderRadiusFull,
                        ),
                        child: Text(
                          role,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getDisplayLevel(String level) {
    switch (level.toUpperCase()) {
      case 'BEGINNER':
        return 'Iniciante';
      case 'INTERMEDIATE':
        return 'Intermédio';
      case 'ADVANCED':
        return 'Avançado';
      case 'PROFESSIONAL':
        return 'Profissional';
      default:
        return level;
    }
  }
}

class _LevelProgress extends StatelessWidget {
  final String currentLevel;
  final double progress;
  final int pointsToNext;

  const _LevelProgress({
    required this.currentLevel,
    required this.progress,
    required this.pointsToNext,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso',
                style: AppTypography.h4,
              ),
              Text(
                '$pointsToNext vitórias para o próximo n��vel',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          AppSpacing.verticalLg,
          // Progress bar
          ClipRRect(
            borderRadius: AppDecorations.borderRadiusFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.surfaceBright,
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          AppSpacing.verticalMd,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getDisplayLevel(currentLevel),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.getSkillColor(currentLevel),
                ),
              ),
              Text(
                _getNextLevel(currentLevel),
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDisplayLevel(String level) {
    switch (level.toUpperCase()) {
      case 'BEGINNER':
        return 'Iniciante';
      case 'INTERMEDIATE':
        return 'Intermédio';
      case 'ADVANCED':
        return 'Avançado';
      case 'PROFESSIONAL':
        return 'Profissional';
      default:
        return level;
    }
  }

  String _getNextLevel(String level) {
    switch (level.toUpperCase()) {
      case 'BEGINNER':
        return 'Intermédio';
      case 'INTERMEDIATE':
        return 'Avançado';
      case 'ADVANCED':
        return 'Profissional';
      default:
        return 'Max';
    }
  }
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.gradientCard,
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              item,
              if (index < items.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 1,
                    color: AppColors.glassBorder,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconColor = isDestructive ? AppColors.error : AppColors.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? AppColors.error.withOpacity(0.1)
                      : AppColors.surfaceBright,
                  borderRadius: AppDecorations.borderRadiusSm,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.bodyLarge.copyWith(color: color),
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: AppDecorations.borderRadiusFull,
                  ),
                  child: Text(
                    badge!,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppSpacing.horizontalSm,
              ],
              Icon(
                Icons.chevron_right_rounded,
                color: iconColor,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: AppDecorations.borderRadiusLg,
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDecorations.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                AppSpacing.horizontalSm,
                Text(
                  'Terminar sessão',
                  style: AppTypography.buttonText.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
