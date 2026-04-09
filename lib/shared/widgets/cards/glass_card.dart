import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool blurEnabled;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.blurEnabled = true,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppDecorations.borderRadiusLg;

    Widget content = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: radius,
        border: Border.all(color: AppColors.glassBorder, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? AppSpacing.cardPadding,
            child: child,
          ),
        ),
      ),
    );

    if (blurEnabled) {
      return ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: AppDecorations.blurFilter,
          child: content,
        ),
      );
    }

    return content;
  }
}
