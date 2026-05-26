import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/matches_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/widgets.dart';

class MatchDetailScreen extends StatefulWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MatchesProvider>().fetchMatchById(widget.matchId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchesProvider>();
    final auth = context.watch<AuthProvider>();
    final match = provider.selectedMatch;

    if (provider.isLoading || match == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final isParticipant = match.players.any((p) => p.userId == auth.user?.id);
    final isOrganizer = match.players.any((p) => p.userId == auth.user?.id && p.isOrganizer);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        titleWidget: const SizedBox.shrink(),
        transparent: true,
        showBackgroundLine: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: AppIconButton(
              icon: Icons.arrow_back_rounded,
              variant: AppIconButtonVariant.glass,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
          if (isOrganizer)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AppIconButton(
                icon: Icons.edit_outlined,
                variant: AppIconButtonVariant.glass,
                onPressed: () {},
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: AppIconButton(
              icon: Icons.share_outlined,
              variant: AppIconButtonVariant.glass,
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Header
            _HeroHeader(match: match),

            // Content
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.verticalXl,

                  // Quick Info Chips
                  _QuickInfoRow(match: match)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 100.ms)
                      .slideY(begin: 0.1, end: 0),

                  AppSpacing.verticalXxl,

                  // Location Section
                  _LocationSection(match: match)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 150.ms),

                  AppSpacing.verticalXxl,

                  // Team Section (2v2 visualization)
                  if (match.playersNeeded == 4)
                    _TeamSection(match: match)
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 200.ms)
                  else
                    _PlayersSection(match: match)
                        .animate()
                        .fadeIn(duration: 300.ms, delay: 200.ms),

                  AppSpacing.verticalXxl,

                  // Match Info
                  _MatchInfoSection(match: match)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 250.ms),

                  // Spacing for bottom button
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomActionBar(
        match: match,
        isParticipant: isParticipant,
        isOrganizer: isOrganizer,
        onJoin: () => provider.joinMatch(widget.matchId),
        onLeave: () => provider.leaveMatch(widget.matchId),
        onCancel: () async {
          await provider.cancelMatch(widget.matchId);
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final dynamic match;

  const _HeroHeader({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _PatternPainter(),
            ),
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.3),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Content
          Positioned(
            left: 20,
            right: 20,
            bottom: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status badge
                if (match.isFull)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: AppDecorations.borderRadiusFull,
                    ),
                    child: Text(
                      'COMPLETO',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: AppDecorations.borderRadiusFull,
                    ),
                    child: Text(
                      'ABERTO',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                AppSpacing.verticalMd,

                // Title
                Text(
                  match.title ?? 'Jogo de Padel',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.verticalXs,

                // Date & Time
                Text(
                  '${DateFormat('EEEE, d MMMM', 'pt_PT').format(match.date)} • ${match.startTime}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms);
  }
}

class _PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw subtle court lines pattern
    for (var i = 0; i < 5; i++) {
      canvas.drawLine(
        Offset(0, size.height * 0.2 * i),
        Offset(size.width, size.height * 0.2 * i + 50),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _QuickInfoRow extends StatelessWidget {
  final dynamic match;

  const _QuickInfoRow({required this.match});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickInfoCard(
            icon: Icons.people_rounded,
            value: '${match.currentPlayers}/${match.playersNeeded}',
            label: 'Jogadores',
            color: AppColors.primary,
          ),
        ),
        AppSpacing.horizontalMd,
        Expanded(
          child: _QuickInfoCard(
            icon: Icons.signal_cellular_alt_rounded,
            value: match.level ?? '${match.minLevel}',
            label: 'Nível',
            color: AppColors.accent,
          ),
        ),
        AppSpacing.horizontalMd,
        Expanded(
          child: _QuickInfoCard(
            icon: Icons.timer_outlined,
            value: '${match.duration ?? 90}',
            label: 'Minutos',
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _QuickInfoCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickInfoCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppDecorations.borderRadiusSm,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          AppSpacing.verticalSm,
          Text(
            value,
            style: AppTypography.h3.copyWith(color: color),
          ),
          AppSpacing.verticalXxs,
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  final dynamic match;

  const _LocationSection({required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Localização'),
        AppSpacing.verticalMd,
        GradientCard(
          onTap: () {
            // TODO: Open maps
          },
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: AppDecorations.borderRadiusMd,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              AppSpacing.horizontalLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.displayLocation,
                      style: AppTypography.h4,
                    ),
                    AppSpacing.verticalXxs,
                    Text(
                      match.city ?? 'Portugal',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBright,
                  borderRadius: AppDecorations.borderRadiusSm,
                ),
                child: const Icon(
                  Icons.directions_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamSection extends StatelessWidget {
  final dynamic match;

  const _TeamSection({required this.match});

  @override
  Widget build(BuildContext context) {
    final team1 = match.players.where((p) => p.team == 1).toList();
    final team2 = match.players.where((p) => p.team == 2).toList();
    final unassigned = match.players.where((p) => p.team == 0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Equipas'),
        AppSpacing.verticalMd,
        GradientCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Team 1
              Expanded(
                child: _TeamColumn(
                  teamName: 'Equipa A',
                  players: team1,
                  color: AppColors.info,
                  maxPlayers: 2,
                ),
              ),

              // VS
              Container(
                width: 50,
                height: 50,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppDecorations.shadowGlow(AppColors.accent, intensity: 0.3),
                ),
                child: Center(
                  child: Text(
                    'VS',
                    style: AppTypography.labelMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Team 2
              Expanded(
                child: _TeamColumn(
                  teamName: 'Equipa B',
                  players: team2,
                  color: AppColors.secondary,
                  maxPlayers: 2,
                ),
              ),
            ],
          ),
        ),

        if (unassigned.isNotEmpty) ...[
          AppSpacing.verticalLg,
          Text(
            'Sem equipa atribuída',
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          AppSpacing.verticalSm,
          ...unassigned.map((player) => _PlayerRow(player: player)),
        ],
      ],
    );
  }
}

class _TeamColumn extends StatelessWidget {
  final String teamName;
  final List<dynamic> players;
  final Color color;
  final int maxPlayers;

  const _TeamColumn({
    required this.teamName,
    required this.players,
    required this.color,
    required this.maxPlayers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: AppDecorations.borderRadiusFull,
          ),
          child: Text(
            teamName,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ),
        AppSpacing.verticalMd,
        ...List.generate(maxPlayers, (index) {
          if (index < players.length) {
            final player = players[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  UserAvatar(
                    imageUrl: player.user?.avatarUrl,
                    name: player.user?.fullName ?? 'Jogador',
                    size: 48,
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    player.user?.firstName ?? 'Jogador',
                    style: AppTypography.labelSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }
          // Empty slot
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBright,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.glassBorder,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ),
                AppSpacing.verticalXs,
                Text(
                  'Vago',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _PlayersSection extends StatelessWidget {
  final dynamic match;

  const _PlayersSection({required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Jogadores'),
        AppSpacing.verticalMd,
        ...match.players.map<Widget>((player) => _PlayerRow(player: player)).toList(),
        // Empty slots
        ...List.generate(
          match.playersNeeded - match.currentPlayers,
          (index) => _EmptySlot(),
        ),
      ],
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final dynamic player;

  const _PlayerRow({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: AppDecorations.gradientCard,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: AppDecorations.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                UserAvatar(
                  imageUrl: player.user?.avatarUrl,
                  name: player.user?.fullName ?? 'Jogador',
                  size: 44,
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.user?.fullName ?? 'Jogador',
                        style: AppTypography.labelLarge,
                      ),
                      if (player.isOrganizer)
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Organizador',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (player.team > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: player.team == 1
                          ? AppColors.info.withValues(alpha: 0.15)
                          : AppColors.secondary.withValues(alpha: 0.15),
                      borderRadius: AppDecorations.borderRadiusFull,
                    ),
                    child: Text(
                      'Equipa ${player.team == 1 ? "A" : "B"}',
                      style: AppTypography.labelSmall.copyWith(
                        color: player.team == 1 ? AppColors.info : AppColors.secondary,
                      ),
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

class _EmptySlot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: AppDecorations.borderRadiusMd,
        border: Border.all(
          color: AppColors.glassBorder,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceBright,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_add_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ),
          AppSpacing.horizontalMd,
          Text(
            'Lugar disponível',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchInfoSection extends StatelessWidget {
  final dynamic match;

  const _MatchInfoSection({required this.match});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Detalhes'),
        AppSpacing.verticalMd,
        GradientCard(
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.calendar_today_rounded,
                label: 'Data',
                value: DateFormat('EEEE, d MMMM yyyy', 'pt_PT').format(match.date),
              ),
              Divider(color: AppColors.glassBorder, height: 24),
              _InfoRow(
                icon: Icons.schedule_rounded,
                label: 'Horário',
                value: '${match.startTime} - ${match.endTime}',
              ),
              Divider(color: AppColors.glassBorder, height: 24),
              _InfoRow(
                icon: Icons.signal_cellular_alt_rounded,
                label: 'Nível',
                value: '${match.minLevel} - ${match.maxLevel}',
              ),
              if (match.notes != null && match.notes!.isNotEmpty) ...[
                Divider(color: AppColors.glassBorder, height: 24),
                _InfoRow(
                  icon: Icons.notes_rounded,
                  label: 'Notas',
                  value: match.notes!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        AppSpacing.horizontalMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              AppSpacing.verticalXxs,
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final dynamic match;
  final bool isParticipant;
  final bool isOrganizer;
  final VoidCallback onJoin;
  final VoidCallback onLeave;
  final VoidCallback onCancel;

  const _BottomActionBar({
    required this.match,
    required this.isParticipant,
    required this.isOrganizer,
    required this.onJoin,
    required this.onLeave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.glassBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: _buildButton(),
      ),
    );
  }

  Widget _buildButton() {
    if (isParticipant) {
      if (isOrganizer) {
        return GhostButton(
          label: 'Cancelar Jogo',
          icon: Icons.cancel_outlined,
          color: AppColors.error,
          onPressed: onCancel,
        );
      }
      return GhostButton(
        label: 'Sair do Jogo',
        icon: Icons.exit_to_app_rounded,
        color: AppColors.error,
        onPressed: onLeave,
      );
    }

    if (match.isFull) {
      return SecondaryButton(
        label: 'Jogo Completo',
        icon: Icons.block_rounded,
        onPressed: null,
      );
    }

    return PrimaryButton(
      label: 'Entrar no Jogo',
      icon: Icons.login_rounded,
      onPressed: onJoin,
    );
  }
}
