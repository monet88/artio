import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock for SupabaseClient
class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Mock for GoTrue auth client
class MockGoTrueClient extends Mock implements GoTrueClient {}

/// Mock for Supabase query builder - generic for list queries
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

/// Mock for single item filter (maybeSingle queries)
class MockSingleFilterBuilder extends Mock
    implements PostgrestFilterBuilder<Map<String, dynamic>?> {}

/// Mock for single item transform
class MockSingleTransformBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {}

/// Mock for PostgrestFilterBuilder - used for query filtering
/// Note: Do NOT override then() - let mocktail handle it via thenAnswer
class MockPostgrestFilterBuilder<T> extends Mock
    implements PostgrestFilterBuilder<T> {}

class FakePostgrestFilterBuilder<T> extends Fake
    implements PostgrestFilterBuilder<T> {}

/// Mock for PostgrestTransformBuilder
class MockPostgrestTransformBuilder<T> extends Mock
    implements PostgrestTransformBuilder<T> {}

/// Mock for realtime channel
class MockRealtimeChannel extends Mock implements RealtimeChannel {}

/// Mock for SupabaseStorageClient
class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

/// Mock for FunctionsClient (edge functions)
class MockFunctionsClient extends Mock implements FunctionsClient {}

/// Mock for Supabase User
class MockUser extends Mock implements User {}

/// Mock for SupabaseStreamFilterBuilder (realtime streams)
class MockSupabaseStreamFilterBuilder extends Mock
    implements SupabaseStreamFilterBuilder {}

/// Mock for SupabaseStreamBuilder
class MockSupabaseStreamBuilder extends Mock implements SupabaseStreamBuilder {}
