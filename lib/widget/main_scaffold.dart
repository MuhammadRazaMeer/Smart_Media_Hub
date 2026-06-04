import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_media_hub/theme/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 600;
    final String location = GoRouterState.of(context).uri.path;

    int calculateSelectedIndex(String location) {
      if (location == '/') return 0;
      if (location == '/tools') return 1;
      if (location == '/auto') return 2;
      if (location == '/history') return 3;
      if (location == '/profile') return 4;
      return 0;
    }

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/tools');
          break;
        case 2:
          context.go('/auto');
          break;
        case 3:
          context.go('/history');
          break;
        case 4:
          context.go('/profile');
          break;
      }
    }

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: calculateSelectedIndex(location),
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.purplePrimary,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkMutedText
            : AppColors.lightMutedText,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          _buildNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
            isSelected: calculateSelectedIndex(location) == 0,
          ),
          _buildNavItem(
            icon: Icons.image_outlined,
            activeIcon: Icons.image_rounded,
            label: 'Tools',
            isSelected: calculateSelectedIndex(location) == 1,
          ),
          _buildNavItem(
            icon: Icons.auto_awesome_outlined,
            activeIcon: Icons.auto_awesome_rounded,
            label: 'Auto',
            isSelected: calculateSelectedIndex(location) == 2,
          ),
          _buildNavItem(
            icon: Icons.history_outlined,
            activeIcon: Icons.history_rounded,
            label: 'History',
            isSelected: calculateSelectedIndex(location) == 3,
          ),
          _buildNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
            isSelected: calculateSelectedIndex(location) == 4,
          ),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Transform.scale(
        scale: isSelected ? 1.15 : 1.0,
        child: Icon(isSelected ? activeIcon : icon),
      ),
      label: label,
    );
  }
}
