import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/matches_provider.dart';
import '../../../shared/widgets/widgets.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    context.read<MatchesProvider>().fetchMatches();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchesProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: AppSpacing.screenPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Encontrar Jogo', style: AppTypography.h1),
                      AppSpacing.verticalXs,
                      Text(
                        '${provider.matches.length} jogos disponíveis',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  AppIconButton(
                    icon: Icons.tune_rounded,
                    variant: AppIconButtonVariant.glass,
                    onPressed: () => _showFilterSheet(context),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalLg,

            // Filter Chips
            FilterChipGroup(
              options: const ['Todos', 'Hoje', 'Amanhã', 'Esta Semana'],
              selected: _selectedFilter,
              onSelected: (filter) {
                setState(() => _selectedFilter = filter);
              },
            ),
            AppSpacing.verticalLg,

            // Match List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.fetchMatches(),
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: provider.isLoading
                    ? _buildLoadingState()
                    : provider.matches.isEmpty
                        ? _buildEmptyState()
                        : _buildMatchList(provider),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _CreateMatchFAB(
        onPressed: () => context.push('/create-match'),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: const [
        SkeletonMatchCard(),
        SkeletonMatchCard(),
        SkeletonMatchCard(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.sports_tennis_rounded,
      title: 'Sem jogos disponíveis',
      message: 'Não encontramos jogos para os filtros selecionados. Cria o teu próprio jogo!',
      actionLabel: 'Criar Jogo',
      onAction: () => context.push('/create-match'),
    );
  }

  Widget _buildMatchList(MatchesProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: provider.matches.length,
      itemBuilder: (context, index) {
        final match = provider.matches[index];
        return _MatchCard(
          title: match.title ?? 'Jogo de Padel',
          location: match.displayLocation,
          date: DateFormat('EEE, d MMM', 'pt_PT').format(match.date),
          time: '${match.startTime} - ${match.endTime}',
          level: '${match.minLevel} - ${match.maxLevel}',
          currentPlayers: match.currentPlayers,
          maxPlayers: match.playersNeeded,
          organizerName: match.players.where((p) => p.isOrganizer).firstOrNull?.user?.firstName ?? 'Anónimo',
          onTap: () => context.push('/matches/${match.id}'),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .slideX(begin: 0.05, end: 0);
      },
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDecorations.radiusXl),
        ),
      ),
      builder: (context) => _FilterSheet(),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final String title;
  final String location;
  final String date;
  final String time;
  final String level;
  final int currentPlayers;
  final int maxPlayers;
  final String organizerName;
  final VoidCallback onTap;

  const _MatchCard({
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.level,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.organizerName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isFull = currentPlayers >= maxPlayers;
    final spotsLeft = maxPlayers - currentPlayers;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: AppDecorations.borderRadiusLg,
        border: Border.all(
          color: isFull
              ? AppColors.warning.withOpacity(0.3)
              : AppColors.glassBorder,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDecorations.borderRadiusLg,
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Title + Players badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.h3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppSpacing.verticalXs,
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.horizontalMd,
                    _PlayersBadge(
                      current: currentPlayers,
                      max: maxPlayers,
                      isFull: isFull,
                    ),
                  ],
                ),
                AppSpacing.verticalLg,

                // Date, Time, Level chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoChip(
                      icon: Icons.calendar_today_rounded,
                      label: date,
                    ),
                    InfoChip(
                      icon: Icons.access_time_rounded,
                      label: time,
                    ),
                    _LevelChip(level: level),
                  ],
                ),
                AppSpacing.verticalLg,

                // Divider
                Container(
                  height: 1,
                  color: AppColors.glassBorder,
                ),
                AppSpacing.verticalLg,

                // Bottom row: Organizer + Action
                Row(
                  children: [
                    UserAvatar(
                      name: organizerName,
                      size: 32,
                    ),
                    AppSpacing.horizontalSm,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Organizado por',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          organizerName,
                          style: AppTypography.labelMedium,
                        ),
                      ],
                    ),
                    const Spacer(),
                    if (!isFull)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: AppDecorations.borderRadiusFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Entrar',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.background,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: AppColors.background,
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.15),
                          borderRadius: AppDecorations.borderRadiusFull,
                        ),
                        child: Text(
                          'Completo',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayersBadge extends StatelessWidget {
  final int current;
  final int max;
  final bool isFull;

  const _PlayersBadge({
    required this.current,
    required this.max,
    required this.isFull,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFull
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.primaryMuted,
        borderRadius: AppDecorations.borderRadiusMd,
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(max, (index) {
              final isFilled = index < current;
              return Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.only(right: index < max - 1 ? 4 : 0),
                decoration: BoxDecoration(
                  color: isFilled
                      ? (isFull ? AppColors.warning : AppColors.primary)
                      : AppColors.surfaceBright,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          AppSpacing.verticalXs,
          Text(
            '$current/$max',
            style: AppTypography.labelSmall.copyWith(
              color: isFull ? AppColors.warning : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String level;

  const _LevelChip({required this.level});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getSkillColor(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: AppDecorations.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.signal_cellular_alt_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            level,
            style: AppTypography.labelSmall.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateMatchFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateMatchFAB({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 80),
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: AppDecorations.borderRadiusMd,
        boxShadow: AppDecorations.shadowGlow(AppColors.accent),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppDecorations.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Criar Jogo',
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(begin: 0.5, end: 0);
  }
}

class _FilterSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted,
                borderRadius: AppDecorations.borderRadiusFull,
              ),
            ),
          ),
          AppSpacing.verticalXl,

          Text('Filtrar Jogos', style: AppTypography.h2),
          AppSpacing.verticalXl,

          Text(
            'Nível',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.verticalMd,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SelectableChip(label: 'Todos', isSelected: true, onTap: () {}),
              SelectableChip(label: 'Iniciante', onTap: () {}),
              SelectableChip(label: 'Intermédio', onTap: () {}),
              SelectableChip(label: 'Avançado', onTap: () {}),
            ],
          ),
          AppSpacing.verticalXl,

          Text(
            'Disponibilidade',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.verticalMd,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SelectableChip(label: 'Com vagas', isSelected: true, onTap: () {}),
              SelectableChip(label: 'Completos', onTap: () {}),
            ],
          ),
          AppSpacing.verticalXxl,

          PrimaryButton(
            label: 'Aplicar Filtros',
            onPressed: () => Navigator.pop(context),
          ),
          AppSpacing.verticalLg,
        ],
      ),
    );
  }
}
