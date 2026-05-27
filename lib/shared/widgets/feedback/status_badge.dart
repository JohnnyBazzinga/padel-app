import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

enum BadgeVariant {
  filled,
  outlined,
  soft,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final BadgeVariant variant;
  final IconData? icon;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.variant = BadgeVariant.soft,
    this.icon,
    this.fontSize,
  });

  // Factory constructors for common statuses
  factory StatusBadge.confirmed({String label = 'Confirmado'}) {
    return StatusBadge(
      label: label,
      color: AppColors.success,
      icon: Icons.check_circle_outline_rounded,
    );
  }

  factory StatusBadge.pending({String label = 'Pendente'}) {
    return StatusBadge(
      label: label,
      color: AppColors.warning,
      icon: Icons.access_time_rounded,
    );
  }

  factory StatusBadge.cancelled({String label = 'Cancelado'}) {
    return StatusBadge(
      label: label,
      color: AppColors.error,
      icon: Icons.cancel_outlined,
    );
  }

  factory StatusBadge.completed({String label = 'Concluído'}) {
    return StatusBadge(
      label: label,
      color: AppColors.info,
      icon: Icons.task_alt_rounded,
    );
  }

  factory StatusBadge.fromStatus(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'confirmado':
        return StatusBadge.confirmed();
      case 'pending':
      case 'pendente':
        return StatusBadge.pending();
      case 'cancelled':
      case 'cancelado':
        return StatusBadge.cancelled();
      case 'completed':
      case 'concluído':
        return StatusBadge.completed();
      default:
        return StatusBadge(label: status, color: AppColors.textMuted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: _getDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: _getTextColor(),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: _getTextColor(),
              fontSize: fontSize ?? 11,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (variant) {
      case BadgeVariant.filled:
        return BoxDecoration(
          color: color,
          borderRadius: AppDecorations.borderRadiusFull,
        );
      case BadgeVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: AppDecorations.borderRadiusFull,
          border: Border.all(color: color, width: 1.5),
        );
      case BadgeVariant.soft:
        return BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: AppDecorations.borderRadiusFull,
        );
    }
  }

  Color _getTextColor() {
    switch (variant) {
      case BadgeVariant.filled:
        return Colors.white;
      case BadgeVariant.outlined:
      case BadgeVariant.soft:
        return color;
    }
  }
}

class LevelBadge extends StatelessWidget {
  final String level;

  const LevelBadge({
    super.key,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return StatusBadge(
      label: level,
      color: AppColors.getSkillColor(level),
      variant: BadgeVariant.soft,
    );
  }
}

class RankBadge extends StatelessWidget {
  final String tier;
  final int? position;

  const RankBadge({
    super.key,
    required this.tier,
    this.position,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getRankColor(tier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: AppDecorations.borderRadiusFull,
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (position != null) ...[
            Text(
              '#$position',
              style: AppTypography.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            tier,
            style: AppTypography.labelSmall.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
