import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/shared/widgets/aspect_ratio_selector.dart';

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

    testWidgets('shows More button when more options available', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('expands to show all ratios when More tapped', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      expect(find.text('Less'), findsOneWidget);
      expect(find.text('2:3'), findsOneWidget);
      expect(find.text('3:2'), findsOneWidget);
    });

    testWidgets('collapses when Less tapped', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Less'));
      await tester.pumpAndSettle();

      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('selected ratio is highlighted', (tester) async {
      await tester.pumpWidget(buildWidget(selectedRatio: '4:3'));

      final chip = tester.widget<ChoiceChip>(
        find.ancestor(
          of: find.text('4:3'),
          matching: find.byType(ChoiceChip),
        ),
      );
      expect(chip.selected, isTrue);
    });

    testWidgets('calls onChanged when ratio tapped', (tester) async {
      String? selectedRatio;
      await tester.pumpWidget(buildWidget(
        onChanged: (ratio) => selectedRatio = ratio,
      ));

      await tester.tap(find.text('16:9'));
      await tester.pumpAndSettle();

      expect(selectedRatio, '16:9');
    });

    testWidgets('filters ratios based on selected model (GPT)', (tester) async {
      await tester.pumpWidget(buildWidget(
        selectedModelId: 'gpt-image/1.5-text-to-image',
      ));

      // GPT only supports 1:1, 2:3, 3:2
      expect(find.text('1:1'), findsOneWidget);
      // 16:9 not in GPT supported ratios
      expect(find.text('16:9'), findsNothing);
    });
  });
}
