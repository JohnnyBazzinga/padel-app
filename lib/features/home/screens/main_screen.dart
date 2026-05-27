import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/matches')) return 2;
    if (location.startsWith('/notifications')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/matches');
        break;
      case 3:
        context.go('/notifications');
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
      backgroundColor: AppColors.background,
      body: SafeArea(top: true, bottom: false, child: child),
      bottomNavigationBar: _InstagramBottomNavBar(
        selectedIndex: selectedIndex,
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}

class _InstagramBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _InstagramBottomNavBar({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppDecorations.borderRadiusXl,
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: AppDecorations.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _InstagramNavItem(
              icon: Icons.home_rounded,
              activeIcon: Icons.home_filled,
              label: 'Feed',
              isSelected: selectedIndex == 0,
              onTap: () => onTap(0),
            ),
          ),
          Expanded(
            child: _InstagramNavItem(
              icon: Icons.travel_explore_outlined,
              activeIcon: Icons.travel_explore_rounded,
              label: 'Buscar',
              isSelected: selectedIndex == 1,
              onTap: () => onTap(1),
            ),
          ),
          Expanded(
            child: _InstagramNavItem(
              icon: Icons.sports_tennis_outlined,
              activeIcon: Icons.sports_tennis_rounded,
              label: 'Partidas',
              isSelected: selectedIndex == 2,
              onTap: () => onTap(2),
            ),
          ),
          Expanded(
            child: _InstagramNavItem(
              icon: Icons.notifications_outlined,
              activeIcon: Icons.notifications_rounded,
              label: 'Notificações',
              isSelected: selectedIndex == 3,
              onTap: () => onTap(3),
            ),
          ),
          Expanded(
            child: _InstagramNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Perfil',
              isSelected: selectedIndex == 4,
              onTap: () => onTap(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _InstagramNavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _InstagramNavItem({
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: AppDecorations.borderRadiusFull,
          color: isSelected ? AppColors.surfaceBright : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey(isSelected ? '$label-active' : '$label'),
                color: isSelected ? AppColors.primary : AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
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

