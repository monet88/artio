import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Center(child: Text('Test'))),
        ),
      ),
    );
    expect(find.text('Test'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
