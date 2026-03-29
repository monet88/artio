import 'package:artio_admin/features/jobs/domain/entities/admin_job_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminJobModel', () {
    group('fromJson', () {
      test('parses all fields', () {
        final model = AdminJobModel.fromJson(_fullJson());
        expect(model.id, 'job-uuid-1');
        expect(model.userId, 'user-uuid-1');
        expect(model.status, 'done');
        expect(model.modelId, 'kie-v1');
        expect(model.prompt, 'a cat');
        expect(model.imageUrl, 'https://example.com/img.png');
        expect(model.errorMessage, isNull);
        expect(model.createdAt, isNotNull);
      });

      test('defaults status to pending when absent', () {
        final json = _minimalJson()..remove('status');
        expect(AdminJobModel.fromJson(json).status, 'pending');
      });

      test('errorMessage is null when absent', () {
        final json = _minimalJson()..remove('error_message');
        expect(AdminJobModel.fromJson(json).errorMessage, isNull);
      });

      test('imageUrl is null when absent', () {
        final json = _minimalJson()..remove('image_url');
        expect(AdminJobModel.fromJson(json).imageUrl, isNull);
      });
    });

    group('status helpers', () {
      test('isDone true when status=done', () {
        expect(AdminJobModel.fromJson(_minimalJson()..['status'] = 'done').isDone, true);
      });
      test('isFailed true when status=failed', () {
        expect(AdminJobModel.fromJson(_minimalJson()..['status'] = 'failed').isFailed, true);
      });
      test('isGenerating true when status=generating', () {
        expect(AdminJobModel.fromJson(_minimalJson()..['status'] = 'generating').isGenerating, true);
      });
      test('isPending true when status=pending', () {
        expect(AdminJobModel.fromJson(_minimalJson()).isPending, true);
      });
    });
  });
}

Map<String, dynamic> _minimalJson() => {
  'id': 'job-uuid-1',
  'user_id': 'user-uuid-1',
  'status': 'pending',
  'model_id': 'kie-v1',
  'created_at': '2026-01-01T00:00:00.000Z',
};

Map<String, dynamic> _fullJson() => {
  'id': 'job-uuid-1',
  'user_id': 'user-uuid-1',
  'status': 'done',
  'model_id': 'kie-v1',
  'prompt': 'a cat',
  'image_url': 'https://example.com/img.png',
  'error_message': null,
  'created_at': '2026-01-01T00:00:00.000Z',
  'updated_at': '2026-01-01T00:01:00.000Z',
};
