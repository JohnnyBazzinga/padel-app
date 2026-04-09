import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/bookings_provider.dart';
import '../../../shared/providers/matches_provider.dart';
import '../../../shared/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<BookingsProvider>().fetchMyBookings();
    context.read<MatchesProvider>().fetchMyMatches();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookings = context.watch<BookingsProvider>();
    final matches = context.watch<MatchesProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => _loadData(),
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _Header(userName: auth.user?.firstName ?? 'Jogador'),

                AppSpacing.verticalXl,

                // Quick Actions
                _QuickActionsSection(),

                AppSpacing.verticalXxl,

                // Next Match Hero (if has upcoming match)
                if (matches.myMatches.isNotEmpty) ...[
                  Padding(
                    padding: AppSpacing.screenPadding,
                    child: _NextMatchHero(
                      match: matches.myMatches.first,
                      onTap: () => context.push('/matches/${matches.myMatches.first.id}'),
                    ),
                  ),
                  AppSpacing.verticalXxl,
                ],

                // My Bookings
                _BookingsSection(
                  bookings: bookings,
                  onSeeAll: () => context.push('/my-bookings'),
                  onBook: () => context.push('/clubs'),
                ),

                AppSpacing.verticalXxl,

                // My Matches
                _MatchesSection(
                  matches: matches,
                  onSeeAll: () => context.push('/matches'),
                  onCreateMatch: () => context.push('/create-match'),
                ),

                AppSpacing.verticalXxl,

                // Find Partners Banner
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: _FindPartnersBanner(
                    onTap: () => context.push('/matches'),
                  ),
                ),

                AppSpacing.verticalXxl,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String userName;

  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $userName!',
                style: AppTypography.h1,
              ),
              AppSpacing.verticalXs,
              Text(
                'Pronto para jogar?',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              AppIconButton(
                icon: Icons.chat_bubble_outline_rounded,
                variant: AppIconButtonVariant.glass,
                onPressed: () => context.push('/chat'),
              ),
              AppSpacing.horizontalSm,
              AppIconButton(
                icon: Icons.notifications_outlined,
                variant: AppIconButtonVariant.glass,
                badge: '3',
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0, duration: 400.ms);
  }
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        children: [
          QuickActionCard(
            icon: Icons.calendar_month_rounded,
            label: 'Reservar',
            subtitle: 'Courts',
            accentColor: AppColors.primary,
            onTap: () => context.push('/clubs'),
          ),
          AppSpacing.horizontalMd,
          QuickActionCard(
            icon: Icons.group_add_rounded,
            label: 'Criar Jogo',
            subtitle: 'Novo',
            accentColor: AppColors.accent,
            onTap: () => context.push('/create-match'),
          ),
          AppSpacing.horizontalMd,
          QuickActionCard(
            icon: Icons.emoji_events_rounded,
            label: 'Torneios',
            subtitle: 'Competir',
            accentColor: AppColors.secondary,
            onTap: () => context.push('/tournaments'),
          ),
          AppSpacing.horizontalMd,
          QuickActionCard(
            icon: Icons.people_rounded,
            label: 'Amigos',
            subtitle: 'Social',
            accentColor: AppColors.info,
            onTap: () => context.push('/friends'),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideX(begin: 0.05, end: 0, duration: 400.ms);
  }
}

class _NextMatchHero extends StatelessWidget {
  final dynamic match;
  final VoidCallback onTap;

  const _NextMatchHero({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: AppDecorations.borderRadiusXl,
          boxShadow: AppDecorations.shadowGlow(AppColors.primary, intensity: 0.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: AppDecorations.borderRadiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_tennis_rounded,
                        size: 14,
                        color: AppColors.background,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'PRÓXIMO JOGO',
                        style: AppTypography.overline.copyWith(
                          color: AppColors.background,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.background.withOpacity(0.7),
                  size: 20,
                ),
              ],
            ),
            AppSpacing.verticalLg,
            Text(
              match.displayLocation ?? 'Jogo de Padel',
              style: AppTypography.h2.copyWith(
                color: AppColors.background,
              ),
            ),
            AppSpacing.verticalXs,
            Text(
              '${DateFormat('EEEE, d MMM', 'pt_PT').format(match.date)} • ${match.startTime}',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.background.withOpacity(0.8),
              ),
            ),
            AppSpacing.verticalLg,
            Row(
              children: [
                _HeroInfoChip(
                  icon: Icons.person_rounded,
                  label: '${match.currentPlayers}/${match.playersNeeded}',
                ),
                AppSpacing.horizontalSm,
                _HeroInfoChip(
                  icon: Icons.schedule_rounded,
                  label: match.startTime,
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 200.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), duration: 500.ms);
  }
}

