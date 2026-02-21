import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/features/gallery/presentation/widgets/empty_gallery_illustration.dart';
import 'package:artio/routing/routes/app_routes.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Animated empty gallery state with floating illustration,
/// contextual messaging, and gradient CTA button.
class EmptyGalleryState extends StatefulWidget {
  const EmptyGalleryState({required this.isLoggedIn, super.key});

  final bool isLoggedIn;

  @override
  State<EmptyGalleryState> createState() => _EmptyGalleryStateState();
}

class _EmptyGalleryStateState extends State<EmptyGalleryState>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _fadeController;

  late final Animation<Offset> _floatAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Floating up/down — subtle ambient motion
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _floatAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: const Offset(0, -0.02),
        ).animate(
          CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
        );

    // Fade-in on mount
    _fadeController = AnimationController(
      vsync: this,
      duration: AppAnimations.slow,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: AppAnimations.defaultCurve,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: AppAnimations.defaultCurve,
      ),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Animated Illustration ─────────────────────────
                SlideTransition(
                  position: _floatAnimation,
                  child: EmptyIllustration(isDark: isDark),
                ),

                const SizedBox(height: AppSpacing.lg),

                // ── Title ─────────────────────────────────────────
                Text(
                  widget.isLoggedIn
                      ? 'Your Gallery is Empty'
                      : 'Sign in to see your gallery',
                  style: AppTypography.displaySmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // ── Subtitle ──────────────────────────────────────
                Text(
                  widget.isLoggedIn
                      ? 'Create your first AI-generated artwork\nand it will appear here'
                      : 'Your generated artworks will be\nsaved to your gallery',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySecondary(context),
                ),

                const SizedBox(height: AppSpacing.xl),

                // ── CTA Button ────────────────────────────────────
                if (widget.isLoggedIn)
                  GradientCTAButton(
                    onPressed: () => const HomeRoute().go(context),
                    icon: Icons.auto_awesome,
                    label: 'Start Creating',
                  )
                else
                  FilledButton(
                    onPressed: () => const LoginRoute().go(context),
                    child: const Text('Sign In'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
