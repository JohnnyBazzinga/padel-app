import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/rankings_provider.dart';
import '../../../shared/widgets/widgets.dart';

class RankingsScreen extends StatefulWidget {
  const RankingsScreen({super.key});

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _cityFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final auth = context.read<AuthProvider>();
    final provider = context.read<RankingsProvider>();

    _cityFilter = auth.user?.city;
    _loadTabData(0, provider: provider, force: true);
    provider.fetchMyRanking();
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      _loadTabData(_tabController.index);
    }
  }

  void _loadTabData(
    int index, {
    RankingsProvider? provider,
    bool force = false,
  }) {
    final rankingProvider = provider ?? context.read<RankingsProvider>();
    if (!force && rankingProvider.isLoading) return;

    switch (index) {
      case 1:
        rankingProvider.fetchEloRankings(city: _cityFilter);
        break;
      default:
        rankingProvider.fetchRankings();
        break;
    }
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

            if (provider.myRanking != null)
              Padding(
                padding: AppSpacing.screenPadding,
                child: _MyRankingCard(
                  position: provider.myRanking!.position ?? 0,
                  points: provider.myRanking!.points,
                  tier: provider.myRanking!.tier ?? 'BRONZE',
                  wins: provider.myRanking!.matchesWon,
                  losses: provider.myRanking!.matchesPlayed - provider.myRanking!.matchesWon,
                  reputation: provider.myRanking!.reputationScore,
                  reputationLabel: provider.myRanking!.reputationLabel,
                  reputationSignals: provider.myRanking!.reputationSignals,
                ),
              ).animate().fadeIn(duration: 320.ms).slideY(begin: -0.06, end: 0),
            AppSpacing.verticalLg,

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
                dividerColor: Colors.transparent,
                labelColor: AppColors.background,
                unselectedLabelColor: AppColors.textMuted,
                tabs: const [
                  Tab(text: 'Global'),
                  Tab(text: 'Cidade'),
                ],
              ),
            ),
            AppSpacing.verticalLg,
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _RankingsList(
                    provider: provider,
                    fallbackTitle: 'Global',
                  ),
                  _RankingsList(
                    provider: provider,
                    fallbackTitle: 'Cidade',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _loadTabData(_tabController.index, provider: provider);
        },
        tooltip: 'Atualizar',
        child: const Icon(Icons.refresh_rounded),
      ),
    );
  }

  void _showRankingInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDecorations.radiusXl)),
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
  final double reputation;
  final String? reputationLabel;
  final int reputationSignals;

  const _MyRankingCard({
    required this.position,
    required this.points,
    required this.tier,
    required this.wins,
    required this.losses,
    required this.reputation,
    required this.reputationLabel,
    required this.reputationSignals,
  });

  @override
  Widget build(BuildContext context) {
    final total = wins + losses;
    final winRate = total == 0 ? 0 : ((wins / total) * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.borderRadiusXl,
        boxShadow: AppDecorations.shadowGlow(AppColors.primary, intensity: 0.25),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBright,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Center(
                  child: Text(
                    '#$position',
                    style: AppTypography.h3,
                  ),
                ),
              ),
              AppSpacing.horizontalLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('A tua posição', style: AppTypography.labelSmall),
                    AppSpacing.verticalXs,
                    Row(
                      children: [
                        Text('$points', style: AppTypography.h2),
                        const SizedBox(width: 4),
                        Text('pontos', style: AppTypography.labelSmall),
                      ],
                    ),
                  ],
                ),
              ),
              _TierBadge(tier: tier, position: position),
            ],
          ),
          AppSpacing.verticalLg,
          Row(
            children: [
              Expanded(
                child: _StatItem(label: 'Vitórias', value: '$wins', color: AppColors.success),
              ),
              Expanded(
                child: _StatItem(label: 'Derrotas', value: '$losses', color: AppColors.error),
              ),
              Expanded(
                child: _StatItem(label: 'Taxa', value: '$winRate%', color: AppColors.warning),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Reputação',
                  value: _reputationText(),
                  color: AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _reputationText() {
    if (reputation <= 0) return 'Sem dados';
    final base = reputation.toStringAsFixed(0);
    final label = _resolveReputationLabel();
    if (reputationSignals <= 0) return '$label • $base';
    return '$label • $base • $reputationSignals votos';
  }

  String _resolveReputationLabel() {
    if (reputationLabel != null && reputationLabel!.trim().isNotEmpty) {
      return reputationLabel!;
    }
    if (reputation >= 90) return 'Top';
    if (reputation >= 75) return 'Confiavel';
    if (reputation >= 55) return 'Regular';
    return 'Nova Conta';
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
          style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
        ),
        AppSpacing.verticalXxs,
        Text(label, style: AppTypography.caption.copyWith(color: color)),
      ],
    );
  }
}

