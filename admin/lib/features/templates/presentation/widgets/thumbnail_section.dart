import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ThumbnailSection extends StatefulWidget {
  final TextEditingController thumbnailUrlController;
  final String? templateId;
  final bool isDark;

  const ThumbnailSection({
    super.key,
    required this.thumbnailUrlController,
    required this.templateId,
    required this.isDark,
  });

  @override
  State<ThumbnailSection> createState() => _ThumbnailSectionState();
}

class _ThumbnailSectionState extends State<ThumbnailSection> {
  bool _isUploading = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    final ext = file.extension ?? 'jpg';
    final path = 'templates/${widget.templateId}/thumbnail.$ext';

    setState(() => _isUploading = true);
    try {
      await Supabase.instance.client.storage.from('templates').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
          );

      final publicUrl = Supabase.instance.client.storage
          .from('templates')
          .getPublicUrl(path);

      if (!mounted) return;
      setState(() => widget.thumbnailUrlController.text = publicUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thumbnail uploaded')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isDark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thumbnail',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              if (widget.templateId != null) ...[
                OutlinedButton.icon(
                  onPressed: _isUploading ? null : _pickAndUpload,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_outlined, size: 18),
                  label: Text(_isUploading ? 'Uploading...' : 'Upload Image'),
                ),
                const Gap(8),
                Text(
                  'Or paste a URL below',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AdminColors.textMuted : Colors.grey,
                  ),
                ),
                const Gap(12),
              ] else ...[
                Text(
                  'Save template first to upload thumbnail',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? AdminColors.textMuted : Colors.grey,
                  ),
                ),
                const Gap(12),
              ],
              ListenableBuilder(
                listenable: widget.thumbnailUrlController,
                builder: (context, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: widget.thumbnailUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Thumbnail URL',
                          hintText: 'https://example.com/image.png',
                          prefixIcon: Icon(Icons.link),
                        ),
                      ),
                      const Gap(24),
                      if (widget.thumbnailUrlController.text.isNotEmpty) ...[
                        Text(
                          'Preview',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Gap(12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 300),
                            width: double.infinity,
                            color: isDark
                                ? AdminColors.surfaceContainer
                                : Colors.grey.shade100,
                            child: Image.network(
                              widget.thumbnailUrlController.text,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Padding(
                                padding: EdgeInsets.all(32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image, size: 48),
                                    Gap(8),
                                    Text('Invalid or unreachable URL'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else
                        Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AdminColors.surfaceContainer
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? AdminColors.borderSubtle
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: isDark
                                    ? AdminColors.textHint
                                    : Colors.grey.shade400,
                              ),
                              const Gap(8),
                              Text(
                                'Add a thumbnail URL above',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isDark
                                      ? AdminColors.textMuted
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
