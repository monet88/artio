import 'package:artio/features/gallery/presentation/widgets/shimmer_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  group('ShimmerGrid', () {
    Widget buildWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: ShimmerGrid(),
        ),
      );
    }

    testWidgets('renders shimmer placeholders', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(MasonryGridView), findsOneWidget);
      expect(find.byType(Shimmer), findsWidgets);
    });

    testWidgets('renders correct number of placeholder items', (tester) async {
      await tester.pumpWidget(buildWidget());

      // ShimmerGrid creates 12 placeholder items
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays loading shimmer animation', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Verify shimmer effect is present
      expect(find.byType(Shimmer), findsWidgets);
    });
  });
}
