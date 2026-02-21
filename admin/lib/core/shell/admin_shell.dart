import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Main shell layout with NavigationRail sidebar
class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _indexFromLocation(location);

    return Scaffold(
      body: Row(
        children: [
          // ── Sidebar ─────────────────────────────────────
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) => _onNavTap(context, index),
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: _buildLogo(context),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, size: 20),
                    tooltip: 'Logout',
                    onPressed: () => Supabase.instance.client.auth.signOut(),
                    color: isDark ? AdminColors.textMuted : Colors.grey,
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.style_outlined),
                selectedIcon: Icon(Icons.style_rounded),
                label: Text('Templates'),
              ),
            ],
          ),

          // ── Divider ─────────────────────────────────────
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: isDark ? AdminColors.borderSubtle : Colors.grey.shade200,
          ),

          // ── Content ─────────────────────────────────────
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AdminColors.primary, AdminColors.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'A',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Artio',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  int _indexFromLocation(String location) {
    if (location.startsWith('/templates')) return 1;
    return 0; // dashboard
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        context.go('/templates');
    }
  }
}
