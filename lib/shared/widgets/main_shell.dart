import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'offline_banner.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _routes = ['/home', '/create', '/gallery', '/settings'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: child),
        ],
      ),
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
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i])) return i;
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    context.go(_routes[index]);
  }
}
