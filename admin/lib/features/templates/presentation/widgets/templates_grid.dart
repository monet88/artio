import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/templates/domain/entities/admin_template_model.dart';
import 'package:artio_admin/features/templates/presentation/widgets/template_card.dart';
import 'package:flutter/material.dart';

/// Displays the list of templates with reordering, selection, and empty states.
class TemplatesGrid extends StatelessWidget {
  final List<AdminTemplateModel> allTemplates;
  final List<AdminTemplateModel> filteredTemplates;
  final Set<String> selectedIds;
  final bool isSelectionMode;
  final bool isDark;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(String id) onToggleSelect;
  final void Function(String id) onLongPress;
  final void Function(String id) onEdit;
  final Future<void> Function(AdminTemplateModel template) onDelete;

  const TemplatesGrid({
    super.key,
    required this.allTemplates,
    required this.filteredTemplates,
    required this.selectedIds,
    required this.isSelectionMode,
    required this.isDark,
    required this.onReorder,
    required this.onToggleSelect,
    required this.onLongPress,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (allTemplates.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.style_outlined,
              size: 64,
              color: isDark ? AdminColors.textHint : Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text('No templates yet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
          ],
        ),
      );
    }

    if (filteredTemplates.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: isDark ? AdminColors.textHint : Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              'No templates match your filters',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      itemCount: filteredTemplates.length,
      onReorder: onReorder,
      itemBuilder: (context, index) {
        final template = filteredTemplates[index];
        return Container(
          key: ValueKey(template.id),
          margin: const EdgeInsets.only(bottom: 8),
          child: TemplateCard(
            template: template,
            isSelected:
                isSelectionMode ? selectedIds.contains(template.id) : null,
            onLongPress:
                isSelectionMode ? null : () => onLongPress(template.id),
            onToggleSelect: () => onToggleSelect(template.id),
            onEdit: () => onEdit(template.id),
            onDelete: () => onDelete(template),
          ),
        );
      },
    );
  }
}
