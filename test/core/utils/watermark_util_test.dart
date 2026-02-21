import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:artio/core/utils/watermark_util.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a minimal valid PNG image of the given dimensions.
Future<Uint8List> _createTestImage(int width, int height) async {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint()..color = const ui.Color(0xFF0000FF),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return byteData!.buffer.asUint8List();
}

void main() {
  group('WatermarkUtil', () {
    testWidgets('applyWatermark returns valid PNG bytes', (tester) async {
      final output = await tester.runAsync(() async {
        final input = await _createTestImage(200, 200);
        return WatermarkUtil.applyWatermark(input);
      });

      expect(output, isNotNull);
      // PNG header: 137 80 78 71 13 10 26 10
      expect(output!.length, greaterThan(8));
      expect(output[0], 137); // PNG signature
      expect(output[1], 80); // 'P'
      expect(output[2], 78); // 'N'
      expect(output[3], 71); // 'G'
    });

    testWidgets('output dimensions match input dimensions', (tester) async {
      final result = await tester.runAsync(() async {
        final input = await _createTestImage(300, 400);
        final output = await WatermarkUtil.applyWatermark(input);

        // Decode the output to verify dimensions.
        final codec = await ui.instantiateImageCodec(output);
        final frame = await codec.getNextFrame();
        final image = frame.image;
        final dims = [image.width, image.height];
        image.dispose();
        return dims;
      });

      expect(result, isNotNull);
      expect(result![0], 300);
      expect(result[1], 400);
    });

    testWidgets('returns original bytes for small images', (tester) async {
      final result = await tester.runAsync(() async {
        final input = await _createTestImage(50, 50);
        final output = await WatermarkUtil.applyWatermark(input);
        return [input, output];
      });

      expect(result, isNotNull);
      // Should return the exact same instance.
      expect(identical(result![0], result[1]), isTrue);
    });
  });
}
