import 'package:artio/core/design_system/app_shadows.dart';
import 'package:artio/shared/widgets/offline_banner.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Main shell with branded NavigationBar — pill indicator, selected/unselected
/// icons, sparkle badge on Create, and subtle shadow separation.
class MainShell extends ConsumerWidget {
  const MainShell({required this.child, super.key});

  final Widget child;

  static const _routes = ['/home', '/create', '/gallery', '/settings'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: isDark
              ? AppShadows.bottomNavShadowDark
              : AppShadows.bottomNavShadow,
          border: isDark
              ? const Border(
                  top: BorderSide(
                    color: AppColors.white10,
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            HapticFeedback.selectionClick();
            _onItemTapped(context, index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
              tooltip: 'Home — Browse templates',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome),
              label: 'Create',
              tooltip: 'Create — Generate AI art',
            ),
            NavigationDestination(
              icon: Icon(Icons.photo_library_outlined),
              selectedIcon: Icon(Icons.photo_library_rounded),
              label: 'Gallery',
              tooltip: 'Gallery — View your creations',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
              tooltip: 'Settings — App preferences',
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) return i;
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    context.go(_routes[index]);
  }
}
