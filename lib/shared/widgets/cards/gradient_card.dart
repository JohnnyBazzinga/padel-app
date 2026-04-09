import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final LinearGradient? gradient;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const GradientCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradient,
    this.width,
    this.height,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppDecorations.borderRadiusLg;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.cardGradient,
        borderRadius: radius,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: boxShadow,
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
  }
}
