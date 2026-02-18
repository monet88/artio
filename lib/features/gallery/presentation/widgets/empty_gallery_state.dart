import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_gradients.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
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

    _floatAnimation = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: const Offset(0, -0.02),
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

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
                  child: _EmptyIllustration(isDark: isDark),
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
                  _GradientCTAButton(
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

// ── Empty Gallery Illustration (widget-based) ─────────────────────────────

class _EmptyIllustration extends StatelessWidget {
  const _EmptyIllustration({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle glow
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryCta.withValues(alpha: 0.12),
                  AppColors.primaryCta.withValues(alpha: 0),
                ],
              ),
            ),
          ),

          // Main circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurface2 : AppColors.lightSurface2,
              border: isDark
                  ? Border.all(color: AppColors.white10, width: 0.5)
                  : null,
            ),
            child: Icon(
              Icons.photo_library_outlined,
              size: 40,
              color: isDark ? AppColors.textMuted : AppColors.textMutedLight,
            ),
          ),

          // Floating sparkle top-right
          Positioned(
            top: 16,
            right: 20,
            child: Icon(
              Icons.auto_awesome,
              size: 20,
              color: AppColors.primaryCta.withValues(alpha: 0.6),
            ),
          ),

          // Small dot bottom-left
          Positioned(
            bottom: 24,
            left: 24,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withValues(alpha: 0.5),
              ),
            ),
          ),

          // Medium dot top-left
          Positioned(
            top: 32,
            left: 28,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryCta.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gradient CTA Button ───────────────────────────────────────────────────

class _GradientCTAButton extends StatelessWidget {
  const _GradientCTAButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x333DD598),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTypography.buttonLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
