import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/models/match_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/bookings_provider.dart';
import '../../../shared/providers/matches_provider.dart';
import '../../../shared/providers/notifications_provider.dart';
import '../../../shared/widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String _allCities = 'Todas as cidades';
  static const List<String> _cityFilters = [
    _allCities,
    'Lisboa',
    'Madrid',
    'Dubai',
    'Sao Paulo',
    'Barcelona',
  ];

  String _selectedCity = _allCities;
  bool _needOneOnly = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final selectedCity = _selectedCity == _allCities ? null : _selectedCity;
    await Future.wait([
      context.read<BookingsProvider>().fetchMyBookings(),
      context.read<MatchesProvider>().fetchMyMatches(),
      context.read<MatchesProvider>().fetchMatches(city: selectedCity),
      context.read<NotificationsProvider>().fetchUnreadCount(),
    ]);
  }

  List<Match> _uniqueMatches(Iterable<Match> source) {
    final unique = <String, Match>{};
    for (final match in source) {
      unique[match.id] = match;
    }
    return unique.values.toList();
  }

  List<Match> _discoveryMatches(MatchesProvider provider) {
    var list = List<Match>.from(_uniqueMatches(provider.matches));

    if (_selectedCity != _allCities) {
      final selected = _selectedCity.toLowerCase();
      list = list.where((match) {
        final city = (match.city ?? match.club?.city ?? '').toLowerCase();
        final location = match.displayLocation.toLowerCase();
        return city == selected || location.contains(selected);
      }).toList();
    }

    if (_needOneOnly) {
      list = list.where((match) => match.spotsLeft == 1).toList();
    }

    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  Match? _needOneHeroMatch(MatchesProvider provider) {
    final all = _uniqueMatches([
      ...provider.myMatches,
      ...provider.matches,
    ]);
    final candidates = all
        .where((match) => !match.isFull && match.spotsLeft == 1)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return candidates.isEmpty ? null : candidates.first;
  }

  String _formatMatchDateTime(DateTime date, String time) {
    return '${DateFormat('EEEE, d MMM', 'pt_PT').format(date)} - $time';
  }

  void _selectCity(String city) {
    setState(() {
      _selectedCity = city;
    });
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final bookings = context.watch<BookingsProvider>();
    final matches = context.watch<MatchesProvider>();
    final notifications = context.watch<NotificationsProvider>();

    final discoveryMatches = _discoveryMatches(matches);
    final heroMatch = _needOneHeroMatch(matches);

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
                _HomeHeader(
                  firstName: auth.user?.firstName ?? 'Jogador',
                  cityName: auth.user?.city ?? 'Lisboa',
                  avatarUrl: auth.user?.avatarUrl,
                  unreadNotifications: notifications.unreadCount,
                  onOpenProfile: () => context.push('/profile'),
                  onOpenChat: () => context.push('/chat'),
                  onOpenNotifications: () => context.push('/chat'),
                ),
                AppSpacing.verticalLg,
                _CityDiscoveryStrip(
                  cities: _cityFilters,
                  selectedCity: _selectedCity,
                  needOneOnly: _needOneOnly,
                  onCitySelected: _selectCity,
                  onNeedOneToggle: (value) {
                    setState(() => _needOneOnly = value);
                  },
                ),
                AppSpacing.verticalXl,
                _QuickActionsSection(
                  canInviteOrganizer: auth.canInviteOrganizer,
                  canCreateMatch: auth.canCreateMatches,
                  onBook: () => context.push('/clubs'),
                  onMatches: () => context.push('/matches'),
                  onCreateMatch:
                      auth.canCreateMatches ? () => context.push('/create-match') : null,
                  onChat: () => context.push('/chat'),
                  onTournaments: () => context.push('/tournaments'),
                  onFriends: () => context.push('/friends'),
                  onAdmin: auth.canInviteOrganizer
                      ? () => context.push('/admin/invite-organizer')
                      : null,
                ),
                AppSpacing.verticalXxl,
                if (heroMatch != null) ...[
                  _NeedOneHeroCard(
                    match: heroMatch,
                    onTap: () => context.push('/matches/${heroMatch.id}'),
                    matchDateLabel: _formatMatchDateTime(heroMatch.date, heroMatch.startTime),
                  ),
                  AppSpacing.verticalXxl,
                ],
                if (matches.error != null && matches.matches.isEmpty)
                  Padding(
                    padding: AppSpacing.screenPadding,
                    child: _ErrorState(
                      message: matches.error!,
                      onRetry: _loadData,
                    ),
                  )
                else
                  _DiscoverySection(
                    title: 'Jogos para ti',
                    actionLabel: 'Ver todos',
                    onAction: () => context.push('/matches'),
                    isLoading: matches.isLoading,
                    matches: discoveryMatches,
                    onMatchTap: (matchId) => context.push('/matches/$matchId'),
                    formatMatchDateTime: _formatMatchDateTime,
                  ),
                AppSpacing.verticalXxl,
                _HomeBookingsSection(
                  bookings: bookings,
                  onSeeAll: () => context.push('/my-bookings'),
                  onBook: () => context.push('/clubs'),
                  formatDate: (date) => DateFormat('dd MMM', 'pt_PT').format(date),
                  formatTime: (booking) => '${booking.startTime} - ${booking.endTime}',
                ),
                AppSpacing.verticalXxl,
                _HomeMatchesSection(
                  matches: matches.myMatches,
                  isLoading: matches.isLoading,
                  onSeeAll: () => context.push('/matches'),
                  onCreateMatch: auth.canCreateMatches
                      ? () => context.push('/create-match')
                      : () => context.push('/matches'),
                  onMatchTap: (matchId) => context.push('/matches/$matchId'),
                  formatMatchDateTime: _formatMatchDateTime,
                ),
                AppSpacing.verticalXxl,
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: _CommunityPromoBanner(onAction: () => context.push('/friends')),
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

class _HomeHeader extends StatelessWidget {
  final String firstName;
  final String cityName;
  final String? avatarUrl;
  final int unreadNotifications;
  final VoidCallback onOpenProfile;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenNotifications;

  const _HomeHeader({
    required this.firstName,
    required this.cityName,
    this.avatarUrl,
    required this.unreadNotifications,
    required this.onOpenProfile,
    required this.onOpenChat,
    required this.onOpenNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            imageUrl: avatarUrl,
            name: firstName,
            size: 52,
            showGradient: true,
            onTap: onOpenProfile,
          ),
          AppSpacing.horizontalLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello $firstName',
                  style: AppTypography.h2,
                ),
                AppSpacing.verticalXs,
                Text(
                  'Vamos jogar padel em $cityName hoje',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AppIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            onPressed: onOpenChat,
            variant: AppIconButtonVariant.glass,
            badge: null,
          ),
          AppSpacing.horizontalSm,
          AppIconButton(
            icon: Icons.notifications_outlined,
            onPressed: onOpenNotifications,
            variant: AppIconButtonVariant.glass,
            badge: unreadNotifications > 0 ? unreadNotifications.toString() : null,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 80.ms)
        .slideY(begin: -0.06, end: 0, duration: 380.ms);
  }
}

class _CityDiscoveryStrip extends StatelessWidget {
  final List<String> cities;
  final String selectedCity;
  final bool needOneOnly;
  final ValueChanged<String> onCitySelected;
  final ValueChanged<bool> onNeedOneToggle;

  const _CityDiscoveryStrip({
    required this.cities,
    required this.selectedCity,
    required this.needOneOnly,
    required this.onCitySelected,
    required this.onNeedOneToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Need 1 player now',
            style: AppTypography.h3,
          ),
          AppSpacing.verticalSm,
          Text(
            'Filtra partidas abertas por cidade e urgencia',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.verticalMd,
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final city = cities[index];
                final isSelected = city == selectedCity;

                return GestureDetector(
                  onTap: () => onCitySelected(city),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: AppDecorations.borderRadiusFull,
                      border: Border.all(
                        color: isSelected ? Colors.transparent : AppColors.glassBorder,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      city,
                      style: AppTypography.labelSmall.copyWith(
                        color: isSelected ? AppColors.background : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
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
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppDecorations.borderRadiusMd,
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.groups_2_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      AppSpacing.horizontalSm,
                      Text(
                        'Precisa apenas 1 jogador',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              AppSpacing.horizontalMd,
              Switch.adaptive(
                value: needOneOnly,
                activeColor: AppColors.primary,
                onChanged: onNeedOneToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final bool canInviteOrganizer;
  final bool canCreateMatch;
  final VoidCallback onBook;
  final VoidCallback onMatches;
  final VoidCallback? onCreateMatch;
  final VoidCallback onChat;
  final VoidCallback onTournaments;
  final VoidCallback onFriends;
  final VoidCallback? onAdmin;

  const _QuickActionsSection({
    required this.canInviteOrganizer,
    required this.canCreateMatch,
    required this.onBook,
    required this.onMatches,
    required this.onCreateMatch,
    required this.onChat,
    required this.onTournaments,
    required this.onFriends,
    required this.onAdmin,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 138,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        children: [
          QuickActionCard(
            icon: Icons.calendar_month_rounded,
            label: 'Reservar',
            subtitle: 'Courts',
            accentColor: AppColors.primary,
            onTap: onBook,
          ),
          AppSpacing.horizontalMd,
          QuickActionCard(
            icon: Icons.groups_3_rounded,
            label: 'Partidas',
            subtitle: 'Matchmaking',
            accentColor: AppColors.accent,
            onTap: onMatches,
          ),
          AppSpacing.horizontalMd,
          QuickActionCard(
            icon: Icons.emoji_events_rounded,
            label: 'Torneios',
            subtitle: 'Competir',
            accentColor: AppColors.secondary,
            onTap: onTournaments,
          ),
          AppSpacing.horizontalMd,
          QuickActionCard(
            icon: Icons.chat_rounded,
            label: 'Chat',
            subtitle: 'Mensagem',
            accentColor: AppColors.info,
            onTap: onChat,
          ),
          if (canCreateMatch) ...[
            AppSpacing.horizontalMd,
            QuickActionCard(
              icon: Icons.add_box_outlined,
              label: 'Criar',
              subtitle: 'Jogo',
              accentColor: AppColors.success,
              onTap: onCreateMatch,
            ),
          ],
          AppSpacing.horizontalMd,
          QuickActionCard(
            icon: Icons.people_alt_rounded,
            label: 'Amigos',
            subtitle: 'Rede',
            accentColor: AppColors.info,
            onTap: onFriends,
          ),
          if (canInviteOrganizer && onAdmin != null) ...[
            AppSpacing.horizontalMd,
            QuickActionCard(
              icon: Icons.workspace_premium_rounded,
              label: 'Admin',
              subtitle: 'Clube',
              accentColor: AppColors.error,
              onTap: onAdmin,
            ),
          ],
        ],
      ),
    );
  }
}

class _NeedOneHeroCard extends StatelessWidget {
  final Match match;
  final String matchDateLabel;
  final VoidCallback onTap;

  const _NeedOneHeroCard({
    required this.match,
    required this.matchDateLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppDecorations.borderRadiusXl,
            boxShadow: AppDecorations.shadowGlow(AppColors.primary, intensity: 0.25),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBright,
                    borderRadius: AppDecorations.borderRadiusFull,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sports_tennis_rounded,
                        size: 14,
                        color: AppColors.textPrimary,
                      ),
                      AppSpacing.horizontalSm,
                      Text(
                        'NEED 1 PLAYER NOW',
                        style: AppTypography.overline.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.verticalLg,
                Text(
                  match.displayLocation,
                  style: AppTypography.h2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.verticalXs,
                Text(
                  matchDateLabel,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                AppSpacing.verticalXl,
                Row(
                  children: [
                    _SpotPill(
                      icon: Icons.person_rounded,
                      label: '${match.currentPlayers}/${match.playersNeeded}',
                      isLight: false,
                    ),
                    AppSpacing.horizontalSm,
                    _SpotPill(
                      icon: Icons.location_city_rounded,
                      label: match.city ?? match.club?.city ?? 'Online',
                      isLight: false,
                    ),
                    const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppDecorations.borderRadiusMd,
                  ),
                  child: Text(
                    'Entrar',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.background,
                      fontWeight: FontWeight.w700,
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
    )
        .animate()
        .fadeIn(duration: 450.ms)
        .slideY(begin: 0.05, end: 0, duration: 450.ms);
  }
}

class _SpotPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLight;

  const _SpotPill({
    required this.icon,
    required this.label,
    required this.isLight,
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
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 14),
          AppSpacing.horizontalSm,
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverySection extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final bool isLoading;
  final List<Match> matches;
  final ValueChanged<String> onMatchTap;
  final String Function(DateTime, String) formatMatchDateTime;

  const _DiscoverySection({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.isLoading,
    required this.matches,
    required this.onMatchTap,
    required this.formatMatchDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: AppSpacing.screenPadding,
          child: SectionHeader(
            title: title,
            actionLabel: actionLabel,
            onAction: onAction,
          ),
        ),
        AppSpacing.verticalMd,
        if (isLoading && matches.isEmpty)
          Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: const [
                SkeletonMatchCard(),
                AppSpacing.verticalMd,
                SkeletonMatchCard(),
              ],
            ),
          )
        else if (matches.isEmpty)
          Padding(
            padding: AppSpacing.screenPadding,
            child: _HomeEmptyCard(
              icon: Icons.sports_tennis_outlined,
              message:
                  'Nao ha jogos com 1 vaga faltando com este filtro',
              actionLabel: 'Abrir feed geral',
              onAction: onAction,
            ),
          )
        else
          Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: matches
                  .take(4)
                  .map(
                    (match) => _SocialMatchCard(
                      match: match,
                      matchDateLabel: formatMatchDateTime(match.date, match.startTime),
                      onOpen: () => onMatchTap(match.id),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    )
        .animate()
        .fadeIn(duration: 420.ms, delay: 60.ms)
        .slideX(begin: -0.02, end: 0, duration: 420.ms);
  }
}

class _HomeBookingsSection extends StatelessWidget {
  final BookingsProvider bookings;
  final VoidCallback onSeeAll;
  final VoidCallback onBook;
  final String Function(DateTime) formatDate;
  final String Function(Booking) formatTime;

  const _HomeBookingsSection({
    required this.bookings,
    required this.onSeeAll,
    required this.onBook,
    required this.formatDate,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: AppSpacing.screenPadding,
          child: SectionHeader(
            title: 'Minhas reservas',
            actionLabel: 'Ver todas',
            onAction: onSeeAll,
          ),
        ),
        AppSpacing.verticalMd,
        if (bookings.isLoading)
          Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: const [
                SkeletonCard(height: 96),
                AppSpacing.verticalMd,
                SkeletonCard(height: 96),
              ],
            ),
          )
        else if (bookings.myBookings.isEmpty)
          Padding(
            padding: AppSpacing.screenPadding,
            child: _HomeEmptyCard(
              icon: Icons.calendar_today_outlined,
              message: 'Sem reservas no momento',
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
                  clubName: booking.clubName.isEmpty ? 'Padel Court' : booking.clubName,
                  courtName: booking.courtName.isEmpty ? 'Court' : booking.courtName,
                  date: formatDate(booking.date),
                  time: formatTime(booking),
                  price: booking.priceFormatted,
                );
              }).toList(),
            ),
          ),
      ],
    )
        .animate()
        .fadeIn(duration: 420.ms, delay: 140.ms)
        .slideX(begin: 0.02, end: 0, duration: 420.ms);
  }
}

class _HomeMatchesSection extends StatelessWidget {
  final List<Match> matches;
  final bool isLoading;
  final VoidCallback onSeeAll;
  final VoidCallback onCreateMatch;
  final ValueChanged<String> onMatchTap;
  final String Function(DateTime, String) formatMatchDateTime;

  const _HomeMatchesSection({
    required this.matches,
    required this.isLoading,
    required this.onSeeAll,
    required this.onCreateMatch,
    required this.onMatchTap,
    required this.formatMatchDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: AppSpacing.screenPadding,
          child: SectionHeader(
            title: 'Meus jogos',
            actionLabel: 'Ver todos',
            onAction: onSeeAll,
          ),
        ),
        AppSpacing.verticalMd,
        if (isLoading)
          Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: const [
                SkeletonMatchCard(),
                AppSpacing.verticalMd,
                SkeletonMatchCard(),
              ],
            ),
          )
        else if (matches.isEmpty)
          Padding(
            padding: AppSpacing.screenPadding,
            child: _HomeEmptyCard(
              icon: Icons.sports_score_rounded,
              message: 'Ainda sem jogos agendados',
              actionLabel: 'Criar jogo',
              onAction: onCreateMatch,
            ),
          )
        else
          Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: matches.take(2).map((match) {
                return _SocialMatchCard(
                  match: match,
                  matchDateLabel: formatMatchDateTime(match.date, match.startTime),
                  onOpen: () => onMatchTap(match.id),
                  showTeamHint: true,
                );
              }).toList(),
            ),
          ),
      ],
    )
        .animate()
        .fadeIn(duration: 420.ms, delay: 220.ms)
        .slideY(begin: 0.04, end: 0, duration: 420.ms);
  }
}

