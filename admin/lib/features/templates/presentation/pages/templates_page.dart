import 'package:artio_admin/features/templates/presentation/widgets/template_card.dart';
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
  Stream<List<Map<String, dynamic>>> build() {
    return Supabase.instance.client
        .from('templates')
        .stream(primaryKey: ['id'])
        .order('order', ascending: true);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final currentList = state.valueOrNull ?? [];
    if (currentList.isEmpty) return;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = currentList.removeAt(oldIndex);
    currentList.insert(newIndex, item);

    // Optimistic update
    state = AsyncValue.data(currentList);

    // Batch update order in Supabase
    // Note: In a real app with pagination, this needs more logic.
    // For admin with limited templates, updating all orders is okay-ish,
    // but updating only affected range is better.
    // For simplicity, we just update the changed items' order field.
    
    final updates = <Map<String, dynamic>>[];
    for (int i = 0; i < currentList.length; i++) {
      if (currentList[i]['order'] != i) {
        updates.add({
          'id': currentList[i]['id'],
          'order': i,
        });
      }
    }

    if (updates.isNotEmpty) {
      await Supabase.instance.client.from('templates').upsert(updates);
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
            onReorder: (oldIndex, newIndex) {
              ref.read(templatesProvider.notifier).reorder(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final template = templates[index];
              return Container(
                key: ValueKey(template['id']),
                margin: const EdgeInsets.only(bottom: 8),
                child: TemplateCard(
                  template: template,
                  onEdit: () => context.go('/templates/${template['id']}'),
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Template'),
                        content: const Text('Are you sure you want to delete this template?'),
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
                      await ref.read(templatesProvider.notifier).deleteTemplate(template['id']);
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
