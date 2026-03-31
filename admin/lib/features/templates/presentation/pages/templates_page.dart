import 'package:artio_admin/features/templates/domain/entities/admin_template_model.dart';
import 'package:artio_admin/features/templates/presentation/widgets/bulk_actions_bar.dart';
import 'package:artio_admin/features/templates/presentation/widgets/templates_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'templates_page.g.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

@riverpod
class Templates extends _$Templates {
  @override
  Stream<List<AdminTemplateModel>> build() {
    return Supabase.instance.client
        .from('templates')
        .stream(primaryKey: ['id'])
        .order('sort_order', ascending: true)
        .map(
          (rows) =>
              rows.map((row) => AdminTemplateModel.fromJson(row)).toList(),
        );
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final currentList = state.valueOrNull;
    if (currentList == null || currentList.isEmpty) return;

    if (oldIndex < newIndex) newIndex -= 1;

    final reorderedList = List<AdminTemplateModel>.from(currentList);
    final item = reorderedList.removeAt(oldIndex);
    reorderedList.insert(newIndex, item);

    state = AsyncValue.data(reorderedList);

    final updates = <Map<String, dynamic>>[];
    for (var i = 0; i < reorderedList.length; i++) {
      final dbOrder = i + 1;
      if (reorderedList[i].order != dbOrder) {
        updates.add({'id': reorderedList[i].id, 'sort_order': dbOrder});
      }
    }

    if (updates.isNotEmpty) {
      try {
        await Supabase.instance.client.from('templates').upsert(updates);
      } catch (e) {
        state = AsyncValue.data(currentList);
        rethrow;
      }
    }
  }

  Future<void> deleteTemplate(String id) async {
    await Supabase.instance.client.from('templates').delete().eq('id', id);
  }

  Future<void> bulkSetActive(List<String> ids, {required bool isActive}) async {
    await Supabase.instance.client
        .from('templates')
        .update({
          'is_active': isActive,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .inFilter('id', ids);
  }
}

// ── Page ─────────────────────────────────────────────────────────────────────

class TemplatesPage extends ConsumerStatefulWidget {
  const TemplatesPage({super.key});

  @override
  ConsumerState<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends ConsumerState<TemplatesPage> {
  String _searchQuery = '';
  String? _selectedCategory;
  bool _showPremiumOnly = false;
  bool _showInactiveOnly = false;
  final Set<String> _selectedIds = {};

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  List<AdminTemplateModel> _applyFilters(List<AdminTemplateModel> templates) {
    var filtered = templates;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where(
            (t) =>
                t.name.toLowerCase().contains(query) ||
                t.description.toLowerCase().contains(query),
          )
          .toList();
    }
    if (_selectedCategory != null) {
      filtered =
          filtered.where((t) => t.category == _selectedCategory).toList();
    }
    if (_showPremiumOnly) filtered = filtered.where((t) => t.isPremium).toList();
    if (_showInactiveOnly) {
      filtered = filtered.where((t) => !t.isActive).toList();
    }
    return filtered;
  }

  Future<void> _bulkAction({required bool isActive}) async {
    final ids = _selectedIds.toList();
    try {
      await ref
          .read(templatesProvider.notifier)
          .bulkSetActive(ids, isActive: isActive);
      if (!mounted) return;
      setState(() => _selectedIds.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${ids.length} templates ${isActive ? 'activated' : 'deactivated'}',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete(AdminTemplateModel template) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: Text('Delete "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref
          .read(templatesProvider.notifier)
          .deleteTemplate(template.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(templatesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedIds.length} selected')
            : const Text('Templates'),
        actions: _isSelectionMode
            ? [
                TextButton.icon(
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: Text('Activate ${_selectedIds.length}'),
                  onPressed: () => _bulkAction(isActive: true),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: Text('Deactivate ${_selectedIds.length}'),
                  onPressed: () => _bulkAction(isActive: false),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => setState(() => _selectedIds.clear()),
                ),
                const SizedBox(width: 8),
              ]
            : [
                FilledButton.icon(
                  onPressed: () => context.go('/templates/new'),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Template'),
                ),
                const SizedBox(width: 16),
              ],
      ),
      body: Column(
        children: [
          TemplateSearchBar(
            searchQuery: _searchQuery,
            selectedCategory: _selectedCategory,
            showPremiumOnly: _showPremiumOnly,
            showInactiveOnly: _showInactiveOnly,
            isDark: isDark,
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onCategoryChanged: (v) => setState(() => _selectedCategory = v),
            onPremiumChanged: (v) => setState(() => _showPremiumOnly = v),
            onInactiveChanged: (v) => setState(() => _showInactiveOnly = v),
            onClearFilters: () => setState(() {
              _selectedCategory = null;
              _showPremiumOnly = false;
              _showInactiveOnly = false;
            }),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: templatesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
              data: (templates) => TemplatesGrid(
                allTemplates: templates,
                filteredTemplates: _applyFilters(templates),
                selectedIds: _selectedIds,
                isSelectionMode: _isSelectionMode,
                isDark: isDark,
                onReorder: (oldIndex, newIndex) async {
                  if (_applyFilters(templates).length != templates.length) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Clear filters before reordering'),
                        ),
                      );
                    }
                    return;
                  }
                  try {
                    await ref
                        .read(templatesProvider.notifier)
                        .reorder(oldIndex, newIndex);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to reorder: $e')),
                      );
                    }
                  }
                },
                onToggleSelect: (id) => setState(() {
                  if (_selectedIds.contains(id)) {
                    _selectedIds.remove(id);
                  } else {
                    _selectedIds.add(id);
                  }
                }),
                onLongPress: (id) => setState(() => _selectedIds.add(id)),
                onEdit: (id) => context.go('/templates/$id'),
                onDelete: _confirmDelete,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
