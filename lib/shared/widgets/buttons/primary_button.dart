import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final IconData? trailingIcon;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.trailingIcon,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;
    final buttonContent = Container(
      height: height ?? 52,
      decoration: BoxDecoration(
        color: isEnabled ? AppColors.primary : AppColors.textMuted.withOpacity(0.3),
        borderRadius: AppDecorations.borderRadiusMd,
        boxShadow: isEnabled
            ? AppDecorations.shadowGlow(AppColors.primary)
            : null,
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
                        color: isEnabled ? AppColors.background : AppColors.textMuted,
                      ),
                    )
                else ...[
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.background, size: 20),
                    AppSpacing.horizontalSm,
                  ],
                  Text(
                    label,
                    style: AppTypography.buttonText.copyWith(
                      color: isEnabled ? AppColors.background : AppColors.textMuted,
                    ),
                  ),
                  if (trailingIcon != null) ...[
                    AppSpacing.horizontalSm,
                    Icon(
                      trailingIcon,
                      color: isEnabled ? AppColors.background : AppColors.textMuted,
                      size: 20,
                    ),
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
