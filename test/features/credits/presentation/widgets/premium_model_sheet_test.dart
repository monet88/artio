import 'package:artio/features/credits/presentation/widgets/premium_model_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildWidget({String modelName = 'FLUX Ultra'}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PremiumModelSheet(modelName: modelName),
        ),
      ),
    );
  }

  group('PremiumModelSheet', () {
    testWidgets('displays premium model name', (tester) async {
      await tester.pumpWidget(buildWidget(modelName: 'Midjourney v6'));

      expect(find.text('Premium model'), findsOneWidget);
      expect(
        find.textContaining('Midjourney v6 is available with a premium'),
        findsOneWidget,
      );
    });

    testWidgets('shows crown emoji', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('👑'), findsOneWidget);
    });

    testWidgets('shows Upgrade to Premium button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Upgrade to Premium'), findsOneWidget);
    });

    testWidgets('shows Dismiss button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Dismiss'), findsOneWidget);
    });
  });
}
