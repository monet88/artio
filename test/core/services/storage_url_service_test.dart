import 'package:artio/core/providers/supabase_provider.dart';
import 'package:artio/core/services/storage_url_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  group('storageUrlServiceProvider', () {
    test('keeps the same service instance after the last listener is removed', () async {
      final mockSupabase = MockSupabaseClient();
      final container = ProviderContainer(
        overrides: [supabaseClientProvider.overrideWithValue(mockSupabase)],
      );
      addTearDown(container.dispose);

      final subscription = container.listen<StorageUrlService>(
        storageUrlServiceProvider,
        (_, __) {},
      );
      final first = subscription.read();

      subscription.close();
      await container.pump();

      final second = container.read(storageUrlServiceProvider);

      expect(identical(first, second), isTrue);
    });
  });
}
