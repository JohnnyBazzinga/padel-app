import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;
  final Color? accentColor;
  final bool animate;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.accentColor,
    this.animate = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.borderRadiusLg,
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppDecorations.borderRadiusLg,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: AppDecorations.borderRadiusSm,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  AppSpacing.verticalMd,
                ],
                animate
                    ? _AnimatedStatValue(value: value, color: color)
                    : Text(
                        value,
                        style: AppTypography.statNumber.copyWith(color: color),
                      ),
                AppSpacing.verticalXs,
                Text(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedStatValue extends StatefulWidget {
  final String value;
  final Color color;

  const _AnimatedStatValue({
    required this.value,
    required this.color,
  });

  @override
  State<_AnimatedStatValue> createState() => _AnimatedStatValueState();
}

class _AnimatedStatValueState extends State<_AnimatedStatValue>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Try to parse as number for animation
    final numValue = int.tryParse(widget.value.replaceAll(RegExp(r'[^0-9]'), ''));

    if (numValue != null) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final animatedValue = (numValue * _animation.value).round();
          // Preserve suffix like % if present
          final suffix = widget.value.contains('%') ? '%' : '';
          return Text(
            '$animatedValue$suffix',
            style: AppTypography.statNumber.copyWith(color: widget.color),
          );
        },
      );
    }

    // Non-numeric value, just show it
    return Text(
      widget.value,
      style: AppTypography.statNumber.copyWith(color: widget.color),
    );
  }
}
