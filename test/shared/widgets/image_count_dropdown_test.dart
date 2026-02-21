import 'package:artio/shared/widgets/image_count_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageCountDropdown', () {
    Widget buildWidget({int value = 1, ValueChanged<int>? onChanged}) {
      return MaterialApp(
        home: Scaffold(
          body: ImageCountDropdown(
            value: value,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Image Count'), findsOneWidget);
    });

    testWidgets('renders dropdown', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(DropdownButtonFormField<int>), findsOneWidget);
    });

    testWidgets('shows singular for 1 image', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('1 image'), findsOneWidget);
    });

    testWidgets('shows plural for multiple images', (tester) async {
      await tester.pumpWidget(buildWidget(value: 2));

      expect(find.text('2 images'), findsOneWidget);
    });

    testWidgets('dropdown contains options 1-4', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();

      // Dropdown shows selected item + menu items, so "1 image" appears twice
      expect(find.text('1 image'), findsAtLeast(1));
      expect(find.text('2 images'), findsOneWidget);
      expect(find.text('3 images'), findsOneWidget);
      expect(find.text('4 images'), findsOneWidget);
    });

    testWidgets('calls onChanged when selection made', (tester) async {
      int? selectedValue;
      await tester.pumpWidget(
        buildWidget(onChanged: (value) => selectedValue = value),
      );

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();

      // Tap on the text inside the dropdown menu overlay
      await tester.tap(find.text('3 images'));
      await tester.pumpAndSettle();

      expect(selectedValue, 3);
    });
  });
}
