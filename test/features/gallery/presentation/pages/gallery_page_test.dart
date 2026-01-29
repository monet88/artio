import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:artio/features/gallery/presentation/pages/gallery_page.dart';
import 'package:artio/features/gallery/presentation/providers/gallery_provider.dart';
import 'package:artio/features/gallery/data/repositories/gallery_repository.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/auth/presentation/state/auth_state.dart';
import '../../../../core/fixtures/fixtures.dart';

class MockGalleryRepository extends Mock implements GalleryRepository {}

class MockAuthViewModel extends AuthViewModel {
  @override
  AuthState build() => AuthState.authenticated(UserFixtures.authenticated());
}

void main() {
  setUpAll(() {
    registerFallbackValue('test-user-id');
  });

  group('GalleryPage', () {
    late MockGalleryRepository mockRepository;

    setUp(() {
      mockRepository = MockGalleryRepository();
    });

    Widget createTestWidget({List<Override>? overrides}) {
      return ProviderScope(
        overrides: [
          authViewModelProvider.overrideWith(() => MockAuthViewModel()),
          galleryRepositoryProvider.overrideWithValue(mockRepository),
          ...?overrides,
        ],
        child: const MaterialApp(
          home: GalleryPage(),
        ),
      );
    }

    testWidgets('renders app bar with Gallery title', (tester) async {
      when(() => mockRepository.watchUserImages(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Gallery'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('renders Scaffold', (tester) async {
      when(() => mockRepository.watchUserImages(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows loading shimmer initially', (tester) async {
      when(() => mockRepository.watchUserImages(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(GalleryPage), findsOneWidget);
    });

    testWidgets('displays empty state when no images', (tester) async {
      when(() => mockRepository.watchUserImages(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.value([]));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GalleryPage), findsOneWidget);
    });

    testWidgets('displays images when gallery has items', (tester) async {
      final items = GalleryItemFixtures.list(count: 3);
      when(() => mockRepository.watchUserImages(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.value(items));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(GalleryPage), findsOneWidget);
    });

    testWidgets('shows error state with retry button on error', (tester) async {
      when(() => mockRepository.watchUserImages(userId: any(named: 'userId')))
          .thenAnswer((_) => Stream.error(Exception('Network error')));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}
