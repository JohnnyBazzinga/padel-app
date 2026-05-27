import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/rankings_provider.dart';
import '../../../shared/widgets/widgets.dart';

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final provider = context.read<RankingsProvider>();
    provider.fetchRankings();
    provider.fetchMyRanking();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RankingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: AppSpacing.screenPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ranking', style: AppTypography.h1),
                  AppIconButton(
                    icon: Icons.info_outline_rounded,
                    variant: AppIconButtonVariant.glass,
                    onPressed: () => _showRankingInfo(context),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalLg,

            // My Ranking Card
            if (provider.myRanking != null)
              Padding(
                padding: AppSpacing.screenPadding,
                child: _MyRankingCard(
                  position: provider.myRanking!.position ?? 0,
                  points: provider.myRanking!.points,
                  tier: provider.myRanking!.tier ?? 'BRONZE',
                  wins: provider.myRanking!.matchesWon,
                  losses: provider.myRanking!.matchesPlayed - provider.myRanking!.matchesWon,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.1, end: 0),
            AppSpacing.verticalLg,

            // Tab Bar
            Container(
              margin: AppSpacing.screenPadding,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: AppDecorations.borderRadiusFull,
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: AppDecorations.borderRadiusFull,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: AppColors.background,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: AppTypography.labelMedium,
                tabs: const [
                  Tab(text: 'Global'),
                  Tab(text: 'Cidade'),
                  Tab(text: 'Amigos'),
                ],
              ),
            ),
            AppSpacing.verticalLg,

            // Rankings List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _RankingsList(provider: provider),
                  _RankingsList(provider: provider), // TODO: City rankings
                  _RankingsList(provider: provider), // TODO: Friends rankings
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRankingInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDecorations.radiusXl),
        ),
      ),
      builder: (context) => _RankingInfoSheet(),
    );
  }
}

class _MyRankingCard extends StatelessWidget {
  final int position;
  final int points;
  final String tier;
  final int wins;
  final int losses;

  const _MyRankingCard({
    required this.position,
    required this.points,
    required this.tier,
    required this.wins,
    required this.losses,
  });

