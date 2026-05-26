import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/clubs_provider.dart';
import '../../../shared/widgets/widgets.dart';

class ClubDetailScreen extends StatefulWidget {
  final String clubId;

  const ClubDetailScreen({super.key, required this.clubId});

  @override
  State<ClubDetailScreen> createState() => _ClubDetailScreenState();
}

class _ClubDetailScreenState extends State<ClubDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ClubsProvider>().fetchClubById(widget.clubId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClubsProvider>();
    final club = provider.selectedClub;

    if (provider.isLoading || club == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverCustomAppBar(
            title: club.name,
            background: club.coverImageUrl != null
                ? Image.network(
                    club.coverImageUrl!,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: AppColors.surfaceLight,
                    child:
                        const Icon(Icons.stadium, size: 64, color: AppColors.textMuted),
                  ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${club.address}, ${club.city}',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  if (club.phone != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(club.phone!, style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Amenities
                  const Text(
                    'Comodidades',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (club.hasParking) _AmenityChip(icon: Icons.local_parking, label: 'Parking'),
                      if (club.hasShowers) _AmenityChip(icon: Icons.shower, label: 'Duches'),
                      if (club.hasLockers) _AmenityChip(icon: Icons.lock, label: 'Cacifos'),
                      if (club.hasProShop) _AmenityChip(icon: Icons.shopping_bag, label: 'Pro-Shop'),
                      if (club.hasCafeteria) _AmenityChip(icon: Icons.local_cafe, label: 'Bar'),
                      if (club.hasWifi) _AmenityChip(icon: Icons.wifi, label: 'Wi-Fi'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Courts
                  const Text(
                    'Campos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final court = club.courts[index];
                return _CourtCard(
                  name: court.name,
                  isIndoor: court.isIndoor,
                  hasLighting: court.hasLighting,
                  price: court.priceFormatted,
                  peakPrice: court.peakPriceFormatted,
                  onBook: () => context.push('/booking/${court.id}'),
                );
              },
              childCount: club.courts.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AmenityChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  final String name;
  final bool isIndoor;
  final bool hasLighting;
  final String price;
  final String peakPrice;
  final VoidCallback onBook;

  const _CourtCard({
    required this.name,
    required this.isIndoor,
    required this.hasLighting,
    required this.price,
    required this.peakPrice,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sports_tennis, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isIndoor)
                      _Tag(icon: Icons.home, label: 'Indoor')
                    else
                      _Tag(icon: Icons.wb_sunny, label: 'Outdoor'),
                    if (hasLighting) ...[
                      const SizedBox(width: 8),
                      _Tag(icon: Icons.lightbulb, label: 'Luz'),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              if (price != peakPrice)
                Text(
                  'Pico: $peakPrice',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                  const SizedBox(height: 8),
              SecondaryButton(
                label: 'Reservar',
                onPressed: onBook,
                icon: Icons.event_available,
                isExpanded: false,
                height: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Tag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
