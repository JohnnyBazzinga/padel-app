import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceBright,
          borderRadius: AppDecorations.borderRadiusFull,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: iconColor ?? AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectableChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;

  const SelectableChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMuted : AppColors.surfaceLight,
          borderRadius: AppDecorations.borderRadiusFull,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterChipGroup extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final Function(String) onSelected;
  final bool scrollable;

  const FilterChipGroup({
    super.key,
    required this.options,
    this.selected,
    required this.onSelected,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final chips = options.map((option) {
      return SelectableChip(
        label: option,
        isSelected: selected == option,
        onTap: () => onSelected(option),
      );
    }).toList();

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        child: Row(
          children: chips
              .map((chip) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: chip,
                  ))
              .toList(),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }
}
