import 'dart:io';

import 'package:artio/features/create/presentation/providers/image_picker_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockFile extends Mock implements File {}

/// IOOverrides that returns a mock File with controlled length.
final class _MockFileOverrides extends IOOverrides {
  _MockFileOverrides(this.mockLength);

  final int mockLength;

  @override
  File createFile(String path) {
    final file = MockFile();
    // Mocktail requires lambdas for getter/method stubs.
    // ignore: unnecessary_lambdas
    when(() => file.path).thenReturn(path);
    // Mocktail requires lambda for method stub.
    // ignore: unnecessary_lambdas
    when(() => file.length()).thenAnswer((_) async => mockLength);
    return file;
  }
}

void main() {
  late MockImagePicker mockPicker;
  late ImagePickerNotifier notifier;

  setUp(() {
    mockPicker = MockImagePicker();
    notifier = ImagePickerNotifier(picker: mockPicker);
  });

  tearDown(() => notifier.dispose());

  group('ImagePickerNotifier', () {
    test('pickImage with file >10MB sets error state', () async {
      // Arrange: mock picker returns an XFile
      when(() => mockPicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => XFile('/fake/large_image.jpg'));

      // Act: use IOOverrides to mock File.length() returning >10MB
      await IOOverrides.runWithIOOverrides(
        () => notifier.pickImage(ImageSource.gallery),
        _MockFileOverrides(11 * 1024 * 1024), // 11MB
      );

      // Assert
      expect(notifier.state.error, 'Image is too large. Maximum size is 10MB.');
      expect(notifier.state.pickedImage, isNull);
    });

    test('pickImage with file ≤10MB sets pickedImage', () async {
      when(() => mockPicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => XFile('/fake/small_image.jpg'));

      await IOOverrides.runWithIOOverrides(
        () => notifier.pickImage(ImageSource.gallery),
        _MockFileOverrides(5 * 1024 * 1024), // 5MB
      );

      expect(notifier.state.pickedImage, isNotNull);
      expect(notifier.state.pickedImage!.path, '/fake/small_image.jpg');
      expect(notifier.state.error, isNull);
    });

    test('pickImage with file exactly 10MB succeeds', () async {
      when(() => mockPicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => XFile('/fake/exact_image.jpg'));

      await IOOverrides.runWithIOOverrides(
        () => notifier.pickImage(ImageSource.gallery),
        _MockFileOverrides(10 * 1024 * 1024), // exactly 10MB
      );

      expect(notifier.state.pickedImage, isNotNull);
      expect(notifier.state.error, isNull);
    });

    test('pickImage when user cancels does not change state', () async {
      when(() => mockPicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => null);

      await notifier.pickImage(ImageSource.gallery);

      expect(notifier.state.pickedImage, isNull);
      expect(notifier.state.error, isNull);
    });

    test('pickImage when exception thrown sets error', () async {
      when(() => mockPicker.pickImage(source: ImageSource.gallery))
          .thenThrow(Exception('Permission denied'));

      await notifier.pickImage(ImageSource.gallery);

      expect(notifier.state.error, contains('Failed to pick image:'));
      expect(notifier.state.error, contains('Permission denied'));
      expect(notifier.state.pickedImage, isNull);
    });

    test('clearImage resets state', () async {
      when(() => mockPicker.pickImage(source: ImageSource.gallery))
          .thenAnswer((_) async => XFile('/fake/image.jpg'));

      await IOOverrides.runWithIOOverrides(
        () => notifier.pickImage(ImageSource.gallery),
        _MockFileOverrides(1024),
      );

      expect(notifier.state.pickedImage, isNotNull);

      notifier.clearImage();

      expect(notifier.state.pickedImage, isNull);
      expect(notifier.state.error, isNull);
    });
  });
}
