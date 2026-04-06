import 'package:artio_admin/features/templates/domain/entities/admin_template_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for the reorder logic used by the Templates notifier.
///
/// The actual notifier ([Templates]) accesses Supabase.instance.client
/// directly (static singleton), making full integration tests brittle.
/// We test the pure reorder-list + upsert-payload logic here.
void main() {
  group('reorder logic', () {
    test('computes correct sort_order upsert payload', () {
      final items = _makeItems(['a', 'b', 'c', 'd'], [1, 2, 3, 4]);

      // Simulate moving index 0 → 2 (a moves after c)
      const oldIndex = 0;
      var newIndex = 2;
      if (oldIndex < newIndex) newIndex -= 1;

      final reordered = List<AdminTemplateModel>.from(items);
      final item = reordered.removeAt(oldIndex);
      reordered.insert(newIndex, item);

      // Compute updates (same logic as Templates.reorder)
      final updates = <Map<String, dynamic>>[];
      for (int i = 0; i < reordered.length; i++) {
        final dbOrder = i + 1;
        if (reordered[i].order != dbOrder) {
          updates.add({'id': reordered[i].id, 'sort_order': dbOrder});
        }
      }

      // After move: [b, a, c, d] → b=1, a=2, c stays 3, d stays 4
      expect(reordered.map((e) => e.id).toList(), ['b', 'a', 'c', 'd']);
      expect(updates, hasLength(2));
      expect(updates[0], {'id': 'b', 'sort_order': 1});
      expect(updates[1], {'id': 'a', 'sort_order': 2});
    });

    test('no-op when list is empty', () {
      final items = <AdminTemplateModel>[];

      // Reorder on empty list should produce no updates
      final updates = <Map<String, dynamic>>[];
      for (int i = 0; i < items.length; i++) {
        final dbOrder = i + 1;
        if (items[i].order != dbOrder) {
          updates.add({'id': items[i].id, 'sort_order': dbOrder});
        }
      }

      expect(updates, isEmpty);
    });

    test('no updates when order unchanged', () {
      final items = _makeItems(['a', 'b', 'c'], [1, 2, 3]);

      // "Move" index 1 → 1 (no actual change)
      final reordered = List<AdminTemplateModel>.from(items);

      final updates = <Map<String, dynamic>>[];
      for (int i = 0; i < reordered.length; i++) {
        final dbOrder = i + 1;
        if (reordered[i].order != dbOrder) {
          updates.add({'id': reordered[i].id, 'sort_order': dbOrder});
        }
      }

      expect(updates, isEmpty);
    });

    test('moving last item to first computes full reorder', () {
      final items = _makeItems(['a', 'b', 'c'], [1, 2, 3]);

      // Move index 2 → 0 (c moves to first)
      const oldIndex = 2;
      var newIndex = 0;
      if (oldIndex < newIndex) newIndex -= 1;

      final reordered = List<AdminTemplateModel>.from(items);
      final item = reordered.removeAt(oldIndex);
      reordered.insert(newIndex, item);

      final updates = <Map<String, dynamic>>[];
      for (int i = 0; i < reordered.length; i++) {
        final dbOrder = i + 1;
        if (reordered[i].order != dbOrder) {
          updates.add({'id': reordered[i].id, 'sort_order': dbOrder});
        }
      }

      // After move: [c, a, b] → c=1(was 3), a=2(was 1), b=3(was 2)
      expect(reordered.map((e) => e.id).toList(), ['c', 'a', 'b']);
      expect(updates, hasLength(3));
      expect(updates[0], {'id': 'c', 'sort_order': 1});
      expect(updates[1], {'id': 'a', 'sort_order': 2});
      expect(updates[2], {'id': 'b', 'sort_order': 3});
    });

    test('upsert payload always uses sort_order key not order', () {
      final items = _makeItems(['x', 'y'], [1, 2]);

      // Swap
      final reordered = List<AdminTemplateModel>.from(items.reversed);

      final updates = <Map<String, dynamic>>[];
      for (int i = 0; i < reordered.length; i++) {
        final dbOrder = i + 1;
        if (reordered[i].order != dbOrder) {
          updates.add({'id': reordered[i].id, 'sort_order': dbOrder});
        }
      }

      for (final update in updates) {
        expect(update.containsKey('sort_order'), isTrue,
            reason: 'Upsert payload must use sort_order key');
        expect(update.containsKey('order'), isFalse,
            reason: 'Upsert payload must NOT use order key');
      }
    });
  });
}

// -- Helpers --

List<AdminTemplateModel> _makeItems(List<String> ids, List<int> orders) {
  return List.generate(
    ids.length,
    (i) => AdminTemplateModel(
      id: ids[i],
      name: 'Template ${ids[i]}',
      description: 'Desc',
      category: 'Test',
      promptTemplate: 'Generate {prompt}',
      order: orders[i],
    ),
  );
}
