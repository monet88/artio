import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/create/presentation/create_screen.dart';
import '../../../../core/helpers/helpers.dart';

void main() {
  group('CreateScreen', () {
    testWidgets('renders create screen', (tester) async {
      await tester.pumpApp(const CreateScreen());
      // Use pump() instead of pumpAndSettle() since screen has
      // continuous animations (pulse, rotate)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CreateScreen), findsOneWidget);
    });

    testWidgets('displays Coming Soon subtitle', (tester) async {
      await tester.pumpApp(const CreateScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Coming Soon'), findsOneWidget);
    });

    testWidgets('displays Text to Image title', (tester) async {
      await tester.pumpApp(const CreateScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Text to Image'), findsOneWidget);
    });

    testWidgets('displays Notify Me button', (tester) async {
      await tester.pumpApp(const CreateScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));

      expect(find.text('Notify Me When Ready'), findsOneWidget);
    });

    testWidgets('displays feature preview cards', (tester) async {
      await tester.pumpApp(const CreateScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));

      expect(find.text('Describe Your Vision'), findsOneWidget);
      expect(find.text('Choose a Style'), findsOneWidget);
      expect(find.text('Generate in Seconds'), findsOneWidget);
    });
  });
}
