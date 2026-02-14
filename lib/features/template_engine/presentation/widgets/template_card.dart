import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/core/design_system/app_gradients.dart';
import 'package:artio/core/design_system/app_shadows.dart';
import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../domain/entities/template_model.dart';
import '../../../../routing/routes/app_routes.dart';

/// Redesigned template card with gradient overlay on thumbnail,
/// text on overlay, PRO badge as gradient chip with crown icon,
/// category tag, subtle shadow, CachedNetworkImage, and tap animation.
class TemplateCard extends StatefulWidget {
  final TemplateModel template;
  final int index;

  const TemplateCard({
    super.key,
    required this.template,
    this.index = 0,
  });

  @override
  State<TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<TemplateCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tapController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: AppAnimations.fast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _tapController, curve: AppAnimations.defaultCurve),
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _tapController.forward();
  void _onTapUp(TapUpDetails _) => _tapController.reverse();
  void _onTapCancel() => _tapController.reverse();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final template = widget.template;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: () => TemplateDetailRoute(id: template.id).push(context),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark ? AppShadows.cardShadowDark : AppShadows.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Thumbnail Image ─────────────────────────────────
                CachedNetworkImage(
                  imageUrl: template.thumbnailUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: isDark
                        ? AppColors.shimmerBase
                        : const Color(0xFFE8EAF0),
                    highlightColor: isDark
                        ? AppColors.shimmerHighlight
                        : const Color(0xFFF3F4F8),
                    child: Container(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: isDark
                        ? AppColors.darkSurface2
                        : AppColors.lightSurface2,
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: isDark
                          ? AppColors.textMuted
                          : AppColors.textMutedLight,
                      size: 32,
                    ),
                  ),
                ),

                // ── Gradient Overlay ────────────────────────────────
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.cardOverlay,
                  ),
                ),

                // ── Category Tag (top-left) ─────────────────────────
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.black40,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      template.category,
                      style: AppTypography.labelTag.copyWith(
                        color: AppColors.white60,
                      ),
                    ),
                  ),
                ),

                // ── PRO Badge (top-right) ───────────────────────────
                if (template.isPremium)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppGradients.primaryGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'PRO',
                            style: AppTypography.labelBadge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Bottom Text Overlay ─────────────────────────────
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      template.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Color(0x80000000),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