class _TierBadge extends StatelessWidget {
  final String tier;
  final int position;

  const _TierBadge({
    required this.tier,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getRankColor(tier);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppDecorations.borderRadiusFull,
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events_rounded,
            size: 16,
            color: color,
          ),
          AppSpacing.horizontalSm,
          Text(
            tier,
            style: AppTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RankingsList extends StatelessWidget {
  final RankingsProvider provider;
  final String fallbackTitle;

  const _RankingsList({
    required this.provider,
    required this.fallbackTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading) {
      return ListView(
        padding: AppSpacing.screenPadding,
        children: const [
          SkeletonListItem(),
          AppSpacing.verticalMd,
          SkeletonListItem(),
        ],
      );
    }

    if (provider.rankings.isEmpty) {
      return ListView(
        padding: AppSpacing.screenPadding,
        children: [
          EmptyState(
            icon: Icons.leaderboard_outlined,
            title: 'Sem dados em $fallbackTitle',
            message: 'Ainda não há ranking disponível.',
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: provider.rankings.length,
      itemBuilder: (context, index) {
        final ranking = provider.rankings[index];
        final position = ranking.position ?? index + 1;
        return _RankingRow(
          position: position,
          name: ranking.userName,
          avatarUrl: ranking.userAvatar,
          points: ranking.points,
          wins: ranking.matchesWon,
          losses: ranking.matchesPlayed - ranking.matchesWon,
          reputation: ranking.reputationScore,
          reputationLabel: ranking.reputationLabel,
          reputationSignals: ranking.reputationSignals,
          isTop3: position <= 3,
        )
            .animate()
            .fadeIn(duration: 220.ms, delay: (index * 20).ms)
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
  final double reputation;
  final String? reputationLabel;
  final int reputationSignals;
  final bool isTop3;

  const _RankingRow({
    required this.position,
    required this.name,
    this.avatarUrl,
    required this.points,
    required this.wins,
    required this.losses,
    required this.reputation,
    required this.reputationLabel,
    required this.reputationSignals,
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
        border: Border.all(
          color: isTop3 ? positionColor.withValues(alpha: 0.5) : AppColors.glassBorder,
          width: isTop3 ? 1.2 : 1,
        ),
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isTop3 ? positionColor : AppColors.surfaceBright,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isTop3
                        ? const Icon(Icons.emoji_events_rounded, color: AppColors.background, size: 20)
                        : Text(
                            '$position',
                            style: AppTypography.labelLarge,
                          ),
                  ),
                ),
                AppSpacing.horizontalMd,
                UserAvatar(
                  imageUrl: avatarUrl,
                  name: name,
                  size: 40,
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTypography.labelLarge),
                      AppSpacing.verticalXxs,
                      Row(
                        children: [
                          Text('$wins', style: AppTypography.labelSmall.copyWith(color: AppColors.success)),
                          Text('V ', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                          Text('$losses', style: AppTypography.labelSmall.copyWith(color: AppColors.error)),
                          Text('D', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                          AppSpacing.horizontalMd,
                          Text(
                            'Rep ${_resolveReputationLabel()} • ${reputation.toStringAsFixed(0)}${reputationSignals > 0 ? " • $reputationSignals votos" : ""}',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.info),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$points',
                      style: AppTypography.h4.copyWith(color: AppColors.primary),
                    ),
                    Text(
                      'pts',
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
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
    if (position == 1) return AppColors.gold;
    if (position == 2) return AppColors.silver;
    if (position == 3) return AppColors.bronze;
    return AppColors.surfaceBright;
  }

  String _resolveReputationLabel() {
    if (reputationLabel != null && reputationLabel!.trim().isNotEmpty) {
      return reputationLabel!;
    }
    if (reputation >= 90) return 'Top';
    if (reputation >= 75) return 'Confiavel';
    if (reputation >= 55) return 'Regular';
    return 'Nova Conta';
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
          Text('Como funciona', style: AppTypography.h2),
          AppSpacing.verticalLg,
          _InfoRow(
            icon: Icons.emoji_events_rounded,
            title: 'Ganhar pontos',
            description: 'Pontos acumulados por vitórias e nível dos adversários.',
          ),
          AppSpacing.verticalMd,
          _InfoRow(
            icon: Icons.trending_up_rounded,
            title: 'Reputação',
            description:
                'O perfil social adiciona reputação calculada por punctuality, fair play e social.',
          ),
          AppSpacing.verticalMd,
          _InfoRow(
            icon: Icons.calendar_month_rounded,
            title: 'ELO',
            description:
                'A opção ELO usa score de confiança da tua performance para atualização de ranking.',
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
          child: Icon(icon, size: 18, color: AppColors.primary),
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
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
