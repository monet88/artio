import 'package:artio/features/gallery/data/repositories/gallery_repository.dart';
import 'package:artio/features/gallery/data/services/gallery_cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:storage_client/storage_client.dart' as storage_client;

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}
class MockStorageFileApi extends Mock implements storage_client.StorageFileApi {}
class MockGalleryCacheService extends Mock implements GalleryCacheService {}
class MockPostgrestQueryBuilder extends Mock implements PostgrestQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder<Map<String, dynamic>> {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockSupabaseStorageClient mockStorageClient;
  late MockStorageFileApi mockStorageFileApi;
  late MockGalleryCacheService mockCache;
  late GalleryRepository repository;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockStorageClient = MockSupabaseStorageClient();
    mockStorageFileApi = MockStorageFileApi();
    mockCache = MockGalleryCacheService();

    repository = GalleryRepository(mockSupabase, mockCache);

    when(() => mockSupabase.storage).thenReturn(mockStorageClient);
    when(() => mockStorageClient.from(any())).thenReturn(mockStorageFileApi);
    when(() => mockCache.clearCache()).thenAnswer((_) async {});
  });

  group('GalleryRepository.deleteJob', () {
    test('verifies batch deletion (single remove call with all paths)', () async {
      final jobId = 'job-123';
      final urls = ['path1.png', 'path2.png'];
      final inputPaths = ['input1.jpg'];
      final expectedPaths = ['path1.png', 'path2.png', 'input1.jpg'];

      final mockQueryBuilder = MockPostgrestQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();

      when(() => mockSupabase.from('generation_jobs')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', jobId)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.single()).thenAnswer((_) async => {
        'result_urls': urls,
        'input_image_paths': inputPaths,
      });

      when(() => mockQueryBuilder.delete()).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.eq('id', jobId)).thenReturn(mockFilterBuilder);
      when(() => mockFilterBuilder.then(any())).thenAnswer((invocation) {
          final callback = invocation.positionalArguments[0] as Function(PostgrestResponse);
          return Future.value(callback(const PostgrestResponse(data: null, status: 200)));
      });

      // Mock remove
      when(() => mockStorageFileApi.remove(any())).thenAnswer((_) async => []);

      await repository.deleteJob(jobId);

      // Verify batch behavior: remove is called EXACTLY ONCE with ALL paths
      verify(() => mockStorageFileApi.remove(expectedPaths)).called(1);
    });
  });
}
