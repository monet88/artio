import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class TemplateCard extends StatelessWidget {
  final Map<String, dynamic> template;
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
    final isPremium = template['is_premium'] as bool? ?? false;
    final isActive = template['is_active'] as bool? ?? true;
    final thumbnailUrl = template['thumbnail_url'] as String?;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 80,
            height: 80,
            child: thumbnailUrl != null
                ? CachedNetworkImage(
                    imageUrl: thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  ),
          ),
        ),
        title: Row(
          children: [
            Text(
              template['name'] ?? 'Untitled',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (isPremium) ...[
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.amber),
                ),
                child: Text(
                  'PREMIUM',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.amber[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            if (!isActive) ...[
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey),
                ),
                child: Text(
                  'INACTIVE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(4),
            Text(
              template['description'] ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const Gap(4),
            Row(
              children: [
                Icon(Icons.category_outlined, size: 14, color: theme.hintColor),
                const Gap(4),
                Text(
                  template['category'] ?? 'Uncategorized',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
                const Gap(12),
                Icon(Icons.aspect_ratio, size: 14, color: theme.hintColor),
                const Gap(4),
                Text(
                  template['default_aspect_ratio'] ?? '1:1',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: 'Edit Template',
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
                tooltip: 'Delete Template',
              ),
            // ReorderableListView handles the drag handle automatically,
            // or we can add a custom one if needed. Using default for now.
            const Icon(Icons.drag_handle, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
