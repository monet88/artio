import 'package:flutter/material.dart';

/// A widget that wraps its child with swipe-down-to-dismiss gesture handling.
///
/// Handles vertical dragging, scaling, and opacity changes. Calls [onDismiss]
/// when the drag exceeds the threshold, or snaps back on release.
class ImageViewerSwipeDismiss extends StatefulWidget {
  const ImageViewerSwipeDismiss({
    required this.child, required this.onDismiss, required this.onDragStateChanged, super.key,
  });

  final Widget child;
  final VoidCallback onDismiss;

  /// Called with (dragOffset, dragScale, isDragging).
  final void Function(double dragOffset, double dragScale, {required bool isDragging})
      onDragStateChanged;

  @override
  State<ImageViewerSwipeDismiss> createState() =>
      _ImageViewerSwipeDismissState();
}

class _ImageViewerSwipeDismissState extends State<ImageViewerSwipeDismiss> {
  double _dragOffset = 0;
  double _dragScale = 1;

  static const double _kDismissThreshold = 150;
  static const double _kScaleDivisor = 1500;
  static const double _kMaxScaleReduction = 0.15;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragStart: (_) {
        widget.onDragStateChanged(_dragOffset, _dragScale, isDragging: true);
      },
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dy;
          _dragScale = 1.0 -
              (_dragOffset.abs() / _kScaleDivisor)
                  .clamp(0.0, _kMaxScaleReduction);
        });
        widget.onDragStateChanged(_dragOffset, _dragScale, isDragging: true);
      },
      onVerticalDragEnd: (details) {
        if (_dragOffset.abs() > _kDismissThreshold) {
          widget.onDismiss();
        } else {
          setState(() {
            _dragOffset = 0;
            _dragScale = 1.0;
          });
          widget.onDragStateChanged(0, 1, isDragging: false);
        }
      },
      onVerticalDragCancel: () {
        setState(() {
          _dragOffset = 0;
          _dragScale = 1.0;
        });
        widget.onDragStateChanged(0, 1, isDragging: false);
      },
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: Transform.scale(
          scale: _dragScale,
          child: widget.child,
        ),
      ),
    );
  }
}
