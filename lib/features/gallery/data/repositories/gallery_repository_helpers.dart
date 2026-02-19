import 'dart:io';

import 'package:artio/core/exceptions/app_exception.dart';
import 'package:artio/core/utils/date_time_utils.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:http/http.dart' as http;

/// Convert job status string to enum.
GenerationStatus parseJobStatus(String? status) {
  switch (status) {
    case 'pending':
      return GenerationStatus.pending;
    case 'generating':
      return GenerationStatus.generating;
    case 'processing':
      return GenerationStatus.processing;
    case 'completed':
      return GenerationStatus.completed;
    case 'failed':
      return GenerationStatus.failed;
    default:
      return GenerationStatus.pending;
  }
}

/// Parse a raw job row into a [GalleryItem] for the given image index.
GalleryItem parseJob(Map<String, dynamic> job, int imageIndex) {
  final urls = (job['result_urls'] as List?) ?? [];
  final imageUrl = imageIndex < urls.length ? urls[imageIndex] as String : null;

  return GalleryItem(
    id: '${job['id']}_$imageIndex',
    jobId: job['id'] as String,
    userId: job['user_id'] as String,
    imageUrl: imageUrl,
    templateId: (job['template_id'] as String?) ?? '',
    templateName:
        ((job['templates'] as Map<String, dynamic>?)?['name'] as String?) ??
            'Unknown',
    prompt: job['prompt'] as String?,
    createdAt: safeParseDateTime(job['created_at']) ?? DateTime.now(),
    status: parseJobStatus(job['status'] as String?),
    resultPaths: urls.cast<String>(),
    deletedAt: safeParseDateTime(job['deleted_at']),
    isFavorite: (job['is_favorite'] as bool?) ?? false,
  );
}

/// Extract file extension from URL path, fallback to `.png`.
String extensionFromUrl(String url) {
  try {
    final path = Uri.parse(url).path;
    final lastDot = path.lastIndexOf('.');
    if (lastDot != -1 && lastDot < path.length - 1) {
      final ext = path.substring(lastDot).toLowerCase();
      if (const ['.png', '.jpg', '.jpeg', '.webp', '.gif'].contains(ext)) {
        return ext;
      }
    }
  } on FormatException catch (_) {}
  return '.png';
}

/// Download image bytes from [imageUrl] to a file in [directory].
Future<File> downloadToFile(
  String imageUrl,
  Directory directory,
  String prefix,
) async {
  final response = await http.get(Uri.parse(imageUrl));
  if (response.statusCode != 200) {
    throw AppException.network(
      message: 'Download failed',
      statusCode: response.statusCode,
    );
  }

  final ext = extensionFromUrl(imageUrl);
  final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}$ext';
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(response.bodyBytes);
  return file;
}
