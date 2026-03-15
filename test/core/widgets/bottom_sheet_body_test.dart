import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/widgets/bottom_sheet_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BottomSheetBody', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BottomSheetBody(
              child: Text('Hello'),
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('wraps content in SafeArea with top:false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BottomSheetBody(
              child: SizedBox(),
            ),
          ),
        ),
      );

      final safeArea = tester.widget<SafeArea>(find.byType(SafeArea));
      expect(safeArea.top, false);
      expect(safeArea.bottom, true);
    });

    testWidgets(
        'applies default padding EdgeInsets.all(AppSpacing.lg) when no padding given',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              viewPadding: EdgeInsets.only(bottom: 0),
            ),
            child: Scaffold(
              body: BottomSheetBody(
                child: SizedBox(),
              ),
            ),
          ),
        ),
      );

      // SafeArea adds its own internal Padding(EdgeInsets.zero) as first descendant.
      // Our BottomSheetBody Padding is the last one inside SafeArea.
      final safeAreaFinder = find.byType(SafeArea);
      final paddingFinder = find.descendant(
        of: safeAreaFinder,
        matching: find.byType(Padding),
      );
      final padding = tester.widget<Padding>(paddingFinder.last);
      const expected = EdgeInsets.all(AppSpacing.lg);
      expect(padding.padding, expected);
    });

    testWidgets('applies custom padding when provided', (tester) async {
      const customPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);

      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              viewPadding: EdgeInsets.only(bottom: 0),
            ),
            child: Scaffold(
              body: BottomSheetBody(
                padding: customPadding,
                child: SizedBox(),
              ),
            ),
          ),
        ),
      );

      final safeAreaFinder = find.byType(SafeArea);
      final paddingFinder = find.descendant(
        of: safeAreaFinder,
        matching: find.byType(Padding),
      );
      final padding = tester.widget<Padding>(paddingFinder.last);
      expect(padding.padding, customPadding);
    });
  });
}
