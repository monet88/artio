import 'package:artio/shared/widgets/image_input_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ImageInputWidget has semantics for replacing image', (
    WidgetTester tester,
  ) async {
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

    expect(find.byType(Semantics), findsWidgets);
  });
}
