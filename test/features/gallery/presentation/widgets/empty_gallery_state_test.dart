import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/gallery/presentation/widgets/empty_gallery_state.dart';

void main() {
  group('EmptyGalleryState', () {
    Widget buildWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: EmptyGalleryState(),
        ),
      );
    }

    testWidgets('renders empty message', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('No images yet'), findsOneWidget);
    });

    testWidgets('renders icon', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Start generating to see your creations here'), findsOneWidget);
    });

    testWidgets('renders Create New button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Create New'), findsOneWidget);
      expect(find.byIcon(Icons.add_photo_alternate_outlined), findsOneWidget);
    });
  });
}
