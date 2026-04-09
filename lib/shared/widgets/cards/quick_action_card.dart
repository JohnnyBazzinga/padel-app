import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? accentColor;
  final LinearGradient? gradient;

  const QuickActionCard({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.accentColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.primary;

    return Container(
      width: 110,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: gradient ??
                        LinearGradient(
                          colors: [
                            color.withOpacity(0.2),
                            color.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                    borderRadius: AppDecorations.borderRadiusMd,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                AppSpacing.verticalMd,
                Text(
                  label,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  AppSpacing.verticalXxs,
                  Text(
                    subtitle!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
