import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/shared/widgets/output_format_toggle.dart';

void main() {
  group('OutputFormatToggle', () {
    Widget buildWidget({
      String value = 'jpg',
      bool isPremium = false,
      ValueChanged<String>? onChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: OutputFormatToggle(
            value: value,
            isPremium: isPremium,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Output Format'), findsOneWidget);
    });

    testWidgets('renders segmented button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(SegmentedButton<String>), findsOneWidget);
    });

    testWidgets('shows JPG and PNG options', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('JPG'), findsOneWidget);
      expect(find.text('PNG'), findsOneWidget);
    });

    testWidgets('JPG is selected by default', (tester) async {
      await tester.pumpWidget(buildWidget(value: 'jpg'));

      final button = tester.widget<SegmentedButton<String>>(
        find.byType(SegmentedButton<String>),
      );
      expect(button.selected, {'jpg'});
    });

    testWidgets('shows crown emoji for PNG when not premium', (tester) async {
      await tester.pumpWidget(buildWidget(isPremium: false));

      // Crown emoji Unicode
      expect(find.text('\u{1F451}'), findsOneWidget);
    });

    testWidgets('does not show crown emoji for PNG when premium', (tester) async {
      await tester.pumpWidget(buildWidget(isPremium: true));

      expect(find.text('\u{1F451}'), findsNothing);
    });

    testWidgets('shows premium hint when not premium and JPG selected', (tester) async {
      await tester.pumpWidget(buildWidget(isPremium: false, value: 'jpg'));

      expect(find.text('PNG format requires premium'), findsOneWidget);
    });

    testWidgets('calls onChanged when JPG tapped', (tester) async {
      String? selectedFormat;
      await tester.pumpWidget(buildWidget(
        value: 'png',
        isPremium: true,
        onChanged: (format) => selectedFormat = format,
      ));

      await tester.tap(find.text('JPG'));
      await tester.pumpAndSettle();

      expect(selectedFormat, 'jpg');
    });

    testWidgets('calls onChanged when PNG tapped (premium user)', (tester) async {
      String? selectedFormat;
      await tester.pumpWidget(buildWidget(
        value: 'jpg',
        isPremium: true,
        onChanged: (format) => selectedFormat = format,
      ));

      await tester.tap(find.text('PNG'));
      await tester.pumpAndSettle();

      expect(selectedFormat, 'png');
    });

    testWidgets('does NOT call onChanged when PNG tapped (non-premium user)', (tester) async {
      String? selectedFormat;
      await tester.pumpWidget(buildWidget(
        value: 'jpg',
        isPremium: false,
        onChanged: (format) => selectedFormat = format,
      ));

      await tester.tap(find.text('PNG'));
      await tester.pumpAndSettle();

      // Should remain null - callback not triggered for disabled segment
      expect(selectedFormat, isNull);
    });
  });
}
