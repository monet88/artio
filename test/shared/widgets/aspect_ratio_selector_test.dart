import 'package:artio/shared/widgets/aspect_ratio_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AspectRatioSelector', () {
    Widget buildWidget({
      String selectedRatio = '1:1',
      String selectedModelId = 'google/imagen4',
      ValueChanged<String>? onChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AspectRatioSelector(
            selectedRatio: selectedRatio,
            selectedModelId: selectedModelId,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      );
    }

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Aspect Ratio'), findsOneWidget);
    });

    testWidgets('renders primary aspect ratios by default', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('1:1'), findsOneWidget);
      expect(find.text('4:3'), findsOneWidget);
      expect(find.text('3:4'), findsOneWidget);
      expect(find.text('16:9'), findsOneWidget);
      expect(find.text('9:16'), findsOneWidget);
    });

    testWidgets('hides More button when all ratios fit in primary set', (
      tester,
    ) async {
      // Universal ratio list has exactly 5 entries = same as primary ratios
      await tester.pumpWidget(buildWidget());

      expect(find.text('More'), findsNothing);
    });

    testWidgets('selected ratio is highlighted', (tester) async {
      await tester.pumpWidget(buildWidget(selectedRatio: '4:3'));

      final chip = tester.widget<ChoiceChip>(
        find.ancestor(of: find.text('4:3'), matching: find.byType(ChoiceChip)),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('calls onChanged when ratio tapped', (tester) async {
      String? selectedRatio;
      await tester.pumpWidget(
        buildWidget(onChanged: (ratio) => selectedRatio = ratio),
      );

      await tester.tap(find.text('16:9'));
      await tester.pumpAndSettle();

      expect(selectedRatio, '16:9');
    });

    testWidgets('all models share universal aspect ratios', (tester) async {
      // GPT uses server-side ratio mapping, client shows all 5 universal ratios
      await tester.pumpWidget(
        buildWidget(selectedModelId: 'gpt-image/1.5-text-to-image'),
      );

      expect(find.text('1:1'), findsOneWidget);
      expect(find.text('16:9'), findsOneWidget);
    });
  });
}
