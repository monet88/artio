import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routing/route_paths.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(context, index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: 'Create'),
          NavigationDestination(
              icon: Icon(Icons.photo_library), label: 'Gallery'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(RoutePaths.home)) return 0;
    if (location.startsWith(RoutePaths.create)) return 1;
    if (location.startsWith(RoutePaths.gallery)) return 2;
    if (location.startsWith(RoutePaths.settings)) return 3;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    const routes = [
      RoutePaths.home,
      RoutePaths.create,
      RoutePaths.gallery,
      RoutePaths.settings
    ];
    context.go(routes[index]);
  }
}
