import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_gradients.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Branded splash screen with animated logo, tagline, and gradient background.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _taglineController;
  late final AnimationController _pulseController;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();

    // Logo animation: fade-in + scale
    _logoController = AnimationController(
      vsync: this,
      duration: AppAnimations.xSlow,
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: AppAnimations.defaultCurve,
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: AppAnimations.defaultCurve,
      ),
    );

    // Tagline animation: fade-in + slide up (delayed)
    _taglineController = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    );
    _taglineOpacity = CurvedAnimation(
      parent: _taglineController,
      curve: AppAnimations.defaultCurve,
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _taglineController,
      curve: AppAnimations.defaultCurve,
    ));

    // Pulse for loading indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: AppAnimations.ambient,
    )..repeat(reverse: true);

    // Start animation sequence
    _startAnimations();
  }

  Future<void> _startAnimations() async {
    // Small delay for screen to settle
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    // Logo fades in
    _logoController.forward();

    // Tagline starts after logo is halfway
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _taglineController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Radial glow behind logo
            Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: const BoxDecoration(
                  gradient: AppGradients.backgroundRadial,
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated logo
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: const GradientText(
                        'Artio',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          height: 1.0,
                        ),
                        gradient: AppGradients.primaryGradient,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Animated tagline
                  SlideTransition(
                    position: _taglineSlide,
                    child: FadeTransition(
                      opacity: _taglineOpacity,
                      child: Text(
                        'Art Made Simple',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 64),

                  // Pulsing loading indicator
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 0.4 + (_pulseController.value * 0.6),
                          child: child,
                        );
                      },
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryCta.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
