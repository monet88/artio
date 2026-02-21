import 'package:artio/shared/widgets/model_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ModelSelector', () {
    Widget buildWidget({
      String selectedModelId = 'google/imagen4',
      bool isPremium = false,
      ValueChanged<String>? onChanged,
      String? filterByType,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ModelSelector(
            selectedModelId: selectedModelId,
            isPremium: isPremium,
            onChanged: onChanged ?? (_) {},
            filterByType: filterByType,
          ),
        ),
      );
    }

    testWidgets('renders title with info icon', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Model'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('renders dropdown', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('shows selected model name', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Imagen 4'), findsOneWidget);
    });

    testWidgets('shows diamond emoji for credits', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Diamond emoji
      expect(find.text('\u{1F48E}'), findsWidgets);
    });

    testWidgets('shows credit cost', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Imagen 4 costs 6 credits
      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('dropdown contains all models', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Imagen 4'), findsWidgets);
      expect(find.text('Imagen 4 Fast'), findsOneWidget);
    });

    testWidgets('shows crown emoji for premium models', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Crown emoji for premium models
      expect(find.text('\u{1F451}'), findsWidgets);
    });

    testWidgets('shows NEW badge for new models', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Nano Banana Edit is marked as new
      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('premium models are disabled for non-premium users', (
      tester,
    ) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Find Imagen 4 Ultra (premium model) dropdown item
      final premiumItem = find.ancestor(
        of: find.text('Imagen 4 Ultra'),
        matching: find.byType(DropdownMenuItem<String>),
      );
      expect(premiumItem, findsOneWidget);

      final item = tester.widget<DropdownMenuItem<String>>(premiumItem);
      expect(item.enabled, isFalse);
    });

    testWidgets('premium models are enabled for premium users', (tester) async {
      await tester.pumpWidget(buildWidget(isPremium: true));

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      final premiumItem = find.ancestor(
        of: find.text('Imagen 4 Ultra'),
        matching: find.byType(DropdownMenuItem<String>),
      );

      final item = tester.widget<DropdownMenuItem<String>>(premiumItem);
      expect(item.enabled, isTrue);
    });

    testWidgets('filters by type when filterByType provided', (tester) async {
      await tester.pumpWidget(buildWidget(filterByType: 'text-to-image'));

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Text-to-image models should be present
      expect(find.text('Imagen 4'), findsWidgets);
      expect(find.text('Flux-2 Flex'), findsOneWidget);

      // Image-to-image models should NOT be present
      expect(find.text('Flux-2 Flex Edit'), findsNothing);
    });

    testWidgets('calls onChanged when model selected', (tester) async {
      String? selectedModel;
      await tester.pumpWidget(
        buildWidget(
          isPremium: true,
          onChanged: (model) => selectedModel = model,
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Imagen 4 Fast').last);
      await tester.pumpAndSettle();

      expect(selectedModel, 'google/imagen4-fast');
    });
  });
}
