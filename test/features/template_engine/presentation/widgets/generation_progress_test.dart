import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';
import 'package:artio/features/template_engine/presentation/widgets/generation_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/fixtures/generation_job_fixtures.dart';

void main() {
  group('GenerationProgress', () {
    Widget buildWidget({required GenerationJobModel job}) {
      return MaterialApp(
        home: Scaffold(body: GenerationProgress(job: job)),
      );
    }

    group('Pending State', () {
      testWidgets('shows progress indicator', (tester) async {
        final job = GenerationJobFixtures.pending();

        await tester.pumpWidget(buildWidget(job: job));
        await tester.pump();

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('shows queued status text', (tester) async {
        final job = GenerationJobFixtures.pending();

        await tester.pumpWidget(buildWidget(job: job));
        await tester.pump();

        // Redesigned status text
        expect(find.text('Queued — waiting for your turn...'), findsOneWidget);
      });
    });

    group('Generating/Processing State', () {
      testWidgets('shows generating status text', (tester) async {
        final job = GenerationJobFixtures.generating();

        await tester.pumpWidget(buildWidget(job: job));
        await tester.pump();

        // Redesigned generating status text
        expect(find.text('Creating your masterpiece ✨'), findsOneWidget);
      });

      testWidgets('shows processing status text', (tester) async {
        final job = GenerationJobFixtures.processing();

        await tester.pumpWidget(buildWidget(job: job));
        await tester.pump();

        // Redesigned processing status text
        expect(
          find.text('Almost there — applying finishing touches...'),
          findsOneWidget,
        );
      });
    });

    group('Completed State', () {
      testWidgets('shows success icon', (tester) async {
        // Use empty resultUrls to avoid network image loading
        final job = GenerationJobFixtures.completed(resultUrls: []);

        await tester.pumpWidget(buildWidget(job: job));
        await tester.pump();

        // Redesigned — uses check_rounded inside gradient circle
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      });

      testWidgets('shows completed state with resultUrls', (tester) async {
        final job = GenerationJobFixtures.completed(resultUrls: []);

        await tester.pumpWidget(buildWidget(job: job));
        await tester.pump();

        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      });
    });

    group('Failed State', () {
      testWidgets('shows error icon', (tester) async {
        final job = GenerationJobFixtures.failed();

        await tester.pumpWidget(buildWidget(job: job));
        await tester.pump();

        // Redesigned — uses error_outline_rounded
        expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
      });

      testWidgets('shows error message', (tester) async {
        final job = GenerationJobFixtures.failed(
          errorMessage: 'API rate limit exceeded',
        );

        await tester.pumpWidget(buildWidget(job: job));
        await tester.pump();

        expect(find.text('API rate limit exceeded'), findsOneWidget);
      });

      testWidgets('shows default error message from fixture', (tester) async {
        final job = GenerationJobFixtures.failed();

        await tester.pumpWidget(buildWidget(job: job));
        await tester.pump();

        expect(
          find.text('Generation failed: Internal server error'),
          findsOneWidget,
        );
      });
    });
  });
}
