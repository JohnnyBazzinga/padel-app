import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/bookings_provider.dart';
import '../../../shared/widgets/widgets.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingsProvider>().fetchMyBookings();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Minhas Reservas'),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.myBookings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64,
                        color: AppColors.textMuted,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Sem reservas',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.myBookings.length,
                  itemBuilder: (context, index) {
                    final booking = provider.myBookings[index];
                    return _BookingCard(
                      booking: booking,
                      onCancel: () async {
                        if (booking.status != 'CONFIRMED') return;

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Cancelar reserva?'),
                            content: const Text(
                              'Tens a certeza que queres cancelar esta reserva?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Nao'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Sim, cancelar'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await provider.cancelBooking(booking.id);
                        }
                      },
                    );
                  },
                ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final dynamic booking;
  final Future<void> Function() onCancel;

  const _BookingCard({
    required this.booking,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd MMM yyyy', 'pt_PT').format(booking.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.glassCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.clubName,
                  style: AppTypography.h4,
                ),
              ),
              _StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            booking.courtName,
            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(dateLabel),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('${booking.startTime} - ${booking.endTime}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.priceFormatted,
                style: AppTypography.h3.copyWith(
                  color: AppColors.primary,
                  fontSize: 24,
                ),
              ),
              if (booking.status == 'CONFIRMED')
                GhostButton(
                  label: 'Cancelar',
                  icon: Icons.close,
                  color: AppColors.error,
                  onPressed: onCancel,
                  isExpanded: false,
                ),
            ],
          ),
        ],
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
      case 'CONFIRMED':
        color = AppColors.success;
        label = 'Confirmada';
        break;
      case 'PENDING':
        color = AppColors.warning;
        label = 'Pendente';
        break;
      case 'CANCELLED':
        color = AppColors.error;
        label = 'Cancelada';
        break;
      case 'COMPLETED':
        color = AppColors.textMuted;
        label = 'Concluida';
        break;
      default:
        color = AppColors.textMuted;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppDecorations.borderRadiusFull,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}
