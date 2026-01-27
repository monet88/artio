---
title: "Phase 8: Admin App"
status: pending
effort: 3h
---

# Phase 8: Admin App

## Context Links

- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Supabase RLS Policies](https://supabase.com/docs/guides/auth/row-level-security)
- [ReorderableListView](https://api.flutter.dev/flutter/material/ReorderableListView-class.html)

## Overview

**Priority**: P2 (Medium)
**Status**: pending
**Effort**: 3h

Separate Flutter web app for non-technical team members to manage templates without code changes.

## Key Insights

1. Separate Flutter project required - admin app should not bundle with main user app
2. Admin role enforcement via Supabase RLS - database-level security, not just UI
3. Card-based UI better than tables for template management (more visual)
4. ReorderableListView for drag-and-drop template ordering
5. JSON editor for input fields requires validation before save

## Requirements

### Functional
- Card grid UI for template management (not table)
- Template fields: Name, Preset prompt, Category, Sample images
- Status workflow: Draft → Published
- Template preview
- Reorder templates
- Enable/disable templates
- View generation statistics
- Auth: Email/Password login

### Non-Functional
- Separate Flutter web project
- Admin-only access
- Clean, simple UI

## Architecture

### Admin App Structure
```
admin/
├── lib/
│   ├── core/
│   │   ├── router/
│   │   └── theme/
│   ├── features/
│   │   ├── auth/
│   │   ├── templates/
│   │   └── analytics/
│   └── main.dart
├── pubspec.yaml
└── web/
```

### Supabase RLS

Admin users identified by `role` column in profiles table.

```sql
-- Add role column
ALTER TABLE profiles ADD COLUMN role TEXT DEFAULT 'user';

-- Admin RLS for templates
CREATE POLICY "Admins can manage templates"
ON templates
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
);
```

## Related Code Files

### Files to Create
- `admin/lib/main.dart`
- `admin/lib/core/router/app_router.dart`
- `admin/lib/core/theme/theme.dart`
- `admin/lib/features/auth/domain/admin_auth_notifier.dart`
- `admin/lib/features/auth/presentation/pages/login_page.dart`
- `admin/lib/features/templates/presentation/pages/templates_page.dart`
- `admin/lib/features/templates/presentation/pages/template_editor_page.dart`
- `admin/lib/features/analytics/presentation/pages/analytics_page.dart`
- `admin/pubspec.yaml`
- `admin/web/index.html`

### Files to Modify
- `supabase/migrations/` - Add admin role to profiles table
- `supabase/migrations/` - Add admin RLS policies for templates table

### Files to Delete
- None

### Database Schema
See "Supabase RLS" section in Architecture above.

## Implementation Steps

### 1. Create Admin Project
```bash
flutter create --org com.artio --project-name artio_admin admin
cd admin
flutter config --enable-web
```

### 2. Template Management Page
```dart
// admin/lib/features/templates/presentation/pages/templates_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TemplatesPage extends ConsumerStatefulWidget {
  const TemplatesPage({super.key});

  @override
  ConsumerState<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends ConsumerState<TemplatesPage> {
  List<Map<String, dynamic>> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    final response = await Supabase.instance.client
        .from('templates')
        .select()
        .order('order', ascending: true);

    setState(() {
      _templates = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
    });
  }

  Future<void> _deleteTemplate(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await Supabase.instance.client.from('templates').delete().eq('id', id);
      _loadTemplates();
    }
  }

  Future<void> _toggleActive(String id, bool isActive) async {
    await Supabase.instance.client
        .from('templates')
        .update({'is_active': isActive})
        .eq('id', id);
    _loadTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTemplates,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTemplateEditor(null),
        icon: const Icon(Icons.add),
        label: const Text('New Template'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ReorderableListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _templates.length,
              onReorder: _onReorder,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return Card(
                  key: ValueKey(template['id']),
                  child: ListTile(
                    leading: template['thumbnail_url'] != null
                        ? Image.network(
                            template['thumbnail_url'],
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image, size: 56),
                    title: Text(template['name']),
                    subtitle: Text(
                      '${template['category']} • ${template['is_premium'] ? 'Premium' : 'Free'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: template['is_active'] ?? false,
                          onChanged: (value) =>
                              _toggleActive(template['id'], value),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showTemplateEditor(template),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTemplate(template['id']),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    setState(() {
      final item = _templates.removeAt(oldIndex);
      _templates.insert(newIndex, item);
    });
    _updateOrder();
  }

  Future<void> _updateOrder() async {
    for (int i = 0; i < _templates.length; i++) {
      await Supabase.instance.client
          .from('templates')
          .update({'order': i})
          .eq('id', _templates[i]['id']);
    }
  }

  void _showTemplateEditor(Map<String, dynamic>? template) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TemplateEditorPage(
          template: template,
          onSaved: _loadTemplates,
        ),
      ),
    );
  }
}
```

### 3. Template Editor Page
```dart
// admin/lib/features/templates/presentation/pages/template_editor_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TemplateEditorPage extends StatefulWidget {
  final Map<String, dynamic>? template;
  final VoidCallback onSaved;

  const TemplateEditorPage({
    super.key,
    this.template,
    required this.onSaved,
  });

  @override
  State<TemplateEditorPage> createState() => _TemplateEditorPageState();
}

class _TemplateEditorPageState extends State<TemplateEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _promptTemplateController;
  late TextEditingController _inputFieldsController;
  late TextEditingController _thumbnailUrlController;
  bool _isPremium = false;
  String _defaultAspectRatio = '1:1';

  bool get _isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _nameController = TextEditingController(text: t?['name'] ?? '');
    _descriptionController = TextEditingController(text: t?['description'] ?? '');
    _categoryController = TextEditingController(text: t?['category'] ?? '');
    _promptTemplateController = TextEditingController(text: t?['prompt_template'] ?? '');
    _inputFieldsController = TextEditingController(
      text: t?['input_fields'] != null
          ? const JsonEncoder.withIndent('  ').convert(t!['input_fields'])
          : '[]',
    );
    _thumbnailUrlController = TextEditingController(text: t?['thumbnail_url'] ?? '');
    _isPremium = t?['is_premium'] ?? false;
    _defaultAspectRatio = t?['default_aspect_ratio'] ?? '1:1';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _promptTemplateController.dispose();
    _inputFieldsController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    List<dynamic> inputFields;
    try {
      inputFields = jsonDecode(_inputFieldsController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid JSON in input fields')),
      );
      return;
    }

    final data = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'category': _categoryController.text.trim(),
      'prompt_template': _promptTemplateController.text.trim(),
      'input_fields': inputFields,
      'thumbnail_url': _thumbnailUrlController.text.trim().isEmpty
          ? null
          : _thumbnailUrlController.text.trim(),
      'is_premium': _isPremium,
      'default_aspect_ratio': _defaultAspectRatio,
      'updated_at': DateTime.now().toIso8601String(),
    };

    try {
      if (_isEditing) {
        await Supabase.instance.client
            .from('templates')
            .update(data)
            .eq('id', widget.template!['id']);
      } else {
        await Supabase.instance.client.from('templates').insert(data);
      }

      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Template' : 'New Template'),
        actions: [
          FilledButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g., 3D Render, Photo Editing',
              ),
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _promptTemplateController,
              decoration: const InputDecoration(
                labelText: 'Prompt Template',
                hintText: 'Use {variable} for input placeholders',
              ),
              maxLines: 4,
              validator: (v) => v?.isEmpty == true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _inputFieldsController,
              decoration: const InputDecoration(
                labelText: 'Input Fields (JSON)',
                hintText: '[{"name": "style", "label": "Style", "type": "select", "options": ["Modern", "Classic"]}]',
              ),
              maxLines: 8,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _thumbnailUrlController,
              decoration: const InputDecoration(labelText: 'Thumbnail URL'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _defaultAspectRatio,
              decoration: const InputDecoration(labelText: 'Default Aspect Ratio'),
              items: ['1:1', '4:3', '3:4', '16:9', '9:16']
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _defaultAspectRatio = v!),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Premium Template'),
              subtitle: const Text('Requires Pro subscription'),
              value: _isPremium,
              onChanged: (v) => setState(() => _isPremium = v),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. Admin Auth Guard
```dart
// admin/lib/features/auth/domain/admin_auth_notifier.dart
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'admin_auth_notifier.g.dart';

@riverpod
class AdminAuthNotifier extends _$AdminAuthNotifier implements Listenable {
  VoidCallback? _listener;

  @override
  AsyncValue<bool> build() {
    _checkAdmin();
    return const AsyncValue.loading();
  }

  Future<void> _checkAdmin() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      state = const AsyncValue.data(false);
      _listener?.call();
      return;
    }

    final profile = await Supabase.instance.client
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    final isAdmin = profile?['role'] == 'admin';
    state = AsyncValue.data(isAdmin);
    _listener?.call();
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await _checkAdmin();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = const AsyncValue.data(false);
    _listener?.call();
  }

  String? redirect(String currentPath) {
    final isLoading = state.isLoading;
    if (isLoading) return null;

    final isAdmin = state.value == true;
    final isLoginPage = currentPath == '/login';

    if (!isAdmin && !isLoginPage) return '/login';
    if (isAdmin && isLoginPage) return '/';

    return null;
  }

  @override
  void addListener(VoidCallback listener) => _listener = listener;

  @override
  void removeListener(VoidCallback listener) => _listener = null;
}
```

## Todo List

- [ ] Create admin Flutter web project
- [ ] Set up shared Supabase config
- [ ] Add admin role to profiles table
- [ ] Create RLS policies for admin access
- [ ] Implement admin auth guard
- [ ] Create templates list page
- [ ] Create template editor page
- [ ] Add reordering functionality
- [ ] Add input fields JSON editor
- [ ] Test CRUD operations
- [ ] Deploy admin app separately

## Success Criteria

- [ ] Only admin users can access
- [ ] Templates CRUD works
- [ ] Reordering updates order column
- [ ] Input fields JSON validates
- [ ] Changes reflect in main app
- [ ] Admin app deploys separately from main app

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Non-admin users bypass RLS | Low | High | Database-level RLS policies, server-side validation |
| Invalid JSON breaks templates | Medium | Medium | Client-side JSON validation before save |
| Accidental template deletion | Medium | High | Confirmation dialog before delete |
| Admin credentials compromised | Low | High | Strong password requirements, MFA for admin accounts |
| Template order conflicts | Low | Low | Sequential update, optimistic UI with rollback |

## Security Considerations

- Admin role enforced at database level via Supabase RLS
- Admin login requires email/password (no social auth for admin accounts)
- All template mutations go through RLS policies
- No direct database access from admin UI
- Audit log for template changes (future enhancement)

## Next Steps

**Deployment**: Admin app should be deployed to a separate URL (e.g., admin.artio.app) with Cloudflare Pages, Vercel, or Netlify.

After completing Phase 8:
1. End-to-end testing
2. Performance optimization
3. Error monitoring setup
4. Production deployment
