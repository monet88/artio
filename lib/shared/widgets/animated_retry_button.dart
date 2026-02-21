import 'package:flutter/material.dart';

/// Outlined retry button with spin animation on press.
class AnimatedRetryButton extends StatefulWidget {
  const AnimatedRetryButton({
    required this.onPressed,
    required this.color,
    super.key,
  });

  final VoidCallback onPressed;
  final Color color;

  @override
  State<AnimatedRetryButton> createState() => _AnimatedRetryButtonState();
}

class _AnimatedRetryButtonState extends State<AnimatedRetryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _handleRetry() {
    if (_isRetrying) return;
    setState(() => _isRetrying = true);

    // Spin the icon once then trigger retry
    _spinController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() => _isRetrying = false);
        widget.onPressed();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _handleRetry,
      icon: RotationTransition(
        turns: _spinController,
        child: const Icon(Icons.refresh_rounded, size: 20),
      ),
      label: Text(_isRetrying ? 'Retrying...' : 'Try Again'),
      style: OutlinedButton.styleFrom(
        foregroundColor: widget.color,
        side: BorderSide(
          color: widget.color.withValues(alpha: 0.5),
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
