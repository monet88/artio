import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../domain/entities/admin_template_model.dart';

class TemplateCard extends StatelessWidget {
  final AdminTemplateModel template;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPremium = template.isPremium;
    final isActive = template.isActive;
    final thumbnailUrl = template.thumbnailUrl;

    return Card(
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ── Thumbnail ───────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: thumbnailUrl != null
                      ? CachedNetworkImage(
                          imageUrl: thumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: isDark
                                ? AdminColors.surfaceElevated
                                : Colors.grey.shade200,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: isDark
                                ? AdminColors.surfaceElevated
                                : Colors.grey.shade200,
                            child: const Icon(Icons.broken_image, size: 20),
                          ),
                        )
                      : Container(
                          color: isDark
                              ? AdminColors.surfaceElevated
                              : Colors.grey.shade200,
                          child: Icon(
                            Icons.image_not_supported,
                            size: 20,
                            color: isDark
                                ? AdminColors.textHint
                                : Colors.grey.shade400,
                          ),
                        ),
                ),
              ),
              const Gap(16),

              // ── Content ─────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            template.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPremium) ...[
                          const Gap(8),
                          _Badge(
                            label: 'PREMIUM',
                            color: AdminColors.statAmber,
                            isDark: isDark,
                          ),
                        ],
                        if (!isActive) ...[
                          const Gap(8),
                          _Badge(
                            label: 'INACTIVE',
                            color: Colors.grey,
                            isDark: isDark,
                          ),
                        ],
                      ],
                    ),
                    const Gap(4),

                    // Description
                    Text(
                      template.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AdminColors.textSecondary
                            : Colors.grey.shade600,
                      ),
                    ),
                    const Gap(6),

                    // Meta row
                    Row(
                      children: [
                        Icon(Icons.category_outlined,
                            size: 14,
                            color:
                                isDark ? AdminColors.textHint : theme.hintColor),
                        const Gap(4),
                        Text(
                          template.category,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AdminColors.textHint
                                : theme.hintColor,
                          ),
                        ),
                        const Gap(12),
                        Icon(Icons.aspect_ratio,
                            size: 14,
                            color:
                                isDark ? AdminColors.textHint : theme.hintColor),
                        const Gap(4),
                        Text(
                          template.defaultAspectRatio,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? AdminColors.textHint
                                : theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Actions ─────────────────────────
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: AdminColors.error),
                      onPressed: onDelete,
                      tooltip: 'Delete',
                    ),
                  Icon(Icons.drag_handle,
                      size: 20,
                      color: isDark ? AdminColors.textHint : Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _Badge({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
      ),
    );
  }
}
