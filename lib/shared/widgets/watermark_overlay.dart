import 'package:flutter/material.dart';

/// Renders a subtle "artio" watermark over the [child] widget.
///
/// When [showWatermark] is `false`, [child] is returned directly
/// with zero overhead.
class WatermarkOverlay extends StatelessWidget {
  const WatermarkOverlay({
    required this.showWatermark,
    required this.child,
    super.key,
  });

  final bool showWatermark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!showWatermark) return child;

    return Stack(
      children: [
        child,
        Positioned(
          bottom: 8,
          right: 12,
          child: Text(
            'artio',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              shadows: const [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
