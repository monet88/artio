import 'dart:async';

import 'package:artio/core/config/sentry_config.dart';
import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/core/utils/app_exception_mapper.dart';
import 'package:artio/features/template_engine/domain/entities/template_model.dart';
import 'package:artio/features/template_engine/presentation/providers/template_provider.dart';
import 'package:artio/features/template_engine/presentation/widgets/template_card.dart';
import 'package:artio/shared/widgets/loading_state_widget.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Template grid with staggered appear animation for items.
/// Returns sliver-compatible widgets — use directly inside a CustomScrollView.
class TemplateGrid extends ConsumerWidget {
  const TemplateGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);

    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.palette_outlined,
                    size: 48,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textMuted
                        : AppColors.textMutedLight,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No templates available',
                    style: AppTypography.bodySecondary(context),
                  ),
                ],
              ),
            ),
          );
        }
        return _StaggeredGrid(templates: templates);
      },
      loading: () => const SliverToBoxAdapter(child: LoadingStateWidget()),
      error: (error, stack) => SliverToBoxAdapter(
        child: _ErrorMessage(error: error, stackTrace: stack),
      ),
    );
  }
}

/// Grid with staggered fade-in animation for items
class _StaggeredGrid extends StatefulWidget {
  const _StaggeredGrid({required this.templates});
  final List<TemplateModel> templates;

  @override
  State<_StaggeredGrid> createState() => _StaggeredGridState();
}

class _StaggeredGridState extends State<_StaggeredGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  int _previousTemplateCount = 0;

  /// Vertical offset (px) for the stagger slide-up entrance animation.
  static const double _kStaggerSlideOffset = 20;

  @override
  void initState() {
    super.initState();
    _previousTemplateCount = widget.templates.length;
    _staggerController = _createController();
    _staggerController.forward();
  }

  @override
  void didUpdateWidget(covariant _StaggeredGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.templates.length != _previousTemplateCount) {
      _previousTemplateCount = widget.templates.length;
      _staggerController.dispose();
      _staggerController = _createController();
      _staggerController.forward();
    }
  }

  AnimationController _createController() {
    return AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds:
            AppAnimations.normal.inMilliseconds +
            (AppAnimations.staggerDelay.inMilliseconds *
                widget.templates.length.clamp(
                  0,
                  AppAnimations.maxStaggerItems,
                )),
      ),
    );
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final templates = widget.templates;
    final itemCount = templates.length;

    return SliverPadding(
      padding: AppSpacing.screenPadding,
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          // Stagger calculation
          const maxItems = AppAnimations.maxStaggerItems;
          final clampedItemCount = templates.length.clamp(0, maxItems);
          final staggerIndex = index.clamp(0, maxItems);
          final totalStaggerTime =
              AppAnimations.staggerDelay.inMilliseconds * clampedItemCount;
          final totalDuration =
              AppAnimations.normal.inMilliseconds + totalStaggerTime;

          final startFraction =
              (staggerIndex * AppAnimations.staggerDelay.inMilliseconds) /
              totalDuration;
          final endFraction =
              (staggerIndex * AppAnimations.staggerDelay.inMilliseconds +
                  AppAnimations.normal.inMilliseconds) /
              totalDuration;

          final itemAnimation = Tween<double>(begin: 0, end: 1).animate(
            CurvedAnimation(
              parent: _staggerController,
              curve: Interval(
                startFraction.clamp(0.0, 1.0),
                endFraction.clamp(0.0, 1.0),
                curve: AppAnimations.defaultCurve,
              ),
            ),
          );

          return AnimatedBuilder(
            animation: itemAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: itemAnimation.value,
                child: Transform.translate(
                  offset: Offset(
                    0,
                    _kStaggerSlideOffset * (1 - itemAnimation.value),
                  ),
                  child: child,
                ),
              );
            },
            child: TemplateCard(template: templates[index], index: index),
          );
        },
      ),
    );
  }
}

class _ErrorMessage extends ConsumerStatefulWidget {
  const _ErrorMessage({required this.error, required this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  @override
  ConsumerState<_ErrorMessage> createState() => _ErrorMessageState();
}

class _ErrorMessageState extends ConsumerState<_ErrorMessage> {
  bool _didCapture = false;

  @override
  void initState() {
    super.initState();
    _captureOnce();
  }

  void _captureOnce() {
    if (_didCapture) return;
    _didCapture = true;
    unawaited(
      SentryConfig.captureException(
        widget.error,
        stackTrace: widget.stackTrace,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppExceptionMapper.toUserMessage(widget.error),
              style: AppTypography.bodySecondary(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton.icon(
              onPressed: () => ref.invalidate(templatesProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
