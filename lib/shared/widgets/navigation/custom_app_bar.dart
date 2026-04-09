import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool transparent;
  final Color? backgroundColor;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.transparent = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: transparent
          ? Colors.transparent
          : backgroundColor ?? AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      leading: leading ??
          (showBackButton && Navigator.canPop(context)
              ? _BackButton(onPressed: onBackPressed)
              : null),
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: AppTypography.h3,
                )
              : null),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _BackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _BackButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: AppDecorations.borderRadiusMd,
            border: Border.all(color: AppColors.glassBorder, width: 1),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed ?? () => Navigator.pop(context),
              borderRadius: AppDecorations.borderRadiusMd,
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SliverCustomAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double expandedHeight;
  final Widget? background;
  final List<Widget>? actions;
  final bool pinned;

  const SliverCustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.expandedHeight = 200,
    this.background,
    this.actions,
    this.pinned = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      backgroundColor: AppColors.background,
      leading: Navigator.canPop(context)
          ? Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.glassFill,
                    borderRadius: AppDecorations.borderRadiusMd,
                    border: Border.all(color: AppColors.glassBorder, width: 1),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: AppDecorations.borderRadiusMd,
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.h3.copyWith(fontSize: 18),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
              ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (background != null) background!,
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.background.withOpacity(0.5),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