  @override
  Widget build(BuildContext context) {
    final tierColor = AppColors.getRankColor(tier);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.borderRadiusXl,
        boxShadow: AppDecorations.shadowGlow(AppColors.primary, intensity: 0.3),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Position
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: AppColors.surfaceBright,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '#$position',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.horizontalLg,

              // Points & Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A tua posição',
                      style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                      ),
                    ),
                    AppSpacing.verticalXs,
                    Row(
                      children: [
                        Text(
                          '$points',
                          style: AppTypography.statNumberLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'pontos',
                          style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tier Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: tierColor,
                  borderRadius: AppDecorations.borderRadiusFull,
                  boxShadow: AppDecorations.shadowGlow(tierColor, intensity: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getTierIcon(tier),
                      size: 16,
                      color: _getTierTextColor(tier),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _getTierLabel(tier),
                      style: AppTypography.labelMedium.copyWith(
                        color: _getTierTextColor(tier),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.verticalLg,

          // Stats Row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceBright,
              borderRadius: AppDecorations.borderRadiusMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Vitórias',
                  value: '$wins',
                  color: AppColors.success,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.surfaceBright,
                ),
                _StatItem(
                  label: 'Derrotas',
                  value: '$losses',
                  color: AppColors.error,
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.surfaceBright,
                ),
                _StatItem(
                  label: 'Win Rate',
                  value: wins + losses > 0
                      ? '${((wins / (wins + losses)) * 100).toStringAsFixed(0)}%'
                      : '0%',
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTierIcon(String tier) {
    switch (tier.toUpperCase()) {
      case 'DIAMOND':
        return Icons.diamond_rounded;
      case 'PLATINUM':
        return Icons.workspace_premium_rounded;
      case 'GOLD':
        return Icons.emoji_events_rounded;
      case 'SILVER':
        return Icons.military_tech_rounded;
      default:
        return Icons.shield_rounded;
    }
  }

  String _getTierLabel(String tier) {
    switch (tier.toUpperCase()) {
      case 'DIAMOND':
        return 'Diamante';
      case 'PLATINUM':
        return 'Platina';
      case 'GOLD':
        return 'Ouro';
      case 'SILVER':
        return 'Prata';
      default:
        return 'Bronze';
    }
  }

  Color _getTierTextColor(String tier) {
    switch (tier.toUpperCase()) {
      case 'DIAMOND':
      case 'PLATINUM':
      case 'SILVER':
        return Colors.black87;
      default:
        return AppColors.textPrimary;
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        AppSpacing.verticalXxs,
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RankingsList extends StatelessWidget {
  final RankingsProvider provider;

  const _RankingsList({required this.provider});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return ListView(
        padding: AppSpacing.screenPadding,
        children: List.generate(
          5,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SkeletonListItem(),
          ),
        ),
      );
    }

    if (provider.rankings.isEmpty) {
      return const EmptyState(
        icon: Icons.leaderboard_rounded,
        title: 'Sem rankings',
        message: 'Ainda não há dados de ranking disponíveis.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: provider.rankings.length,
      itemBuilder: (context, index) {
        final ranking = provider.rankings[index];
        final position = ranking.position ?? index + 1;
        final isTop3 = position <= 3;

        return _RankingRow(
          position: position,
          name: ranking.userName,
          avatarUrl: ranking.userAvatar,
          points: ranking.points,
          wins: ranking.matchesWon,
          losses: ranking.matchesPlayed - ranking.matchesWon,
          isTop3: isTop3,
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 30).ms)
            .slideX(begin: 0.05, end: 0);
      },
    );
  }
}

class _RankingRow extends StatelessWidget {
  final int position;
  final String name;
  final String? avatarUrl;
  final int points;
  final int wins;
  final int losses;
  final bool isTop3;

  const _RankingRow({
    required this.position,
    required this.name,
    this.avatarUrl,
    required this.points,
    required this.wins,
    required this.losses,
    this.isTop3 = false,
  });

  @override
  Widget build(BuildContext context) {
    final positionColor = _getPositionColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.borderRadiusMd,
        border: isTop3
            ? Border.all(color: positionColor.withValues(alpha: 0.5), width: 1.5)
            : Border.all(color: AppColors.glassBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: AppDecorations.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Position
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isTop3 ? positionColor : AppColors.surfaceBright,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isTop3
                        ? Icon(
                            Icons.emoji_events_rounded,
                            color: position == 1
                                ? Colors.amber.shade900
                                : position == 2
                                    ? Colors.grey.shade800
                                    : Colors.brown.shade800,
                            size: 20,
                          )
                        : Text(
                            '$position',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                  ),
                ),
                AppSpacing.horizontalMd,

                // Avatar
                UserAvatar(
                  imageUrl: avatarUrl,
                  name: name,
                  size: 40,
                ),
                AppSpacing.horizontalMd,

                // Name & Record
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppSpacing.verticalXxs,
                      Row(
                        children: [
                          Text(
                            '$wins',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            'V ',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            '$losses',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          Text(
                            'D',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Points
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$points',
                      style: AppTypography.h4.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'pts',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
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

  Color _getPositionColor() {
    switch (position) {
      case 1:
        return AppColors.gold;
      case 2:
        return AppColors.silver;
      case 3:
        return AppColors.bronze;
      default:
        return AppColors.surfaceBright;
    }
  }
}

class _RankingInfoSheet extends StatelessWidget {
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

          Text('Como funciona o Ranking', style: AppTypography.h2),
          AppSpacing.verticalLg,

          _InfoRow(
            icon: Icons.emoji_events_rounded,
            title: 'Ganhar Pontos',
            description: 'Ganha pontos ao vencer jogos. Quanto maior o nível do adversário, mais pontos ganhas.',
          ),
          AppSpacing.verticalMd,
          _InfoRow(
            icon: Icons.trending_up_rounded,
            title: 'Subir de Tier',
            description: 'Ao acumulares pontos, sobes de Bronze até Diamante.',
          ),
          AppSpacing.verticalMd,
          _InfoRow(
            icon: Icons.calendar_month_rounded,
            title: 'Reset Sazonal',
            description: 'O ranking é resetado a cada 3 meses. Mantém a consistência!',
          ),

          AppSpacing.verticalXxl,

          SecondaryButton(
            label: 'Entendi',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryMuted,
            borderRadius: AppDecorations.borderRadiusSm,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        AppSpacing.horizontalMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.labelLarge),
              AppSpacing.verticalXxs,
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
