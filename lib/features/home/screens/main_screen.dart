import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/clubs')) return 1;
    if (location.startsWith('/matches')) return 2;
    if (location.startsWith('/rankings')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/clubs');
        break;
      case 2:
        context.go('/matches');
        break;
      case 3:
        context.go('/rankings');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      extendBody: true,
      bottomNavigationBar: _FloatingNavBar(
        selectedIndex: selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _FloatingNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.borderRadiusXl,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Início',
              isSelected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavItem(
              icon: Icons.location_city_outlined,
              activeIcon: Icons.location_city_rounded,
              label: 'Clubes',
              isSelected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
            _CenterNavButton(
              isSelected: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
            _NavItem(
              icon: Icons.leaderboard_outlined,
              activeIcon: Icons.leaderboard_rounded,
              label: 'Ranking',
              isSelected: selectedIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Perfil',
              isSelected: selectedIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMuted : Colors.transparent,
          borderRadius: AppDecorations.borderRadiusMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected),
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 10,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterNavButton extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _CenterNavButton({
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: AppDecorations.shadowGlow(
            AppColors.primary,
            intensity: isSelected ? 0.4 : 0.25,
          ),
        ),
        child: Icon(
          Icons.sports_tennis_rounded,
          color: AppColors.background,
          size: 26,
        ),
      ),
    );
  }
}
