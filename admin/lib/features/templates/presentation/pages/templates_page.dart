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
        .map((rows) => rows.map((row) => AdminTemplateModel.fromJson(row)).toList());
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final currentList = state.valueOrNull;
    if (currentList == null || currentList.isEmpty) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Create immutable copy for state update
    final reorderedList = List<AdminTemplateModel>.from(currentList);
    final item = reorderedList.removeAt(oldIndex);
    reorderedList.insert(newIndex, item);

    // Optimistic update with new list instance
    state = AsyncValue.data(reorderedList);

    // Batch update order in Supabase (1-indexed to match DB convention)
    final updates = <Map<String, dynamic>>[];
    for (int i = 0; i < reorderedList.length; i++) {
      final dbOrder = i + 1; // Convert to 1-indexed
      if (reorderedList[i].order != dbOrder) {
        updates.add({
          'id': reorderedList[i].id,
          'order': dbOrder,
        });
      }
    }

    if (updates.isNotEmpty) {
      try {
        await Supabase.instance.client.from('templates').upsert(updates);
      } catch (e) {
        // Rollback on failure
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

class TemplatesPage extends ConsumerWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/templates/new'),
        label: const Text('New Template'),
        icon: const Icon(Icons.add),
      ),
      body: templatesAsync.when(
        data: (templates) {
          if (templates.isEmpty) {
            return const Center(child: Text('No templates found'));
          }
          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            onReorder: (oldIndex, newIndex) async {
              try {
                await ref.read(templatesProvider.notifier).reorder(oldIndex, newIndex);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to reorder: $e')),
                  );
                }
              }
            },
            itemBuilder: (context, index) {
              final template = templates[index];
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
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref.read(templatesProvider.notifier).deleteTemplate(template.id);
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
    );
  }
}
