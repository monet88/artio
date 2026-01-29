import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/template_engine/presentation/widgets/template_grid.dart';
import 'package:artio/features/template_engine/presentation/providers/template_provider.dart';
import 'package:artio/features/template_engine/domain/entities/template_model.dart';

import '../../../../core/fixtures/template_fixtures.dart';

void main() {
  group('TemplateGrid', () {
    testWidgets('renders grid with templates', (tester) async {
      final templates = TemplateFixtures.list(count: 4);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            templatesProvider.overrideWith((ref) => Future.value(templates)),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TemplateGrid(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            templatesProvider.overrideWith((ref) => Future.delayed(
              const Duration(days: 1),
              () => TemplateFixtures.list(count: 1),
            )),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TemplateGrid(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no templates', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            templatesProvider.overrideWith((ref) => Future.value([])),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TemplateGrid(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('No templates available'), findsOneWidget);
    });

    testWidgets('shows error state on error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            templatesProvider.overrideWith(
              (ref) => Future.error('Failed to load'),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TemplateGrid(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Failed to load'), findsOneWidget);
    });
  });
}
