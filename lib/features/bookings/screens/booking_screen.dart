import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/bookings_provider.dart';

class BookingScreen extends StatefulWidget {
  final String courtId;
  final String? date;

  const BookingScreen({super.key, required this.courtId, this.date});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime _selectedDate;
  TimeSlot? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.date != null
        ? DateTime.parse(widget.date!)
        : DateTime.now();
    _loadAvailability();
  }

  void _loadAvailability() {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    context.read<BookingsProvider>().fetchCourtAvailability(widget.courtId, dateStr);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null;
      });
      _loadAvailability();
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedSlot == null) return;

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final booking = await context.read<BookingsProvider>().createBooking(
      courtId: widget.courtId,
      date: dateStr,
      startTime: _selectedSlot!.startTime,
      endTime: _selectedSlot!.endTime,
    );

    if (booking != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reserva confirmada!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/my-bookings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Reservar')),
      body: Column(
        children: [
          // Date selector
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, d MMMM', 'pt_PT').format(_selectedDate),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
          // Time slots
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: provider.availability.length,
                    itemBuilder: (context, index) {
                      final slot = provider.availability[index];
                      final isSelected = _selectedSlot == slot;
                      return _TimeSlotCard(
                        time: slot.startTime,
                        price: slot.priceFormatted,
                        isPeak: slot.isPeak,
                        available: slot.available,
                        isSelected: isSelected,
                        onTap: slot.available
                            ? () => setState(() => _selectedSlot = slot)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedSlot != null
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total', style: TextStyle(color: AppColors.textSecondary)),
                        Text(
                          _selectedSlot!.priceFormatted,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _confirmBooking,
                        child: const Text('Confirmar Reserva'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _TimeSlotCard extends StatelessWidget {
  final String time;
  final String price;
  final bool isPeak;
  final bool available;
  final bool isSelected;
  final VoidCallback? onTap;

  const _TimeSlotCard({
    required this.time,
    required this.price,
    required this.isPeak,
    required this.available,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : available
                  ? AppColors.card
                  : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : available
                    ? AppColors.surfaceLight
                    : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? Colors.white
                    : available
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : available
                        ? (isPeak ? AppColors.warning : AppColors.textSecondary)
                        : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
