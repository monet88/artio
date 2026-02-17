import 'package:artio/features/auth/domain/entities/user_model.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/gallery/data/repositories/gallery_repository.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/features/gallery/presentation/pages/gallery_page.dart';
import 'package:artio/features/gallery/presentation/pages/image_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGalleryRepository extends Mock implements GalleryRepository {}

class MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => AuthState.authenticated(
        UserModel(
          id: 'test-user-id',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        ),
      );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue('test-user-id');
  });

  group('Gallery Flow Integration Tests', () {
    late MockGalleryRepository mockRepository;

    setUp(() {
      mockRepository = MockGalleryRepository();
    });

    Widget createTestWidget({Widget? home}) {
      return ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(MockAuthViewModel.new),
          galleryRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: MaterialApp(
          title: 'Artio Test',
          theme: ThemeData.light(useMaterial3: true),
          home: home ?? const GalleryPage(),
        ),
      );
    }

    testWidgets('gallery page displays with title', (tester) async {
      when(() => mockRepository.watchUserImages(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Gallery'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('gallery shows empty state when no images', (tester) async {
      when(() => mockRepository.watchUserImages(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GalleryPage), findsOneWidget);
    });

    testWidgets('gallery shows error state with retry button', (tester) async {
      when(() => mockRepository.watchUserImages(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.error(Exception('Network error')));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('image viewer displays action buttons', (tester) async {
      final testItems = [
        GalleryItem(
          id: 'gallery-1',
          jobId: 'job-1',
          userId: 'user-1',
          templateId: 'template-1',
          templateName: 'Test Template',
          createdAt: DateTime.now(),
          status: GenerationStatus.completed,
          imageUrl: 'https://example.com/image.jpg',
          prompt: 'Test prompt',
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        home: ImageViewerPage(items: testItems, initialIndex: 0),
      ));

      expect(find.byIcon(Icons.share), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('image viewer supports page swiping', (tester) async {
      final testItems = List.generate(
        3,
        (i) => GalleryItem(
          id: 'gallery-$i',
          jobId: 'job-$i',
          userId: 'user-1',
          templateId: 'template-1',
          templateName: 'Test Template',
          createdAt: DateTime.now(),
          status: GenerationStatus.completed,
          imageUrl: 'https://example.com/image-$i.jpg',
        ),
      );

      await tester.pumpWidget(createTestWidget(
        home: ImageViewerPage(items: testItems, initialIndex: 0),
      ));

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets('image viewer shows prompt in bottom bar', (tester) async {
      final testItems = [
        GalleryItem(
          id: 'gallery-1',
          jobId: 'job-1',
          userId: 'user-1',
          templateId: 'template-1',
          templateName: 'Portrait Template',
          createdAt: DateTime.now(),
          status: GenerationStatus.completed,
          imageUrl: 'https://example.com/image.jpg',
          prompt: 'A beautiful portrait photo',
        ),
      ];

      await tester.pumpWidget(createTestWidget(
        home: ImageViewerPage(items: testItems, initialIndex: 0),
      ));

      expect(find.text('Portrait Template'), findsOneWidget);
      expect(find.text('A beautiful portrait photo'), findsOneWidget);
    });
  });
}
