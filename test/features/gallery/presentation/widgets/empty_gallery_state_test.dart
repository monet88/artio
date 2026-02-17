import 'package:artio/features/gallery/presentation/widgets/empty_gallery_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('EmptyGalleryState', () {
    Widget buildWidget() {
      // Wrap in GoRouter to satisfy HomeRoute().go(context)
      final router = GoRouter(
        initialLocation: '/gallery',
        routes: [
          GoRoute(
            path: '/gallery',
            builder: (context, state) => const Scaffold(
              body: EmptyGalleryState(),
            ),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const Scaffold(
              body: Text('Home'),
            ),
          ),
        ],
      );

      return MaterialApp.router(
        routerConfig: router,
      );
    }

    testWidgets('renders empty message', (tester) async {
      await tester.pumpWidget(buildWidget());
      // Pump past initial animation delays (fade + scale enter)
      await tester.pump(const Duration(milliseconds: 500));

      // Redesigned title
      expect(find.text('Your Gallery is Empty'), findsOneWidget);
    });

    testWidgets('renders illustration icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 500));

      // Redesigned illustration uses photo_library_outlined
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 500));

      // Redesigned subtitle with line break
      expect(
        find.text(
          'Create your first AI-generated artwork\nand it will appear here',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders Start Creating button', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump(const Duration(milliseconds: 500));

      // GradientCTAButton with auto_awesome icon and 'Start Creating' label
      expect(find.text('Start Creating'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsWidgets);
    });
  });
}
