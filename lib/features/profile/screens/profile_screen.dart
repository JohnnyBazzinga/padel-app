import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/models/social_post.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/profile_provider.dart';
import '../../../shared/widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  final String? profileUserId;
  final PostAuthor? previewAuthor;

  const ProfileScreen({
    super.key,
    this.profileUserId,
    this.previewAuthor,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _lastRequestedProfileId;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadPublicProfileIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileUserId != widget.profileUserId) {
      _loadPublicProfileIfNeeded();
    }
  }

  void _loadPublicProfileIfNeeded() {
    final profileProvider = context.read<ProfileProvider>();
    final currentUser = context.read<AuthProvider>().user;
    final targetId = _normalizeProfileId();

    final isOwnProfile =
        targetId == null || (currentUser != null && currentUser.id == targetId);
    if (isOwnProfile || targetId == null) return;
    if (_lastRequestedProfileId == targetId &&
        profileProvider.isLoading(targetId)) {
      return;
    }

    _lastRequestedProfileId = targetId;
    if (profileProvider.getProfile(targetId) == null &&
        !profileProvider.isLoading(targetId)) {
      profileProvider.loadProfile(
        userId: targetId,
        fallbackAuthor: widget.previewAuthor,
      );
    }
  }

  Future<void> _refreshProfile() async {
    final targetId = _normalizeProfileId();
    if (targetId == null) {
      await context.read<AuthProvider>().refreshUser();
      return;
    }

    await context.read<ProfileProvider>().loadProfile(
          userId: targetId,
          fallbackAuthor: widget.previewAuthor,
          force: true,
        );
  }

  String? _normalizeProfileId() {
    if (widget.profileUserId == null) return null;
    final id = widget.profileUserId!.trim();
    return id.isEmpty ? null : id;
  }

  User _buildFallbackUser(String id, User? currentUser) {
    if (widget.previewAuthor != null) {
      return _userFromAuthor(widget.previewAuthor!, id);
    }

    if (widget.profileUserId == null && currentUser != null) {
      return currentUser;
    }

    return User(
      id: id,
      email: '',
      firstName: 'Utilizador',
      skillLevel: 'BEGINNER',
      avatarUrl: null,
      city: null,
      availabilityStatus: null,
      reputationScore: 0,
      reputationSignals: 0,
      matchesPlayed: 0,
      matchesWon: 0,
      totalPoints: 0,
      roles: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final currentUser = auth.user;

    final targetId = _normalizeProfileId();
    final isOwnProfile =
        targetId == null || (currentUser != null && targetId == currentUser.id);
    final hasPublicProfile = targetId != null;

    if (targetId == null && currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!isOwnProfile && hasPublicProfile) {
      _loadPublicProfileIfNeeded();
    }

    final user = isOwnProfile
        ? currentUser
        : profileProvider.getProfile(targetId!) ??
            _buildFallbackUser(targetId, currentUser);

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'Não foi possível carregar o perfil.',
            style: AppTypography.bodyMedium,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshProfile,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              children: [
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isOwnProfile ? 'Perfil' : 'Perfil do jogador',
                        style: AppTypography.h1,
                      ),
                      if (isOwnProfile)
                        AppIconButton(
                          icon: Icons.edit_outlined,
                          variant: AppIconButtonVariant.glass,
                          onPressed: () => context.push('/edit-profile'),
                        ),
                    ],
                  ),
                ),
                if (!isOwnProfile &&
                    targetId != null &&
                    profileProvider.isLoading(targetId))
                  Padding(
                    padding: AppSpacing.screenPadding,
                    child:
                        const LinearProgressIndicator(color: AppColors.primary),
                  ),
                if (!isOwnProfile &&
                    profileProvider.error(targetId) != null &&
                    _shouldShowProfileFallback(user))
                  Padding(
                    padding: AppSpacing.screenPadding,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceBright,
                        borderRadius: AppDecorations.borderRadiusMd,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Perfil em modo parcial. Alguns dados podem não aparecer em todos os campos.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.refresh_rounded,
                                color: AppColors.primary),
                            onPressed: () => _refreshProfile(),
                          ),
                        ],
                      ),
                    ),
                  ),
                AppSpacing.verticalXl,
                _ProfileHeader(user: user)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1)),
                AppSpacing.verticalXxl,
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
                if (isOwnProfile) ...[
                  Padding(
                    padding: AppSpacing.screenPadding,
                    child: _LevelProgress(
                      currentLevel: user.skillLevel,
                      progress: 0.7, // TODO: Calculate actual progress
                      pointsToNext: 8,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
                  AppSpacing.verticalXxl,
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
                            _MenuItem(
                              icon: Icons.leaderboard_rounded,
                              label: 'Meu Ranking',
                              onTap: () => context.push('/rankings'),
                            ),
                            _MenuItem(
                              icon: Icons.history_rounded,
                              label: 'Histórico de Jogos',
                              onTap: () => {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
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
                              onTap: () => context.push('/notifications'),
                            ),
                            _MenuItem(
                              icon: Icons.settings_outlined,
                              label: 'Definições',
                              onTap: () => {},
                            ),
                            _MenuItem(
                              icon: Icons.help_outline_rounded,
                              label: 'Ajuda & Suporte',
                              onTap: () => {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 250.ms),
                  AppSpacing.verticalXl,
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
                  ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                ],
                if (!isOwnProfile)
                  Padding(
                    padding: AppSpacing.screenPadding,
                    child: Text(
                      'Perfil público — em modo consulta. As ações de edição e conta são para o teu próprio perfil.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowProfileFallback(User user) {
    return user.email.isEmpty &&
        user.matchesPlayed == 0 &&
        user.matchesWon == 0;
  }

  User _userFromAuthor(PostAuthor author, String fallbackId) {
    final name = author.name?.trim() ?? '';
    final parts =
        name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();

    return User(
      id: author.id.isNotEmpty ? author.id : fallbackId,
      email: '',
      firstName: parts.isNotEmpty ? parts.first : null,
      lastName: parts.length > 1 ? parts.sublist(1).join(' ') : null,
      avatarUrl: author.avatarUrl,
      city: author.city,
      skillLevel: author.skillLevel ?? 'BEGINNER',
      reputationScore: author.reputation ?? 0,
      availabilityStatus: author.availabilityStatus,
      reputationSignals: 0,
      matchesPlayed: 0,
      matchesWon: 0,
      totalPoints: 0,
      roles: const [],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final availabilityLabel = availabilityStatusLabel(user.availabilityStatus);
    return Padding(
      padding: AppSpacing.screenPadding,
      child: GradientCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: AppDecorations.shadowGlow(AppColors.primary,
                    intensity: 0.3),
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
            Text(
              user.fullName.isNotEmpty ? user.fullName : user.email,
              style: AppTypography.h2,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSm,
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
            if (availabilityLabel != null) ...[
              AppSpacing.verticalMd,
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: _availabilityStatusColor(user.availabilityStatus)
                      .withOpacity(0.12),
                  borderRadius: AppDecorations.borderRadiusFull,
                  border: Border.all(
                    color: _availabilityStatusColor(user.availabilityStatus),
                  ),
                ),
                child: Text(
                  'Estado: $availabilityLabel',
                  style: AppTypography.labelSmall.copyWith(
                    color: _availabilityStatusColor(user.availabilityStatus),
                  ),
                ),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
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
            if (user.reputationSignals > 0 || user.reputationScore > 0) ...[
              AppSpacing.verticalMd,
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBright,
                  borderRadius: AppDecorations.borderRadiusFull,
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_rounded,
                        color: AppColors.info, size: 16),
                    AppSpacing.horizontalSm,
                    Text(
                      '${user.reputationText} • ${user.reputationSignals} votos',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
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

Color _availabilityStatusColor(String? status) {
  final canonical = canonicalAvailabilityStatus(status);
  switch (canonical) {
    case 'a_jogar':
      return AppColors.success;
    case 'a_procurar_parceiro':
      return AppColors.warning;
    case 'offline':
      return AppColors.textMuted;
    case 'busy':
      return AppColors.error;
    default:
      return AppColors.primary;
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
                '$pointsToNext vitórias para o próximo nível',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          AppSpacing.verticalLg,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
