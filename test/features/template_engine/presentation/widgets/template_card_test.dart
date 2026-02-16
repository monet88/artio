import 'package:artio/features/template_engine/presentation/widgets/template_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../core/fixtures/template_fixtures.dart';
import '../../../../core/helpers/pump_app.dart';

void main() {
  group('TemplateCard', () {
    testWidgets('renders template name', (tester) async {
      final template = TemplateFixtures.basic(name: 'Test Template');

      await tester.pumpApp(
        SizedBox(
          height: 200,
          width: 150,
          child: TemplateCard(template: template),
        ),
      );

      expect(find.text('Test Template'), findsOneWidget);
    });

    testWidgets('renders template thumbnail', (tester) async {
      final template = TemplateFixtures.basic();

      await tester.pumpApp(
        SizedBox(
          height: 200,
          width: 150,
          child: TemplateCard(template: template),
        ),
      );

      // Uses CachedNetworkImage which renders Image internally
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows PRO badge for premium templates', (tester) async {
      final template = TemplateFixtures.premium(name: 'Premium Template');

      await tester.pumpApp(
        SizedBox(
          height: 200,
          width: 150,
          child: TemplateCard(template: template),
        ),
      );

      expect(find.text('PRO'), findsOneWidget);
    });

    testWidgets('does not show PRO badge for free templates', (tester) async {
      final template = TemplateFixtures.basic(name: 'Free Template');

      await tester.pumpApp(
        SizedBox(
          height: 200,
          width: 150,
          child: TemplateCard(template: template),
        ),
      );

      expect(find.text('PRO'), findsNothing);
    });

    testWidgets('card is tappable (GestureDetector exists)', (tester) async {
      final template = TemplateFixtures.basic();

      await tester.pumpApp(
        SizedBox(
          height: 200,
          width: 150,
          child: TemplateCard(template: template),
        ),
      );

      // Redesigned card uses GestureDetector for tap animation
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('truncates long template names', (tester) async {
      final template = TemplateFixtures.basic(
        name: 'This is a very long template name that should be truncated',
      );

      await tester.pumpApp(
        SizedBox(
          height: 200,
          width: 150,
          child: TemplateCard(template: template),
        ),
      );

      final textWidget = tester.widget<Text>(find.text(
        'This is a very long template name that should be truncated',
      ));
      // Redesigned template card uses maxLines: 2 for bottom overlay text
      expect(textWidget.maxLines, 2);
      expect(textWidget.overflow, TextOverflow.ellipsis);
    });
  });
}
