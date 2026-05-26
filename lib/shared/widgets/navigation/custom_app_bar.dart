import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final bool transparent;
  final Color? backgroundColor;
  final double elevation;
  final double toolbarHeight;
  final bool? showBackgroundLine;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPressed,
    this.bottom,
    this.elevation = 0,
    this.toolbarHeight = kToolbarHeight,
    this.transparent = false,
    this.backgroundColor,
    this.showBackgroundLine,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: transparent
          ? Colors.transparent
          : backgroundColor ?? AppColors.background,
      toolbarHeight: toolbarHeight,
      surfaceTintColor: Colors.transparent,
      elevation: elevation,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 12,
      bottom: bottom,
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
      shape: showBackgroundLine == false
          ? null
          : const Border(
              bottom: BorderSide(
                color: AppColors.glassBorder,
                width: 0.5,
              ),
            ),
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(toolbarHeight + bottomHeight);
  }
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
  final bool? showBottomGradient;

  const SliverCustomAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.expandedHeight = 220,
    this.background,
    this.actions,
    this.pinned = true,
    this.showBottomGradient,
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
              style: AppTypography.h3.copyWith(fontSize: 19),
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
            if (background != null)
              Positioned.fill(
                child: background!,
              ),
            if (showBottomGradient != false)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.background.withOpacity(0.45),
                      AppColors.background,
                    ],
                    stops: const [0.0, 0.65, 1.0],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
