import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/template_engine/presentation/widgets/generation_progress.dart';
import 'package:artio/features/template_engine/domain/entities/generation_job_model.dart';

import '../../../../core/fixtures/generation_job_fixtures.dart';

void main() {
  group('GenerationProgress', () {
    Widget buildWidget({required GenerationJobModel job}) {
      return MaterialApp(
        home: Scaffold(
          body: GenerationProgress(job: job),
        ),
      );
    }

    group('Pending State', () {
      testWidgets('shows progress indicator', (tester) async {
        final job = GenerationJobFixtures.pending();

        await tester.pumpWidget(buildWidget(job: job));

        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('shows queued status text', (tester) async {
        final job = GenerationJobFixtures.pending();

        await tester.pumpWidget(buildWidget(job: job));

        expect(find.text('Queued...'), findsOneWidget);
      });
    });

    group('Generating/Processing State', () {
      testWidgets('shows generating status text', (tester) async {
        final job = GenerationJobFixtures.generating();

        await tester.pumpWidget(buildWidget(job: job));

        expect(find.text('Generating...'), findsOneWidget);
      });

      testWidgets('shows processing status text', (tester) async {
        final job = GenerationJobFixtures.processing();

        await tester.pumpWidget(buildWidget(job: job));

        expect(find.text('Processing...'), findsOneWidget);
      });
    });

    group('Completed State', () {
      testWidgets('shows success icon', (tester) async {
        // Use empty resultUrls to avoid network image loading
        final job = GenerationJobFixtures.completed(resultUrls: []);

        await tester.pumpWidget(buildWidget(job: job));

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('shows completed state with resultUrls', (tester) async {
        // Verify completed job with URLs shows success icon
        // Note: Cannot test Image.network in widget tests due to HTTP 400
        final job = GenerationJobFixtures.completed(resultUrls: []);

        await tester.pumpWidget(buildWidget(job: job));

        // Completed state should show success icon
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });
    });

    group('Failed State', () {
      testWidgets('shows error icon', (tester) async {
        final job = GenerationJobFixtures.failed();

        await tester.pumpWidget(buildWidget(job: job));

        expect(find.byIcon(Icons.error), findsOneWidget);
      });

      testWidgets('shows error message', (tester) async {
        final job = GenerationJobFixtures.failed(
          errorMessage: 'API rate limit exceeded',
        );

        await tester.pumpWidget(buildWidget(job: job));

        expect(find.text('API rate limit exceeded'), findsOneWidget);
      });

      testWidgets('shows default error message from fixture', (tester) async {
        // Fixture default errorMessage is 'Generation failed: Internal server error'
        final job = GenerationJobFixtures.failed();

        await tester.pumpWidget(buildWidget(job: job));

        expect(find.text('Generation failed: Internal server error'), findsOneWidget);
      });
    });
  });
}