class _HeroInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.2),
        borderRadius: AppDecorations.borderRadiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.background),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.background,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingsSection extends StatelessWidget {
  final BookingsProvider bookings;
  final VoidCallback onSeeAll;
  final VoidCallback onBook;

  const _BookingsSection({
    required this.bookings,
    required this.onSeeAll,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: AppSpacing.screenPadding,
          child: SectionHeader(
            title: 'Minhas Reservas',
            actionLabel: 'Ver todas',
            onAction: onSeeAll,
          ),
        ),
        AppSpacing.verticalMd,
        if (bookings.isLoading)
          Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                const SkeletonCard(height: 90),
                const SkeletonCard(height: 90),
              ],
            ),
          )
        else if (bookings.myBookings.isEmpty)
          Padding(
            padding: AppSpacing.screenPadding,
            child: _EmptyCard(
              icon: Icons.calendar_today_outlined,
              message: 'Sem reservas agendadas',
              actionLabel: 'Reservar agora',
              onAction: onBook,
            ),
          )
        else
          Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: bookings.myBookings.take(2).map((booking) {
                return _BookingCard(
                  clubName: booking.clubName,
                  courtName: booking.courtName,
                  date: DateFormat('dd MMM', 'pt_PT').format(booking.date),
                  time: '${booking.startTime} - ${booking.endTime}',
                  price: booking.priceFormatted,
                );
              }).toList(),
            ),
          ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms);
  }
}

class _MatchesSection extends StatelessWidget {
  final MatchesProvider matches;
  final VoidCallback onSeeAll;
  final VoidCallback onCreateMatch;

  const _MatchesSection({
    required this.matches,
    required this.onSeeAll,
    required this.onCreateMatch,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: AppSpacing.screenPadding,
          child: SectionHeader(
            title: 'Jogos Disponíveis',
            actionLabel: 'Ver todos',
            onAction: onSeeAll,
          ),
        ),
        AppSpacing.verticalMd,
        if (matches.isLoading)
          Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: const [
                SkeletonMatchCard(),
                SkeletonMatchCard(),
              ],
            ),
          )
        else if (matches.myMatches.isEmpty)
          Padding(
            padding: AppSpacing.screenPadding,
            child: _EmptyCard(
              icon: Icons.sports_tennis_outlined,
              message: 'Sem jogos agendados',
              actionLabel: 'Criar jogo',
              onAction: onCreateMatch,
            ),
          )
        else
          Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: matches.myMatches.take(2).map((match) {
                return _MatchCardRedesigned(
                  title: match.title ?? 'Jogo de Padel',
                  location: match.displayLocation,
                  date: DateFormat('dd MMM', 'pt_PT').format(match.date),
                  time: match.startTime,
                  currentPlayers: match.currentPlayers,
                  totalPlayers: match.playersNeeded,
                  level: match.minLevel,
                  onTap: () => context.push('/matches/${match.id}'),
                );
              }).toList(),
            ),
          ),
      ],
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 400.ms);
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _EmptyCard({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.primary),
          ),
          AppSpacing.verticalMd,
          Text(
            message,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.verticalLg,
          GhostButton(
            label: actionLabel,
            onPressed: onAction,
            isExpanded: false,
            height: 44,
          ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final String clubName;
  final String courtName;
  final String date;
  final String time;
  final String price;

  const _BookingCard({
    required this.clubName,
    required this.courtName,
    required this.date,
    required this.time,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      decoration: AppDecorations.gradientCard,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppDecorations.borderRadiusLg,
          onTap: () {},
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: AppDecorations.borderRadiusMd,
                  ),
                  child: const Icon(
                    Icons.location_city_rounded,
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
                        clubName,
                        style: AppTypography.h4,
                      ),
                      AppSpacing.verticalXs,
                      Text(
                        '$courtName • $time',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius: AppDecorations.borderRadiusFull,
                      ),
                      child: Text(
                        date,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      price,
                      style: AppTypography.bodySmall.copyWith(
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
}

class _MatchCardRedesigned extends StatelessWidget {
  final String title;
  final String location;
  final String date;
  final String time;
  final int currentPlayers;
  final int totalPlayers;
  final String level;
  final VoidCallback onTap;

  const _MatchCardRedesigned({
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.currentPlayers,
    required this.totalPlayers,
    required this.level,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      decoration: AppDecorations.gradientCard,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppDecorations.borderRadiusLg,
          onTap: onTap,
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Date & Level
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InfoChip(
                      icon: Icons.calendar_today_rounded,
                      label: '$date • $time',
                    ),
                    LevelBadge(level: level),
                  ],
                ),
                AppSpacing.verticalLg,

                // Location
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentMuted,
                        borderRadius: AppDecorations.borderRadiusSm,
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    AppSpacing.horizontalMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTypography.h4,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            location,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalLg,

                // Divider
                Container(
                  height: 1,
                  color: AppColors.glassBorder,
                ),
                AppSpacing.verticalLg,

                // Bottom: Players
                Row(
                  children: [
                    // Player dots
                    Row(
                      children: List.generate(totalPlayers, (index) {
                        final isFilled = index < currentPlayers;
                        return Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: isFilled ? AppColors.primary : AppColors.surfaceBright,
                            shape: BoxShape.circle,
                          ),
                        );
                      }),
                    ),
                    AppSpacing.horizontalSm,
                    Text(
                      '$currentPlayers/$totalPlayers jogadores',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.textMuted,
                      size: 18,
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

class _FindPartnersBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _FindPartnersBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: AppDecorations.borderRadiusXl,
          boxShadow: AppDecorations.shadowGlow(AppColors.accent, intensity: 0.25),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: AppDecorations.borderRadiusMd,
              ),
              child: Icon(
                Icons.groups_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            AppSpacing.horizontalLg,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Procura parceiros',
                    style: AppTypography.h3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  AppSpacing.verticalXxs,
                  Text(
                    'Encontra jogadores do teu nível',
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppDecorations.borderRadiusMd,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.accent,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 500.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }
}
