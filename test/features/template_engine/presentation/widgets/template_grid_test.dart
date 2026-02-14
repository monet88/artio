import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/template_engine/presentation/widgets/template_grid.dart';
import 'package:artio/features/template_engine/presentation/providers/template_provider.dart';
import 'package:artio/features/template_engine/domain/entities/template_model.dart';

import '../../../../core/fixtures/template_fixtures.dart';

/// Helper to wrap TemplateGrid (which returns slivers) inside a CustomScrollView.
Widget _buildTestHarness({required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: const MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          slivers: [
            TemplateGrid(),
          ],
        ),
      ),
    ),
  );
}

void main() {
  group('TemplateGrid', () {
    testWidgets('renders grid with templates', (tester) async {
      final templates = TemplateFixtures.list(count: 4);

      await tester.pumpWidget(
        _buildTestHarness(
          overrides: [
            templatesProvider.overrideWith((ref) => Future.value(templates)),
          ],
        ),
      );
      await tester.pump();

      // SliverGrid is used internally; verify cards render
      expect(find.byType(SliverGrid), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      // Use Completer that never completes to avoid pending timer issues
      final completer = Completer<List<TemplateModel>>();

      await tester.pumpWidget(
        _buildTestHarness(
          overrides: [
            templatesProvider.overrideWith((ref) => completer.future),
          ],
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no templates', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          overrides: [
            templatesProvider.overrideWith((ref) => Future.value([])),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('No templates available'), findsOneWidget);
    });

    testWidgets('shows error state on error', (tester) async {
      await tester.pumpWidget(
        _buildTestHarness(
          overrides: [
            templatesProvider.overrideWith(
              (ref) => Future.error(Exception('Network error')),
            ),
          ],
        ),
      );
      await tester.pump();

      // AppExceptionMapper converts non-AppException to generic message
      expect(find.text('An unexpected error occurred. Please try again.'), findsOneWidget);
    });
  });
}
