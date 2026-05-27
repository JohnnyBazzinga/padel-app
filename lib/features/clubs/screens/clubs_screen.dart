import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/clubs_provider.dart';
import '../../../shared/widgets/widgets.dart';

class ClubsScreen extends StatefulWidget {
  const ClubsScreen({super.key});

  @override
  State<ClubsScreen> createState() => _ClubsScreenState();
}

class _ClubsScreenState extends State<ClubsScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'Todos';

  @override
  void initState() {
    super.initState();
    context.read<ClubsProvider>().fetchClubs(refresh: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubsProvider>();

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
                      Text('Clubes', style: AppTypography.h1),
                      AppSpacing.verticalXs,
                      Text(
                        '${provider.clubs.length} clubes disponíveis',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  AppIconButton(
                    icon: Icons.map_outlined,
                    variant: AppIconButtonVariant.glass,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            AppSpacing.verticalLg,

            // Search
            Padding(
              padding: AppSpacing.screenPadding,
              child: Row(
                children: [
                  Expanded(
                    child: SearchField(
                      controller: _searchController,
                      hint: 'Procurar clubes...',
                      onChanged: (value) {
                        // TODO: Filter clubs
                      },
                    ),
                  ),
                  AppSpacing.horizontalMd,
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
              options: const ['Todos', 'Perto de mim', 'Favoritos', 'Populares'],
              selected: _selectedFilter,
              onSelected: (filter) {
                setState(() => _selectedFilter = filter);
              },
            ),
            AppSpacing.verticalLg,

            // Clubs List
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.fetchClubs(refresh: true),
                color: AppColors.primary,
                backgroundColor: AppColors.surface,
                child: provider.isLoading && provider.clubs.isEmpty
                    ? _buildLoadingState()
                    : provider.clubs.isEmpty
                        ? _buildEmptyState()
                        : _buildClubsList(provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: AppSpacing.screenPadding,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.cardGap),
          child: SkeletonCard(height: 220),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.location_city_rounded,
      title: 'Sem clubes encontrados',
      message: 'Não encontramos clubes para a tua pesquisa. Tenta outros filtros.',
      actionLabel: 'Limpar filtros',
      onAction: () {
        _searchController.clear();
        setState(() => _selectedFilter = 'Todos');
      },
    );
  }

  Widget _buildClubsList(ClubsProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: provider.clubs.length,
      itemBuilder: (context, index) {
        final club = provider.clubs[index];
        return _ClubCard(
          name: club.name,
          city: club.city,
          courts: club.courtCount,
          imageUrl: club.coverImageUrl,
          isVerified: club.isVerified,
          rating: 4.8, // TODO: Get from club
          amenities: [
            if (club.hasParking) _AmenityData(Icons.local_parking_rounded, 'Parking'),
            if (club.hasShowers) _AmenityData(Icons.shower_rounded, 'Duches'),
            if (club.hasCafeteria) _AmenityData(Icons.local_cafe_rounded, 'Bar'),
            if (club.hasLockers) _AmenityData(Icons.lock_rounded, 'Cacifos'),
          ],
          onTap: () => context.push('/clubs/${club.id}'),
        )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .slideY(begin: 0.05, end: 0);
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

class _AmenityData {
  final IconData icon;
  final String label;

  _AmenityData(this.icon, this.label);
}

class _ClubCard extends StatelessWidget {
  final String name;
  final String city;
  final int courts;
  final String? imageUrl;
  final bool isVerified;
  final double rating;
  final List<_AmenityData> amenities;
  final VoidCallback onTap;

  const _ClubCard({
    required this.name,
    required this.city,
    required this.courts,
    this.imageUrl,
    this.isVerified = false,
    this.rating = 0,
    this.amenities = const [],
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.listGap),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.borderRadiusLg,
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDecorations.borderRadiusLg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppDecorations.radiusLg),
                    ),
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl!,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 160,
                              color: AppColors.surfaceLight,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  // Gradient overlay
                  // Overlay intentionally removed to avoid gradient fills
                  // Rating badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.glassFill,
                        borderRadius: AppDecorations.borderRadiusFull,
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Verified badge
                  if (isVerified)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppDecorations.borderRadiusFull,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: AppColors.background,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verificado',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.background,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Content
              Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: AppTypography.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.verticalSm,

                    // Location & Courts
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          city,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        AppSpacing.horizontalLg,
                        Icon(
                          Icons.sports_tennis_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$courts campos',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    if (amenities.isNotEmpty) ...[
                      AppSpacing.verticalMd,
                      // Amenities
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: amenities.map((amenity) {
                          return _AmenityChip(
                            icon: amenity.icon,
                            label: amenity.label,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 160,
      color: AppColors.surfaceLight,
      child: const Center(
        child: Icon(
          Icons.location_city_rounded,
          size: 48,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AmenityChip({
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
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
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

          Text('Filtrar Clubes', style: AppTypography.h2),
          AppSpacing.verticalXl,

          Text(
            'Comodidades',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.verticalMd,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SelectableChip(label: 'Parking', icon: Icons.local_parking_rounded, onTap: () {}),
              SelectableChip(label: 'Duches', icon: Icons.shower_rounded, onTap: () {}),
              SelectableChip(label: 'Bar', icon: Icons.local_cafe_rounded, onTap: () {}),
              SelectableChip(label: 'Pro Shop', icon: Icons.storefront_rounded, onTap: () {}),
            ],
          ),
          AppSpacing.verticalXl,

          Text(
            'Distância',
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          AppSpacing.verticalMd,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SelectableChip(label: '< 5 km', isSelected: true, onTap: () {}),
              SelectableChip(label: '< 10 km', onTap: () {}),
              SelectableChip(label: '< 20 km', onTap: () {}),
              SelectableChip(label: 'Qualquer', onTap: () {}),
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
