import 'package:artio/features/auth/domain/providers/onboarding_provider.dart';
import 'package:artio/routing/routes/app_routes.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Onboarding screen shown once after first login.
///
/// Design: Full-screen dark gradient, 3 slides with icon, title, subtitle.
/// PageView with explicit dot indicators and a "Get Started" / "Next" button.
/// On completion calls [markOnboardingDone] and navigates to Home.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardingSlide(
      gradient: [Color(0xFF0D1025), Color(0xFF1A1040)],
      iconEmoji: '🎨',
      iconBg: Color(0xFF2A1A60),
      title: 'Create Stunning AI Art',
      subtitle:
          'Turn your ideas into beautiful images using the latest AI models — '
          'Flux, Imagen, and more. Just type a prompt and watch the magic happen.',
    ),
    _OnboardingSlide(
      gradient: [Color(0xFF0D1025), Color(0xFF001A20)],
      iconEmoji: '⚡',
      iconBg: Color(0xFF0D2A20),
      title: 'Fast & Easy to Use',
      subtitle:
          'Choose a style template, pick your model, and generate in seconds. '
          'Save, share, and organise all your creations in your personal gallery.',
    ),
    _OnboardingSlide(
      gradient: [Color(0xFF0D1025), Color(0xFF1A0D25)],
      iconEmoji: '💎',
      iconBg: Color(0xFF2A0D40),
      title: 'Free Credits to Start',
      subtitle:
          'Start with free credits the moment you sign up. '
          'Watch rewarded ads to earn more, or upgrade to Premium for unlimited generations.',
    ),
  ];

  bool get _isLastPage => _currentPage == _slides.length - 1;

  Future<void> _next() async {
    if (_isLastPage) {
      await _finish();
    } else {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finish() async {
    await markOnboardingDone();
    if (!mounted) return;
    const HomeRoute().go(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          // ── Gradient background (animated between slides) ────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: slide.gradient,
              ),
            ),
          ),

          // ── Page content ─────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Skip button (top right, hidden on last page)
                Align(
                  alignment: Alignment.topRight,
                  child: AnimatedOpacity(
                    opacity: _isLastPage ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: _isLastPage ? null : _finish,
                      child: Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.white60,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Slides ──────────────────────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: _slides.length,
                    itemBuilder: (context, idx) =>
                        _SlideContent(slide: _slides[idx]),
                  ),
                ),

                // ── Dot indicators ───────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _currentPage ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _currentPage
                            ? AppColors.primaryCta
                            : AppColors.white20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── CTA button ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryCta.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _isLastPage ? 'Get Started 🚀' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.gradient,
    required this.iconEmoji,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  final List<Color> gradient;
  final String iconEmoji;
  final Color iconBg;
  final String title;
  final String subtitle;
}

// ── Slide content widget ──────────────────────────────────────────────────────

class _SlideContent extends StatelessWidget {
  const _SlideContent({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji icon in rounded square
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: slide.iconBg,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.white10, width: 1),
            ),
            child: Center(
              child: Text(
                slide.iconEmoji,
                style: const TextStyle(fontSize: 56),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 16),

          // Subtitle
          Text(
            slide.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white60,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
