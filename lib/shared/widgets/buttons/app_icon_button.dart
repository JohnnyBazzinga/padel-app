import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

enum AppIconButtonVariant {
  filled,
  outlined,
  ghost,
  glass,
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final AppIconButtonVariant variant;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final String? badge;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.variant = AppIconButtonVariant.ghost,
    this.color,
    this.backgroundColor,
    this.size = 44,
    this.iconSize = 22,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? _getIconColor();
    final bgColor = backgroundColor ?? _getBackgroundColor();
    final border = _getBorder();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppDecorations.borderRadiusMd,
            border: border,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: AppDecorations.borderRadiusMd,
              child: Center(
                child: Icon(
                  icon,
                  color: iconColor,
                  size: iconSize,
                ),
              ),
            ),
          ),
        ),
        if (badge != null)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: AppDecorations.borderRadiusFull,
              ),
              child: Text(
                badge!,
                style: AppTypography.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _getIconColor() {
    switch (variant) {
      case AppIconButtonVariant.filled:
        return AppColors.background;
      case AppIconButtonVariant.outlined:
        return AppColors.primary;
      case AppIconButtonVariant.ghost:
        return AppColors.textPrimary;
      case AppIconButtonVariant.glass:
        return AppColors.textPrimary;
    }
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case AppIconButtonVariant.filled:
        return AppColors.primary;
      case AppIconButtonVariant.outlined:
        return Colors.transparent;
      case AppIconButtonVariant.ghost:
        return Colors.transparent;
      case AppIconButtonVariant.glass:
        return AppColors.glassFill;
    }
  }

  Border? _getBorder() {
    switch (variant) {
      case AppIconButtonVariant.outlined:
        return Border.all(color: AppColors.primary, width: 1.5);
      case AppIconButtonVariant.glass:
        return Border.all(color: AppColors.glassBorder, width: 1);
      default:
        return null;
    }
  }
}
