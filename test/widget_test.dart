import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artio/main.dart';

void main() {
  testWidgets('App renders Artio text', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ArtioApp()));
    expect(find.text('Artio'), findsOneWidget);
  });
}
