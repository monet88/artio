import 'dart:ui';

import 'package:artio/core/design_system/app_animations.dart';
import 'package:artio/features/gallery/domain/entities/gallery_item.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Glassmorphism info bottom sheet for the image viewer.
class ImageInfoBottomSheet extends StatelessWidget {
  const ImageInfoBottomSheet({
    required this.item,
    required this.onCopyPrompt,
    super.key,
  });

  final GalleryItem item;
  final VoidCallback onCopyPrompt;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy · h:mm a').format(item.createdAt);

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: AppAnimations.normal,
        curve: AppAnimations.sharpCurve,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: const Border(
                  top: BorderSide(color: AppColors.white10, width: 0.5),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.white20,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Template name
                    if (item.templateName.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.primaryCta,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            item.templateName,
                            style: const TextStyle(
                              color: AppColors.primaryCta,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Prompt with copy button
                    if (item.prompt?.isNotEmpty ?? false) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PROMPT',
                                  style: TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.prompt!,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          _GlassIconButton(
                            icon: Icons.content_copy_rounded,
                            onTap: onCopyPrompt,
                            tooltip: 'Copy prompt',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Metadata row
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.white05,
                        border: Border.all(
                          color: AppColors.white10,
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          _MetadataChip(
                            icon: Icons.calendar_today_rounded,
                            label: dateStr,
                          ),
                          const SizedBox(width: 12),
                          _MetadataChip(
                            icon: Icons.check_circle_outline_rounded,
                            label: item.status.name.toUpperCase(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted glass-style icon button for the info panel.
class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.white10,
              border: Border.all(color: AppColors.white10, width: 0.5),
            ),
            child: Icon(icon, color: Colors.white70, size: 18),
          ),
        ),
      ),
    );
  }
}

/// Small metadata chip for the info panel.
class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textHint, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
