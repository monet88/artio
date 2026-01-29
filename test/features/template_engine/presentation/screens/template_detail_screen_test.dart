import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/template_engine/presentation/screens/template_detail_screen.dart';

import '../../../../core/helpers/pump_app.dart';

void main() {
  group('TemplateDetailScreen', () {
    testWidgets('renders app bar with Generate title', (tester) async {
      await tester.pumpApp(
        const TemplateDetailScreen(templateId: 'test-template-id'),
      );

      expect(find.text('Generate'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      await tester.pumpApp(
        const TemplateDetailScreen(templateId: 'test-template-id'),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpApp(
        const TemplateDetailScreen(templateId: 'test-template-id'),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
