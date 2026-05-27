import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavBarItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.borderRadiusXl,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: AppDecorations.shadowMd,
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];

            // Center button (special styling)
            if (item.isCenter) {
              return _CenterNavButton(
                icon: item.icon,
                isActive: currentIndex == index,
                onTap: () => onTap(index),
              );
            }

            return _NavItem(
              icon: item.icon,
              activeIcon: item.activeIcon,
              label: item.label,
              isActive: currentIndex == index,
              badge: item.badge,
              onTap: () => onTap(index),
            );
          }),
        ),
      ),
    );
  }
}

class NavBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isCenter;
  final String? badge;

  const NavBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.isCenter = false,
    this.badge,
  });
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final String? badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.isActive,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryMuted : Colors.transparent,
          borderRadius: AppDecorations.borderRadiusMd,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isActive ? (activeIcon ?? icon) : icon,
                    key: ValueKey(isActive),
                    color: isActive ? AppColors.primary : AppColors.textMuted,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isActive ? AppColors.primary : AppColors.textMuted,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
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
        ),
      ),
    );
  }
}

class _CenterNavButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _CenterNavButton({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.textPrimary,
            shape: BoxShape.circle,
            boxShadow: AppDecorations.shadowGlow(
              isActive ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
