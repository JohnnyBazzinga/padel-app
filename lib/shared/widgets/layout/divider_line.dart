import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class DividerLine extends StatelessWidget {
  final double? height;
  final Color? color;
  final EdgeInsets? margin;

  const DividerLine({
    super.key,
    this.height,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 1,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 16),
      color: color ?? AppColors.glassBorder,
    );
  }
}

class DividerWithText extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? lineColor;
  final EdgeInsets? margin;

  const DividerWithText({
    super.key,
    required this.text,
    this.textColor,
    this.lineColor,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final dividerColor = lineColor ?? AppColors.glassBorder;

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: dividerColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: textColor ?? AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}
