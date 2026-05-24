import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/tournaments_provider.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TournamentsProvider>().fetchTournaments();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TournamentsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Torneios')),
      floatingActionButton: auth.canCreateTournaments
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/tournaments/create'),
              icon: const Icon(Icons.add),
              label: const Text('Criar torneio'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchTournaments(),
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.tournaments.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events_outlined, size: 64, color: AppColors.textMuted),
                        SizedBox(height: 16),
                        Text('Sem torneios disponíveis', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.tournaments.length,
                    itemBuilder: (context, index) {
                      final t = provider.tournaments[index];
                      return _TournamentCard(
                        name: t.name,
                        club: t.clubName,
                        city: t.clubCity,
                        date: '${DateFormat('dd MMM').format(t.startDate)} - ${DateFormat('dd MMM').format(t.endDate)}',
                        entryFee: t.entryFeeFormatted,
                        spotsLeft: t.spotsLeft,
                        status: t.status,
                        imageUrl: t.imageUrl,
                        onTap: () => context.push('/tournaments/${t.id}'),
                      );
                    },
                  ),
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final String name;
  final String club;
  final String city;
  final String date;
  final String entryFee;
  final int spotsLeft;
  final String status;
  final String? imageUrl;
  final VoidCallback onTap;

  const _TournamentCard({
    required this.name,
    required this.club,
    required this.city,
    required this.date,
    required this.entryFee,
    required this.spotsLeft,
    required this.status,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: imageUrl != null
                    ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: imageUrl == null
                  ? const Center(child: Icon(Icons.emoji_events, size: 48, color: AppColors.accent))
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      _StatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('$club • $city', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(date),
                      const Spacer(),
                      Text(entryFee, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                  if (status == 'REGISTRATION_OPEN') ...[
                    const SizedBox(height: 8),
                    Text(
                      '$spotsLeft vagas disponíveis',
                      style: TextStyle(color: spotsLeft <= 4 ? AppColors.warning : AppColors.success, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (status) {
      case 'REGISTRATION_OPEN':
        color = AppColors.success;
        label = 'Inscrições abertas';
        break;
      case 'IN_PROGRESS':
        color = AppColors.info;
        label = 'A decorrer';
        break;
      case 'COMPLETED':
        color = AppColors.textMuted;
        label = 'Terminado';
        break;
      default:
        color = AppColors.warning;
        label = 'Brevemente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}
