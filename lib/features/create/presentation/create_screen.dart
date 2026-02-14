import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_gradients.dart';
import 'package:artio/core/design_system/app_shadows.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/theme/app_colors.dart';

/// Premium "Coming Soon" teaser for the Create tab.
///
/// Features:
/// - Animated gradient background with radial glow
/// - Pulsing sparkle icon with rotating halo
/// - Animated feature preview cards
/// - Gradient "Notify Me" CTA button
/// - Staggered entrance animations
class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final AnimationController _entranceController;
  late final AnimationController _shimmerController;

  late final Animation<double> _pulseAnimation;
  late final Animation<double> _rotateAnimation;
  late final Animation<double> _shimmerAnimation;

  // Staggered entrance animations
  late final Animation<double> _iconFade;
  late final Animation<Offset> _iconSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _cardsFade;
  late final Animation<Offset> _cardsSlide;
  late final Animation<double> _ctaFade;
  late final Animation<double> _ctaScale;

  bool _notifyPressed = false;

  @override
  void initState() {
    super.initState();

    // Continuous pulse animation for the icon glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Slow rotation for the halo ring
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      _rotateController,
    );

    // Shimmer for CTA button
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    // Entrance stagger — total 1200ms
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _iconSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
      ),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.35, 0.6, curve: Curves.easeOut),
      ),
    );

    _cardsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );
    _cardsSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _ctaFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
    _ctaScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.7, 1.0, curve: Curves.elasticOut),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _entranceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _onNotifyPressed() {
    HapticFeedback.mediumImpact();
    setState(() => _notifyPressed = true);
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Create'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark
              ? AppGradients.backgroundGradient
              : const LinearGradient(
                  colors: [
                    Color(0xFFF0F4FF),
                    Color(0xFFE8F0FE),
                    Color(0xFFF5F0FF),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: Stack(
          children: [
            // Radial glow behind icon
            if (isDark)
              Positioned(
                top: MediaQuery.of(context).size.height * 0.12,
                left: 0,
                right: 0,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Container(
                      height: 280,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primaryCta
                                .withValues(alpha: 0.12 * _pulseAnimation.value),
                            AppColors.accent
                                .withValues(alpha: 0.06 * _pulseAnimation.value),
                            Colors.transparent,
                          ],
                          radius: 0.6,
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    SizedBox(height: AppSpacing.xxl),

                    // ── Animated Icon with Halo ──
                    _buildAnimatedIcon(isDark),
                    SizedBox(height: AppSpacing.xl),

                    // ── Title ──
                    _buildTitle(isDark),
                    SizedBox(height: AppSpacing.sm),

                    // ── Subtitle ──
                    _buildSubtitle(isDark),
                    SizedBox(height: AppSpacing.xl + AppSpacing.sm),

                    // ── Feature Preview Cards ──
                    _buildFeatureCards(isDark),
                    SizedBox(height: AppSpacing.xl + AppSpacing.sm),

                    // ── CTA Button ──
                    _buildCtaButton(isDark),
                    SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(bool isDark) {
    return SlideTransition(
      position: _iconSlide,
      child: FadeTransition(
        opacity: _iconFade,
        child: SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating halo ring
              AnimatedBuilder(
                animation: _rotateAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          width: 1.5,
                          color: Colors.transparent,
                        ),
                        gradient: SweepGradient(
                          colors: [
                            AppColors.primaryCta.withValues(alpha: 0.0),
                            AppColors.primaryCta.withValues(alpha: 0.6),
                            AppColors.accent.withValues(alpha: 0.6),
                            AppColors.accent.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Inner glow circle
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          isDark
                              ? AppColors.darkSurface2
                              : AppColors.lightSurface1,
                          isDark
                              ? AppColors.darkSurface1
                              : AppColors.lightSurface2,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryCta
                              .withValues(alpha: 0.3 * _pulseAnimation.value),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (bounds) =>
                          AppGradients.primaryGradient.createShader(bounds),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isDark) {
    return SlideTransition(
      position: _titleSlide,
      child: FadeTransition(
        opacity: _titleFade,
        child: Column(
          children: [
            GradientText(
              'Text to Image',
              style: AppTypography.displayLarge.copyWith(fontSize: 28),
              gradient: AppGradients.primaryGradient,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Coming Soon',
              style: AppTypography.displaySmall.copyWith(
                color: isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle(bool isDark) {
    return FadeTransition(
      opacity: _subtitleFade,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Text(
          'Transform your ideas into stunning artwork with AI. '
          'Type a description, choose a style, and watch the magic happen.',
          style: AppTypography.bodySecondary(context).copyWith(
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildFeatureCards(bool isDark) {
    return SlideTransition(
      position: _cardsSlide,
      child: FadeTransition(
        opacity: _cardsFade,
        child: Column(
          children: [
            _FeaturePreviewCard(
              icon: Icons.edit_note_rounded,
              title: 'Describe Your Vision',
              description: 'Type any prompt — from simple to detailed',
              gradient: const LinearGradient(
                colors: [Color(0xFF3DD598), Color(0xFF2BA878)],
              ),
              isDark: isDark,
            ),
            const SizedBox(height: AppSpacing.md),
            _FeaturePreviewCard(
              icon: Icons.palette_rounded,
              title: 'Choose a Style',
              description: 'Anime, realistic, abstract, watercolor & more',
              gradient: const LinearGradient(
                colors: [Color(0xFF9B87F5), Color(0xFF7B62E0)],
              ),
              isDark: isDark,
            ),
            const SizedBox(height: AppSpacing.md),
            _FeaturePreviewCard(
              icon: Icons.auto_fix_high_rounded,
              title: 'Generate in Seconds',
              description: 'Powered by state-of-the-art AI models',
              gradient: const LinearGradient(
                colors: [Color(0xFF29B6F6), Color(0xFF0288D1)],
              ),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCtaButton(bool isDark) {
    return FadeTransition(
      opacity: _ctaFade,
      child: ScaleTransition(
        scale: _ctaScale,
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: AppGradients.primaryGradient,
                boxShadow: AppShadows.buttonShadowGradient,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _notifyPressed ? null : _onNotifyPressed,
                  child: Stack(
                    children: [
                      // Shimmer overlay
                      if (!_notifyPressed)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: ShaderMask(
                            blendMode: BlendMode.srcATop,
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.0),
                                  Colors.white.withValues(alpha: 0.15),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                                begin: Alignment(_shimmerAnimation.value, 0),
                                end: Alignment(
                                    _shimmerAnimation.value + 0.5, 0),
                              ).createShader(bounds);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 56,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                      // Button content
                      Center(
                        child: AnimatedSwitcher(
                          duration: AppAnimations.normal,
                          child: _notifyPressed
                              ? Row(
                                  key: const ValueKey('done'),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "You're on the list!",
                                      style:
                                          AppTypography.buttonLarge.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  key: const ValueKey('notify'),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.notifications_active_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Notify Me When Ready',
                                      style:
                                          AppTypography.buttonLarge.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Feature preview card with icon, gradient accent, and glass-like styling.
class _FeaturePreviewCard extends StatelessWidget {
  const _FeaturePreviewCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? AppColors.darkSurface2.withValues(alpha: 0.7)
            : AppColors.lightSurface1,
        border: Border.all(
          color: isDark ? AppColors.white10 : AppColors.lightSurface3,
          width: isDark ? 0.5 : 1,
        ),
        boxShadow: isDark ? null : AppShadows.cardShadow,
      ),
      child: Row(
        children: [
          // Gradient icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimary
                        : AppColors.textPrimaryLight,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.textMuted
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
