import 'package:artio/shared/widgets/image_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  testWidgets('ImageInputWidget exposes semantics for selecting an image', (
    WidgetTester tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageInputWidget(
              label: 'Test',
              isRequired: false,
              onChanged: (_) {},
              // we'll test the placeholder
            ),
          ),
        ),
      );

      final node = tester.getSemantics(find.byType(GestureDetector));
      expect(node.label, contains('Tap to select image'));
      expect(node.flagsCollection.isButton, isTrue);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets(
    'ImageInputWidget keeps tooltip and semantics for replacing image',
    (WidgetTester tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: ImageInputWidget(
                  label: 'Test',
                  isRequired: false,
                  file: XFile('assets/feature.png'),
                  onChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        expect(find.byTooltip('Tap to replace image'), findsOneWidget);
        final node = tester.getSemantics(find.byType(GestureDetector).first);
        expect(node.label, contains('Tap to replace image'));
        expect(node.flagsCollection.isButton, isTrue);
      } finally {
        semantics.dispose();
      }
    },
  );
}
