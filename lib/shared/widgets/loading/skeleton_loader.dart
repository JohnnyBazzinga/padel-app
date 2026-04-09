import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/theme.dart';

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isCircle;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceLight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: isCircle ? null : (borderRadius ?? AppDecorations.borderRadiusMd),
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;
  final EdgeInsets? margin;

  const SkeletonCard({
    super.key,
    this.height = 120,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceLight,
      child: Container(
        height: height,
        margin: margin ?? const EdgeInsets.only(bottom: AppSpacing.cardGap),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDecorations.borderRadiusLg,
        ),
      ),
    );
  }
}

class SkeletonListItem extends StatelessWidget {
  final bool showAvatar;
  final bool showSubtitle;
  final EdgeInsets? margin;

  const SkeletonListItem({
    super.key,
    this.showAvatar = true,
    this.showSubtitle = true,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceLight,
      child: Padding(
        padding: margin ?? const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (showAvatar) ...[
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                ),
              ),
              AppSpacing.horizontalMd,
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppDecorations.borderRadiusSm,
                    ),
                  ),
                  if (showSubtitle) ...[
                    AppSpacing.verticalSm,
                    Container(
                      height: 12,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppDecorations.borderRadiusSm,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonMatchCard extends StatelessWidget {
  const SkeletonMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceLight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppDecorations.borderRadiusLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 24,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: AppDecorations.borderRadiusFull,
                  ),
                ),
                Container(
                  height: 24,
                  width: 70,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: AppDecorations.borderRadiusFull,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalLg,
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: AppDecorations.borderRadiusSm,
                  ),
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 18,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: AppDecorations.borderRadiusSm,
                        ),
                      ),
                      AppSpacing.verticalXs,
                      Container(
                        height: 14,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: AppDecorations.borderRadiusSm,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            AppSpacing.verticalLg,
            Container(
              height: 1,
              color: AppColors.surfaceLight,
            ),
            AppSpacing.verticalLg,
            Row(
              children: [
                SizedBox(
                  width: 60,
                  height: 32,
                  child: Stack(
                    children: List.generate(3, (i) {
                      return Positioned(
                        left: i * 18.0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                AppSpacing.horizontalMd,
                Container(
                  height: 14,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: AppDecorations.borderRadiusSm,
                  ),
                ),
                const Spacer(),
                Container(
                  height: 24,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: AppDecorations.borderRadiusFull,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonStatCards extends StatelessWidget {
  final int count;

  const SkeletonStatCards({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceLight,
      child: Row(
        children: List.generate(count, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: index < count - 1 ? AppSpacing.cardGap : 0,
              ),
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppDecorations.borderRadiusLg,
              ),
            ),
          );
        }),
      ),
    );
  }
}
