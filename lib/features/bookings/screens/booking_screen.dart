import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/providers/bookings_provider.dart';
import '../../../shared/widgets/widgets.dart';

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
    final isReady = _selectedSlot != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Reservar'),
      body: Column(
        children: [
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              padding: const EdgeInsets.all(16),
              decoration: AppDecorations.glassCard,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: AppDecorations.borderRadiusSm,
                    ),
                    child: const Icon(Icons.calendar_today, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat('EEEE, d MMMM', 'pt_PT').format(_selectedDate),
                    style: AppTypography.bodyLarge,
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          ),
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
      bottomNavigationBar: isReady
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: const Border(top: BorderSide(color: AppColors.glassBorder)),
                  boxShadow: AppDecorations.shadowXs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total', style: AppTypography.labelMedium),
                          Text(
                            _selectedSlot!.priceFormatted,
                            style: AppTypography.statNumber.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Confirmar reserva',
                        isLoading: provider.isLoading,
                        onPressed: _confirmBooking,
                        isExpanded: true,
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
    final color = isSelected
        ? AppColors.primary
        : available
            ? AppColors.surface
            : AppColors.surfaceBright;

    final textColor = isSelected
        ? AppColors.background
        : available
            ? AppColors.textPrimary
            : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppDecorations.borderRadiusMd,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : available
                    ? AppColors.glassBorder
                    : AppColors.glassBorder.withOpacity(0.6),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              time,
              style: AppTypography.labelLarge.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              price,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected
                    ? AppColors.background.withOpacity(0.9)
                    : isPeak
                        ? AppColors.warning
                        : AppColors.textSecondary,
                fontWeight: isPeak ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