class _SocialMatchCard extends StatelessWidget {
  final Match match;
  final String matchDateLabel;
  final VoidCallback onOpen;
  final bool showTeamHint;

  const _SocialMatchCard({
    required this.match,
    required this.matchDateLabel,
    required this.onOpen,
    this.showTeamHint = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatars = match.players
        .map(
          (player) => AvatarData(
            imageUrl: player.user?.avatarUrl,
            name: player.user?.fullName,
          ),
        )
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      decoration: AppDecorations.gradientCard,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: AppDecorations.borderRadiusLg,
          child: Padding(
            padding: AppSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (avatars.isNotEmpty)
                      AvatarStack(
                        avatars: avatars,
                        size: 26,
                        overlap: 0.45,
                        maxDisplay: 3,
                        totalCount: match.currentPlayers,
                      )
                    else
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceBright,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.person_outline,
                          size: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    AppSpacing.horizontalSm,
                    Expanded(
                      child: Text(
                        match.title ?? 'Jogo de padel',
                        style: AppTypography.h4,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (match.spotsLeft == 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.18),
                          borderRadius: AppDecorations.borderRadiusFull,
                        ),
                        child: Text(
                          'NEED 1',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                AppSpacing.verticalMd,
                Text(
                  match.displayLocation,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.verticalSm,
                Text(
                  matchDateLabel,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                AppSpacing.verticalMd,
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoChip(
                      icon: Icons.location_city_rounded,
                      label: match.city ?? match.club?.city ?? 'Cidade',
                    ),
                    InfoChip(
                      icon: Icons.people_rounded,
                      label: '${match.currentPlayers}/${match.playersNeeded}',
                    ),
                    InfoChip(
                      icon: Icons.sports_tennis_rounded,
                      label: match.minLevel,
                    ),
                  ],
                ),
                AppSpacing.verticalLg,
                Divider(color: AppColors.glassBorder),
                AppSpacing.verticalMd,
                Row(
                  children: [
                    _PlayerDots(
                      total: match.playersNeeded,
                      filled: match.currentPlayers,
                      compact: true,
                    ),
                    AppSpacing.horizontalSm,
                    Text(
                      '${match.currentPlayers}/${match.playersNeeded} jogadores',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (showTeamHint)
                      Row(
                        children: [
                          Icon(
                            Icons.group_add_outlined,
                            color: AppColors.primary,
                            size: 18,
                          ),
                          AppSpacing.horizontalXs,
                          Text(
                            'Entrar',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      GestureDetector(
                        onTap: onOpen,
                        child: const Icon(
                          Icons.arrow_forward_rounded,
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

class _PlayerDots extends StatelessWidget {
  final int total;
  final int filled;
  final bool compact;

  const _PlayerDots({
    required this.total,
    required this.filled,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: compact ? 76 : 90,
      height: compact ? 20 : 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(total, (index) {
          final isFilled = index < filled;
          return Positioned(
            left: index * 16,
            child: Container(
              width: compact ? 12 : 14,
              height: compact ? 12 : 14,
              decoration: BoxDecoration(
                color: isFilled ? AppColors.primary : AppColors.surfaceBright,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
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
      decoration: AppDecorations.glassCard,
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
                size: 22,
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
                  AppSpacing.verticalXxs,
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
                AppSpacing.verticalSm,
                Text(
                  price,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeEmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _HomeEmptyCard({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.glassCard,
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: AppColors.primary,
              ),
            ),
            AppSpacing.verticalMd,
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalLg,
            GhostButton(
              label: actionLabel,
              onPressed: onAction,
              isExpanded: false,
              height: 42,
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityPromoBanner extends StatelessWidget {
  final VoidCallback onAction;

  const _CommunityPromoBanner({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAction,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: AppDecorations.borderRadiusXl,
          boxShadow: AppDecorations.shadowGlow(AppColors.accent, intensity: 0.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: AppDecorations.borderRadiusMd,
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                size: 28,
                color: AppColors.accent,
              ),
            ),
            AppSpacing.horizontalLg,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Convide a comunidade',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.background,
                    ),
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    'Mostre os seus jogos, encontre parceiros e cresca com a app',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.background.withOpacity(0.88),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.glassCard,
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalMd,
            PrimaryButton(
              label: 'Tentar novamente',
              onPressed: () => onRetry(),
              isExpanded: false,
            ),
          ],
        ),
      ),
    );
  }
}
