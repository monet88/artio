import 'dart:typed_data';
import 'dart:ui' as ui;

/// Utility for burning a watermark into image bytes.
class WatermarkUtil {
  WatermarkUtil._();

  /// Burns an "artio" watermark into [imageBytes] and returns PNG bytes.
  ///
  /// For images smaller than 100px on either dimension, returns [imageBytes]
  /// unchanged since the watermark would be unreadable.
  static Future<Uint8List> applyWatermark(Uint8List imageBytes) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frame = await codec.getNextFrame();
    codec.dispose();
    final image = frame.image;

    final width = image.width;
    final height = image.height;

    // Skip watermark for tiny images.
    if (width < 100 || height < 100) {
      image.dispose();
      return imageBytes;
    }

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);

    // Draw original image.
    // ignore: cascade_invocations
    canvas.drawImage(image, ui.Offset.zero, ui.Paint());

    // Draw watermark text.
    final fontSize = (width * 0.04).clamp(12.0, 48.0);
    final paragraphBuilder = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textAlign: ui.TextAlign.right,
        fontSize: fontSize,
      ),
    )..pushStyle(
        ui.TextStyle(
          color: const ui.Color.fromRGBO(255, 255, 255, 0.4),
          fontSize: fontSize,
          fontWeight: ui.FontWeight.w600,
          letterSpacing: 0.5,
          shadows: const [
            ui.Shadow(blurRadius: 4, color: ui.Color.fromRGBO(0, 0, 0, 0.54)),
          ],
        ),
      )
      ..addText('artio')
      ..pop();

    final paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: width.toDouble()));

    final textX = width - paragraph.longestLine - 12;
    final textY = height - paragraph.height - 8;
    canvas.drawParagraph(paragraph, ui.Offset(textX, textY));

    // Encode to PNG.
    final picture = recorder.endRecording();
    final rendered = await picture.toImage(width, height);
    final byteData = await rendered.toByteData(
      format: ui.ImageByteFormat.png,
    );

    image.dispose();
    rendered.dispose();

    // Graceful fallback: return original if encoding failed.
    if (byteData == null) return imageBytes;

    return byteData.buffer.asUint8List();
  }
}
