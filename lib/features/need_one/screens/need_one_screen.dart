import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/models/match_suggestion.dart';
import '../../../shared/providers/matches_provider.dart';
import '../../../shared/widgets/widgets.dart';

class NeedOneScreen extends StatefulWidget {
  const NeedOneScreen({super.key});

  @override
  State<NeedOneScreen> createState() => _NeedOneScreenState();
}

class _NeedOneScreenState extends State<NeedOneScreen> {
  final List<String> _cities = const ['Lisboa', 'Madrid', 'Sao Paulo', 'Barcelona', 'Dubai'];
  String _selectedCity = 'Lisboa';

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    await context.read<MatchesProvider>().fetchMatchSuggestions(
          city: _selectedCity,
          minPlayersNeeded: 1,
          maxPlayersNeeded: 4,
        );
  }

  Future<void> _onJoinNow(MatchSuggestion suggestion) async {
    final provider = context.read<MatchesProvider>();
    final match = await provider.createAutoFill(suggestionId: suggestion.id, premium: false);

    if (!mounted) return;
    if (match != null) {
      context.push('/matches/${match.id}');
      return;
    }

    final success = await provider.createFillFallback(suggestion: suggestion, premium: false);
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível entrar na partida')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entraste na partida')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MatchesProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.screenPadding,
              child: Row(
                children: [
                  Expanded(
                    child: Text('Need 1 Now', style: AppTypography.h1),
                  ),
                  AppIconButton(
                    icon: Icons.location_on_rounded,
                    variant: AppIconButtonVariant.glass,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            Padding(
              padding: AppSpacing.screenPadding,
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _cities.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final city = _cities[index];
                    final selected = city == _selectedCity;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedCity = city);
                        _load();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.surface,
                          borderRadius: AppDecorations.borderRadiusFull,
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: Text(
                          city,
                          style: AppTypography.labelSmall.copyWith(
                            color: selected ? AppColors.background : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            AppSpacing.verticalMd,
            if (provider.isSuggesting)
              const Expanded(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (provider.suggestions.isEmpty)
              Expanded(
                child: ListView(
                  padding: AppSpacing.screenPadding,
                  children: [
                    EmptyState(
                      icon: Icons.person_search_rounded,
                      title: 'Sem parceiros em tempo real',
                      message:
                          'Ainda não há sugestões para a cidade selecionada. Cria uma partida ou abre o feed de Match.',
                      actionLabel: 'Ver partidas',
                      onAction: () => context.push('/search'),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    itemCount: provider.suggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final suggestion = provider.suggestions[index];
                      return _NeedOneCard(
                        suggestion: suggestion,
                        onAction: () => _onJoinNow(suggestion),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NeedOneCard extends StatelessWidget {
  final MatchSuggestion suggestion;
  final VoidCallback onAction;

  const _NeedOneCard({
    required this.suggestion,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = suggestion.date == null
        ? 'Data por confirmar'
        : DateFormat('EEE, dd MMM • HH:mm', 'pt_PT').format(suggestion.date!);
    final city = suggestion.city ?? 'Cidade';
    final spots = suggestion.spotsLeft < 0 ? 0 : suggestion.spotsLeft;
    final level = '${suggestion.minLevel ?? 'BEGINNER'} - ${suggestion.maxLevel ?? 'PROFESSIONAL'}';

    return Container(
      decoration: AppDecorations.gradientCard,
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Need 1', style: AppTypography.labelLarge.copyWith(color: AppColors.error)),
                AppSpacing.horizontalSm,
                Expanded(
                  child: Text(
                    suggestion.title ?? 'Partida',
                    style: AppTypography.h4,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSm,
            Text(
              '$city • $dateLabel',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            AppSpacing.verticalSm,
            Text(level, style: AppTypography.bodyMedium),
            AppSpacing.verticalMd,
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBright,
                    borderRadius: AppDecorations.borderRadiusFull,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'Vaga: $spots/${suggestion.playersNeeded}',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary),
                  ),
                ),
                AppSpacing.horizontalSm,
                if (suggestion.confidence != null)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: AppDecorations.borderRadiusFull,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      '${(suggestion.confidence! * 100).toStringAsFixed(0)}% match',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.accent),
                    ),
                  ),
                const Spacer(),
                PrimaryButton(label: 'Entrar Agora', onPressed: onAction, isExpanded: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
