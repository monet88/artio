import 'package:artio_admin/core/constants/app_constants.dart';
import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/templates/presentation/widgets/template_card.dart';
import 'package:artio_admin/features/templates/domain/entities/admin_template_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'templates_page.g.dart';

// --- Provider ---

@riverpod
class Templates extends _$Templates {
  @override
  Stream<List<AdminTemplateModel>> build() {
    return Supabase.instance.client
        .from('templates')
        .stream(primaryKey: ['id'])
        .order('order', ascending: true)
        .map(
          (rows) =>
              rows.map((row) => AdminTemplateModel.fromJson(row)).toList(),
        );
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final currentList = state.valueOrNull;
    if (currentList == null || currentList.isEmpty) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final reorderedList = List<AdminTemplateModel>.from(currentList);
    final item = reorderedList.removeAt(oldIndex);
    reorderedList.insert(newIndex, item);

    state = AsyncValue.data(reorderedList);

    final updates = <Map<String, dynamic>>[];
    for (int i = 0; i < reorderedList.length; i++) {
      final dbOrder = i + 1;
      if (reorderedList[i].order != dbOrder) {
        updates.add({'id': reorderedList[i].id, 'order': dbOrder});
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
}

// --- Page ---

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
      filtered = filtered
          .where((t) => t.category == _selectedCategory)
          .toList();
    }

    if (_showPremiumOnly) {
      filtered = filtered.where((t) => t.isPremium).toList();
    }

    if (_showInactiveOnly) {
      filtered = filtered.where((t) => !t.isActive).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final templatesAsync = ref.watch(templatesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
        actions: [
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
          // ── Search + Filters ────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search templates...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 12),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected:
                            _selectedCategory == null &&
                            !_showPremiumOnly &&
                            !_showInactiveOnly,
                        onSelected: (_) => setState(() {
                          _selectedCategory = null;
                          _showPremiumOnly = false;
                          _showInactiveOnly = false;
                        }),
                      ),
                      const SizedBox(width: 8),
                      ...AppConstants.templateCategories.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            selected: _selectedCategory == cat,
                            onSelected: (selected) => setState(() {
                              _selectedCategory = selected ? cat : null;
                            }),
                          ),
                        ),
                      ),
                      FilterChip(
                        label: const Text('Premium'),
                        avatar: Icon(
                          Icons.workspace_premium,
                          size: 16,
                          color: _showPremiumOnly
                              ? AdminColors.statAmber
                              : (isDark ? AdminColors.textMuted : Colors.grey),
                        ),
                        selected: _showPremiumOnly,
                        onSelected: (v) => setState(() => _showPremiumOnly = v),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Inactive'),
                        selected: _showInactiveOnly,
                        onSelected: (v) =>
                            setState(() => _showInactiveOnly = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Template List ───────────────────────────
          Expanded(
            child: templatesAsync.when(
              data: (templates) {
                final filtered = _applyFilters(templates);

                if (templates.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.style_outlined,
                          size: 64,
                          color: isDark
                              ? AdminColors.textHint
                              : Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No templates yet',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          onPressed: () => context.go('/templates/new'),
                          icon: const Icon(Icons.add),
                          label: const Text('Create First Template'),
                        ),
                      ],
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: isDark
                              ? AdminColors.textHint
                              : Colors.grey.shade300,
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
                  itemCount: filtered.length,
                  onReorder: (oldIndex, newIndex) async {
                    // Map filtered indices back to original indices
                    final allTemplates = templates;
                    final oldItem = filtered[oldIndex];
                    final newItem = newIndex < filtered.length
                        ? filtered[newIndex > oldIndex
                              ? newIndex - 1
                              : newIndex]
                        : filtered.last;
                    final realOldIndex = allTemplates.indexOf(oldItem);
                    final realNewIndex = allTemplates.indexOf(newItem);

                    if (realOldIndex == -1 || realNewIndex == -1) return;

                    try {
                      await ref
                          .read(templatesProvider.notifier)
                          .reorder(realOldIndex, realNewIndex);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to reorder: $e')),
                        );
                      }
                    }
                  },
                  itemBuilder: (context, index) {
                    final template = filtered[index];
                    return Container(
                      key: ValueKey(template.id),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: TemplateCard(
                        template: template,
                        onEdit: () => context.go('/templates/${template.id}'),
                        onDelete: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Template'),
                              content: Text('Delete "${template.name}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: AdminColors.error),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await ref
                                .read(templatesProvider.notifier)
                                .deleteTemplate(template.id);
                          }
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
