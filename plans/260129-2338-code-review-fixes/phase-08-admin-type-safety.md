# Phase 08: Admin Type Safety

## Parallelization Info

| Property | Value |
|----------|-------|
| Group | C (Flutter) |
| Can Run With | Phases 05, 06, 07 |
| Blocked By | Group B (Phases 03, 04) |
| Blocks | Group E (Phases 10, 11) |

## File Ownership (Exclusive)

- `admin/lib/features/templates/presentation/pages/templates_page.dart`
- `admin/lib/features/templates/domain/entities/admin_template_model.dart` (CREATE)
- `admin/lib/features/templates/presentation/widgets/template_card.dart`

## Priority: MEDIUM

**Issue**: Templates provider uses raw `Map<String, dynamic>` instead of typed models. No compile-time safety for template properties.

## Current State

```dart
@riverpod
class Templates extends _$Templates {
  @override
  Stream<List<Map<String, dynamic>>> build() {  // Untyped!
    return Supabase.instance.client
        .from('templates')
        .stream(primaryKey: ['id'])
        .order('order', ascending: true);
  }
}
```

Usage relies on string keys:
```dart
template['id']
template['order']
template['name']
// No compile-time checking!
```

## Implementation Steps

### Step 1: Create AdminTemplateModel

Create `admin/lib/features/templates/domain/entities/admin_template_model.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_template_model.freezed.dart';
part 'admin_template_model.g.dart';

@freezed
class AdminTemplateModel with _$AdminTemplateModel {
  const factory AdminTemplateModel({
    required String id,
    required String name,
    required String description,
    required String category,
    required String promptTemplate,
    required int order,
    @Default(false) bool isPremium,
    String? thumbnailUrl,
    @Default([]) List<Map<String, dynamic>> inputFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AdminTemplateModel;

  factory AdminTemplateModel.fromJson(Map<String, dynamic> json) =>
      _$AdminTemplateModelFromJson(json);
}
```

### Step 2: Update Provider with Type Mapping

```dart
import 'package:artio_admin/features/templates/presentation/widgets/template_card.dart';
import 'package:artio_admin/features/templates/domain/entities/template_model.dart';
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
        .map((rows) => rows
            .map((row) => AdminTemplateModel.fromJson(row))
            .toList());
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
      final dbOrder = i + 1;
      if (reorderedList[i].order != dbOrder) {
        updates.add({
          'id': reorderedList[i].id,
          'order': dbOrder,
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
```

### Step 3: Update TemplatesPage Widget

```dart
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
                key: ValueKey(template.id),  // Type-safe!
                margin: const EdgeInsets.only(bottom: 8),
                child: TemplateCard(
                  template: template,  // Pass typed model
                  onEdit: () => context.go('/templates/${template.id}'),
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Template'),
                        content: Text('Delete "${template.name}"?'),  // Type-safe!
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
```

### Step 4: Update TemplateCard Widget

Update `admin/lib/features/templates/presentation/widgets/template_card.dart` to accept `AdminTemplateModel`:

```dart
class TemplateCard extends StatelessWidget {
  final AdminTemplateModel template;  // Changed from Map
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TemplateCard({
    super.key,
    required this.template,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: template.thumbnailUrl != null
            ? Image.network(template.thumbnailUrl!, width: 50, height: 50)
            : const Icon(Icons.image),
        title: Text(template.name),
        subtitle: Text(template.category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
```

## Success Criteria

- [ ] `AdminTemplateModel` created with Freezed
- [ ] Provider returns typed `List<AdminTemplateModel>`
- [ ] All template property access is type-safe
- [ ] Compile-time errors if accessing wrong properties
- [ ] Run `dart run build_runner build` in admin directory
- [ ] `flutter analyze` passes

## Conflict Prevention

- Only this phase modifies admin template files
- Creates new files in `admin/lib/features/templates/domain/`

## Post-Implementation

```bash
cd admin
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```
