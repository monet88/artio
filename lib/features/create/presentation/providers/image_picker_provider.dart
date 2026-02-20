import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerState {
  final File? pickedImage;
  final String? error;

  const ImagePickerState({this.pickedImage, this.error});

  ImagePickerState copyWith({File? pickedImage, String? error, bool clearError = false}) {
    return ImagePickerState(
      pickedImage: pickedImage ?? this.pickedImage,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ImagePickerNotifier extends StateNotifier<ImagePickerState> {
  ImagePickerNotifier() : super(const ImagePickerState());

  final ImagePicker _picker = ImagePicker();
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB

  Future<void> pickImage(ImageSource source) async {
    state = state.copyWith(clearError: true);
    
    try {
      final XFile? image = await _picker.pickImage(source: source);
      
      if (image == null) return;
      
      final File file = File(image.path);
      final int length = await file.length();
      
      if (length > _maxFileSize) {
        state = state.copyWith(error: 'Image is too large. Maximum size is 10MB.');
        return;
      }
      
      state = state.copyWith(pickedImage: file);
    } catch (e) {
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
