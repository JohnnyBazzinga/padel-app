import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final IconData? trailingIcon;
  final Color? color;
  final double? height;

  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.trailingIcon,
    this.color,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;

    final buttonContent = Container(
      height: height ?? 52,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppDecorations.borderRadiusMd,
        border: Border.all(
          color: buttonColor,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: AppDecorations.borderRadiusMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: buttonColor,
                    ),
                  )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, color: buttonColor, size: 20),
                    AppSpacing.horizontalSm,
                  ],
                  Text(
                    label,
                    style: AppTypography.buttonText.copyWith(
                      color: buttonColor,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    AppSpacing.horizontalSm,
                    Icon(trailingIcon, color: buttonColor, size: 20),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return isExpanded
        ? buttonContent
        : IntrinsicWidth(child: buttonContent);
  }
}
