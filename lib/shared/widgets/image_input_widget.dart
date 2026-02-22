import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// A widget for picking, previewing, and removing an image input.
/// Supports gallery and camera sources with built-in compression.
class ImageInputWidget extends StatelessWidget {
  const ImageInputWidget({
    required this.label,
    required this.isRequired,
    required this.onChanged,
    super.key,
    this.file,
  });

  final String label;
  final bool isRequired;
  final XFile? file;
  final ValueChanged<XFile?> onChanged;

  static const _maxDimension = 2048.0;
  static const _imageQuality = 85;

  Future<void> _pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: _maxDimension,
      maxHeight: _maxDimension,
      imageQuality: _imageQuality,
    );

    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFile = file != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        if (hasFile)
          _ImagePreview(
            file: file!,
            onRemove: () => onChanged(null),
            onReplace: () => _pickImage(context),
          )
        else
          _ImagePlaceholder(
            isRequired: isRequired,
            onTap: () => _pickImage(context),
          ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.file,
    required this.onRemove,
    required this.onReplace,
  });

  final XFile file;
  final VoidCallback onRemove;
  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        GestureDetector(
          onTap: onReplace,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: kIsWeb
                  ? Image.network(file.path, fit: BoxFit.cover)
                  : Image.file(File(file.path), fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: theme.colorScheme.surface.withAlpha(200),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.isRequired,
    required this.onTap,
  });

  final bool isRequired;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withAlpha(100),
            style: BorderStyle.solid,
          ),
          color: theme.colorScheme.surfaceContainerLow,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 40,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to select image',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (isRequired)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Required',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
