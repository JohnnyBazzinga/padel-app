import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/models/match_suggestion.dart';
import '../../../shared/providers/matches_provider.dart';
import '../../../shared/widgets/widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _search = TextEditingController();
  final List<String> _cities = const [
    'Todas',
    'Lisboa',
    'Madrid',
    'Sao Paulo',
    'Barcelona',
    'Dubai',
  ];
  String _selectedCity = 'Todas';
  bool _needOneOnly = true;
  bool _advancedMode = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchDiscovery());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _fetchDiscovery() async {
    await context.read<MatchesProvider>().fetchMatchSuggestions(
          city: _selectedCity == 'Todas' ? null : _selectedCity,
          level: null,
          minPlayersNeeded: _needOneOnly ? 1 : null,
        );
  }

  Future<void> _onAutoFill(MatchSuggestion suggestion) async {
    final provider = context.read<MatchesProvider>();
    final match = await provider.createAutoFill(suggestionId: suggestion.id);
    if (!mounted) return;

    if (match != null) {
      context.push('/matches/${match.id}');
      return;
    }

    final fallback = await provider.createFillFallback(suggestion: suggestion);
    if (!mounted) return;

    if (fallback) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entraste na partida com sucesso')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível entrar na partida')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final matches = context.watch<MatchesProvider>();
    final suggestions = matches.suggestions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: AppSpacing.screenPadding,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SearchField(
                          controller: _search,
                          hint: 'Pesquisar por jogador, nível ou clube',
                          onSubmitted: (_) => _fetchDiscovery(),
                        ),
                      ),
                      AppSpacing.horizontalSm,
                      AppIconButton(
                        icon: Icons.tune_rounded,
                        variant: AppIconButtonVariant.glass,
                        onPressed: () => setState(() => _advancedMode = !_advancedMode),
                      ),
                    ],
                  ),
                  AppSpacing.verticalMd,
                  SizedBox(
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
                            _fetchDiscovery();
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
                  AppSpacing.verticalMd,
                  Row(
                    children: [
                      Switch.adaptive(
                        value: _needOneOnly,
                        onChanged: (value) {
                          setState(() => _needOneOnly = value);
                          _fetchDiscovery();
                        },
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Apenas "Need 1 now"',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (matches.suggestionError != null)
              Padding(
                padding: AppSpacing.screenPadding,
                child: EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'Sem resultados',
                  message: matches.suggestionError!,
                  actionLabel: 'Tentar novamente',
                  onAction: _fetchDiscovery,
                ),
              )
            else if (matches.isSuggesting)
              const Expanded(
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchDiscovery,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  child: suggestions.isEmpty
                      ? ListView(
                          padding: AppSpacing.screenPadding,
                          children: const [
                            EmptyState(
                              icon: Icons.sports_tennis_outlined,
                              title: 'Sem partidas sugeridas',
                              message:
                                  'Não encontrei sugestões para estes filtros. Ajusta a cidade ou abre Need 1 now.',
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: suggestions.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4, bottom: 4),
                                child: SectionHeader(
                                  title: 'Sugestões de parceiro',
                                  actionLabel: 'Need 1 agora',
                                  onAction: () => context.push('/need-1'),
                                ),
                              );
                            }
                            final suggestion = suggestions[index - 1];
                            return _SearchSuggestionCard(
                              suggestion: suggestion,
                              onJoinNow: () => _onAutoFill(suggestion),
                              onOpen: () {
                                if (suggestion.matchId != null) {
                                  context.push('/matches/${suggestion.matchId}');
                                  return;
                                }
                                if (suggestion.match != null && suggestion.match!.id.isNotEmpty) {
                                  context.push('/matches/${suggestion.match!.id}');
                                  return;
                                }
                                context.push('/need-1');
                              },
                              onNeedOne: () {
                                context.push('/need-1');
                              },
                            );
                          },
                        ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _advancedMode
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.auto_fix_high_rounded),
              label: const Text('Need 1 now'),
              onPressed: () => context.push('/need-1'),
            )
          : null,
    );
  }
}

class _SearchSuggestionCard extends StatelessWidget {
  final MatchSuggestion suggestion;
  final VoidCallback onJoinNow;
  final VoidCallback onNeedOne;
  final VoidCallback onOpen;

  const _SearchSuggestionCard({
    required this.suggestion,
    required this.onJoinNow,
    required this.onNeedOne,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final title = suggestion.title ?? 'Partida recomendada';
    final city = suggestion.city ?? 'Cidade';
    final date = suggestion.date != null
        ? '${suggestion.date!.day}/${suggestion.date!.month}/${suggestion.date!.year}'
        : 'Em breve';
    final level = '${suggestion.minLevel ?? 'BEGINNER'} - ${suggestion.maxLevel ?? 'PROFESSIONAL'}';
    final spots = suggestion.spotsLeft < 0 ? 0 : suggestion.spotsLeft;

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        decoration: AppDecorations.gradientCard,
        child: Padding(
          padding: AppSpacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.sports_tennis_rounded, color: AppColors.primary),
                  AppSpacing.horizontalSm,
                  Expanded(
                    child: Text(title, style: AppTypography.h4),
                  ),
                  if (suggestion.confidence != null)
                    Text(
                      '${(suggestion.confidence! * 100).toStringAsFixed(0)}%',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
              AppSpacing.verticalMd,
              Text(
                '$city  •  $date  •  $level',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              if (suggestion.description != null && suggestion.description!.isNotEmpty) ...[
                AppSpacing.verticalSm,
                Text(
                  suggestion.description!,
                  style: AppTypography.bodyMedium,
                ),
              ],
              AppSpacing.verticalSm,
              Text(
                '${suggestion.startTime ?? ''} ${suggestion.endTime != null ? '- ${suggestion.endTime}' : ''}',
                style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              AppSpacing.verticalMd,
              Row(
                children: [
                  _Need1Chip(
                    icon: Icons.group_outlined,
                    label: '$spots/${suggestion.playersNeeded} lugares',
                  ),
                  AppSpacing.horizontalSm,
                  if (suggestion.distanceKm != null)
                    _Need1Chip(
                      icon: Icons.gps_fixed_rounded,
                      label: '${suggestion.distanceKm!.toStringAsFixed(1)} km',
                    ),
                  const Spacer(),
                  GhostButton(
                    label: 'Ver partida',
                    icon: Icons.visibility_outlined,
                    onPressed: onOpen,
                    isExpanded: false,
                    height: 36,
                  ),
                  AppSpacing.horizontalSm,
                  PrimaryButton(
                    label: 'Entrar Agora',
                    icon: Icons.login_rounded,
                    onPressed: onJoinNow,
                    isExpanded: false,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Need1Chip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Need1Chip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceBright,
        borderRadius: AppDecorations.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 14),
          AppSpacing.horizontalSm,
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
