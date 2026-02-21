import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/providers/connectivity_provider.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Animated offline banner that slides down when connection is lost
/// and slides back up with a "Back online" flash when reconnected.
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  bool _wasOffline = false;
  bool _showReconnected = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: AppAnimations.defaultCurve,
          ),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityProvider);

    final isOffline =
        connectivityAsync.whenOrNull(data: (isConnected) => !isConnected) ??
        false;

    // Handle state transitions
    if (isOffline && !_wasOffline) {
      // Just went offline
      _showReconnected = false;
      _controller.forward();
    } else if (!isOffline && _wasOffline) {
      // Just reconnected — show "Back online" briefly
      _showReconnected = true;
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // Re-check connectivity before dismissing — if user went
          // offline again during the delay, keep banner visible.
          final stillOnline =
              ref
                  .read(connectivityProvider)
                  .whenOrNull(data: (isConnected) => isConnected) ??
              true;
          if (stillOnline) {
            _controller.reverse();
            setState(() => _showReconnected = false);
          }
        }
      });
    }
    _wasOffline = isOffline;

    if (!isOffline && !_showReconnected && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedContainer(
        duration: AppAnimations.fast,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: _showReconnected ? AppColors.success : AppColors.error,
          boxShadow: const [
            BoxShadow(
              color: Color(0x20000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Animated Icon ─────────────────────────────────
              if (_showReconnected)
                const Icon(Icons.wifi_rounded, size: 18, color: Colors.white)
              else
                const _PulsingWifiIcon(),

              const SizedBox(width: 8),

              // ── Message ───────────────────────────────────────
              Text(
                _showReconnected ? 'Back online' : 'No internet connection',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),

              if (!_showReconnected) ...[
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    _controller.reverse();
                    ref.invalidate(connectivityProvider);
                  },
                  child: const Text(
                    'Dismiss',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Pulsing wifi-off icon for offline state
class _PulsingWifiIcon extends StatefulWidget {
  const _PulsingWifiIcon();

  @override
  State<_PulsingWifiIcon> createState() => _PulsingWifiIconState();
}

class _PulsingWifiIconState extends State<_PulsingWifiIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        return Opacity(opacity: 0.5 + (_pulse.value * 0.5), child: child);
      },
      child: const Icon(Icons.wifi_off_rounded, size: 18, color: Colors.white),
    );
  }
}
