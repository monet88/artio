import 'package:flutter_test/flutter_test.dart';
import 'package:artio/features/create/presentation/create_screen.dart';
import '../../../../core/helpers/helpers.dart';

void main() {
  group('CreateScreen', () {
    testWidgets('renders create screen', (tester) async {
      await tester.pumpApp(const CreateScreen());
      await tester.pumpAndSettle();

      expect(find.byType(CreateScreen), findsOneWidget);
    });

    testWidgets('displays coming soon message', (tester) async {
      await tester.pumpApp(const CreateScreen());
      await tester.pumpAndSettle();

      expect(find.text('Coming Soon'), findsOneWidget);
    });
  });
}
