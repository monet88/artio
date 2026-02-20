import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerState {

  const ImagePickerState({this.pickedImage, this.error});
  final File? pickedImage;
  final String? error;

  ImagePickerState copyWith({File? pickedImage, String? error, bool clearError = false}) {
    return ImagePickerState(
      pickedImage: pickedImage ?? this.pickedImage,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ImagePickerNotifier extends StateNotifier<ImagePickerState> {
  ImagePickerNotifier({ImagePicker? picker})
      : _picker = picker ?? ImagePicker(),
        super(const ImagePickerState());

  final ImagePicker _picker;
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB

  Future<void> pickImage(ImageSource source) async {
    state = state.copyWith(clearError: true);
    
    try {
      final image = await _picker.pickImage(source: source);
      
      if (image == null) return;
      
      final file = File(image.path);
      final length = await file.length();
      
      if (length > maxFileSize) {
        state = state.copyWith(error: 'Image is too large. Maximum size is 10MB.');
        return;
      }
      
      state = state.copyWith(pickedImage: file);
    } on Exception catch (e) {
      state = state.copyWith(error: 'Failed to pick image: $e');
    }
  }

  void clearImage() {
    state = const ImagePickerState();
  }
}

final imagePickerProvider = StateNotifierProvider<ImagePickerNotifier, ImagePickerState>((ref) {
  return ImagePickerNotifier();
});
