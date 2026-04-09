import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/bookings_provider.dart';

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
      appBar: AppBar(title: const Text('Minhas Reservas')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.myBookings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 64, color: AppColors.textMuted),
                      SizedBox(height: 16),
                      Text('Sem reservas', style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.myBookings.length,
                  itemBuilder: (context, index) {
                    final booking = provider.myBookings[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  booking.clubName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              _StatusBadge(status: booking.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(booking.courtName, style: TextStyle(color: AppColors.textSecondary)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text(DateFormat('dd MMM yyyy', 'pt_PT').format(booking.date)),
                              const SizedBox(width: 16),
                              Icon(Icons.access_time, size: 16, color: AppColors.primary),
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
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              if (booking.status == 'CONFIRMED')
                                TextButton(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Cancelar reserva?'),
                                        content: const Text('Tens a certeza que queres cancelar esta reserva?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Não'),
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
                                  child: const Text('Cancelar', style: TextStyle(color: AppColors.error)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
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
        label = 'Concluída';
        break;
      default:
        color = AppColors.textMuted;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}
