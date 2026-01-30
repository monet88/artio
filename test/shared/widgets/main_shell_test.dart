import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:artio/shared/widgets/main_shell.dart';

void main() {
  group('MainShell', () {
    // Helper to build widget with GoRouter context
    Widget buildWidget({required Widget child, String initialLocation = '/home'}) {
      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainShell(child: child),
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => child,
              ),
              GoRoute(
                path: '/create',
                builder: (context, state) => child,
              ),
              GoRoute(
                path: '/gallery',
                builder: (context, state) => child,
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) => child,
              ),
            ],
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: router,
      );
    }

    testWidgets('renders bottom navigation bar', (tester) async {
      await tester.pumpWidget(
        buildWidget(child: const Text('Home Content')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('all 4 navigation destinations are present', (tester) async {
      await tester.pumpWidget(
        buildWidget(child: const Text('Home Content')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders Home icon', (tester) async {
      await tester.pumpWidget(
        buildWidget(child: const Text('Home Content')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('renders Create icon', (tester) async {
      await tester.pumpWidget(
        buildWidget(child: const Text('Home Content')),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_circle), findsOneWidget);
    });

    testWidgets('correct index selected for home route', (tester) async {
      await tester.pumpWidget(
        buildWidget(child: const Text('Content')),
      );
      await tester.pumpAndSettle();

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 0);
    });

    testWidgets('correct index selected for gallery route', (tester) async {
      await tester.pumpWidget(
        buildWidget(child: const Text('Content'), initialLocation: '/gallery'),
      );
      await tester.pumpAndSettle();

      final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(navBar.selectedIndex, 2);
    });
  });
}
