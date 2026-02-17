import 'dart:convert';
import 'package:artio_admin/core/constants/app_constants.dart';
import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TemplateEditorPage extends ConsumerStatefulWidget {
  final String? templateId;

  const TemplateEditorPage({super.key, this.templateId});

  @override
  ConsumerState<TemplateEditorPage> createState() => _TemplateEditorPageState();
}

class _TemplateEditorPageState extends ConsumerState<TemplateEditorPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInit = true;
  late final TabController _tabController;

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _promptTemplateController = TextEditingController();
  final _inputFieldsController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();

  // Dropdown Values
  String? _selectedCategory;
  String _selectedAspectRatio = '1:1';

  // State
  bool _isPremium = false;
  bool _isActive = true;

  static const _aspectRatios = ['1:1', '16:9', '9:16', '4:3', '3:4'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _loadData();
      _isInit = false;
    }
  }

  Future<void> _loadData() async {
    if (widget.templateId == null) {
      _inputFieldsController.text = const JsonEncoder.withIndent('  ').convert([
        {
          "id": "style",
          "label": "Style",
          "type": "select",
          "options": ["Realistic", "Anime", "Oil Painting"],
          "defaultValue": "Realistic"
        }
      ]);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = await Supabase.instance.client
          .from('templates')
          .select()
          .eq('id', widget.templateId!)
          .single();

      _nameController.text = data['name'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _promptTemplateController.text = data['prompt_template'] ?? '';
      _thumbnailUrlController.text = data['thumbnail_url'] ?? '';

      final category = data['category'] as String?;
      _selectedCategory = category;

      final ratio = data['default_aspect_ratio'] as String?;
      if (ratio != null && _aspectRatios.contains(ratio)) {
        _selectedAspectRatio = ratio;
      }

      _isPremium = data['is_premium'] ?? false;
      _isActive = data['is_active'] ?? true;

      if (data['input_fields'] != null) {
        _inputFieldsController.text =
            const JsonEncoder.withIndent('  ').convert(data['input_fields']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading template: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      // Switch to the tab with invalid fields
      // Basic info fields are on tab 0
      return;
    }

    dynamic inputFieldsJson;
    try {
      inputFieldsJson = jsonDecode(_inputFieldsController.text);
      if (inputFieldsJson is! List) {
        throw const FormatException('Input fields must be a JSON list');
      }
    } catch (e) {
      _tabController.animateTo(1); // Switch to Config tab
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid JSON in Input Fields: $e')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updates = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _selectedCategory,
        'prompt_template': _promptTemplateController.text.trim(),
        'input_fields': inputFieldsJson,
        'thumbnail_url': _thumbnailUrlController.text.trim().isEmpty
            ? null
            : _thumbnailUrlController.text.trim(),
        'is_premium': _isPremium,
        'is_active': _isActive,
        'default_aspect_ratio': _selectedAspectRatio,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (widget.templateId != null) {
        await Supabase.instance.client
            .from('templates')
            .update(updates)
            .eq('id', widget.templateId!);
      } else {
        final maxOrderRes = await Supabase.instance.client
            .from('templates')
            .select('order')
            .order('order', ascending: false)
            .limit(1)
            .maybeSingle();

        final nextOrder = (maxOrderRes?['order'] as int? ?? 0) + 1;

        await Supabase.instance.client.from('templates').insert({
          ...updates,
          'order': nextOrder,
        });
      }

      if (mounted) {
        context.go('/templates');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving template: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _promptTemplateController.dispose();
    _inputFieldsController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/templates'),
        ),
        title: Text(
            widget.templateId != null ? 'Edit Template' : 'New Template'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Basic'),
            Tab(icon: Icon(Icons.tune), text: 'Config'),
            Tab(icon: Icon(Icons.image_outlined), text: 'Media'),
          ],
        ),
        actions: [
          // Status chips
          if (widget.templateId != null) ...[
            ChoiceChip(
              label: Text(_isActive ? 'Active' : 'Inactive'),
              selected: _isActive,
              selectedColor: AdminColors.success.withValues(alpha: 0.2),
              side: BorderSide(
                color: _isActive ? AdminColors.success : Colors.grey,
              ),
              onSelected: (v) => setState(() => _isActive = v),
            ),
            const Gap(8),
            ChoiceChip(
              label: const Text('Premium'),
              selected: _isPremium,
              selectedColor: AdminColors.statAmber.withValues(alpha: 0.2),
              side: BorderSide(
                color: _isPremium ? AdminColors.statAmber : Colors.grey,
              ),
              onSelected: (v) => setState(() => _isPremium = v),
            ),
            const Gap(16),
          ],
          FilledButton.icon(
            onPressed: _isLoading ? null : _save,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child:
                        CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.save, size: 18),
            label: const Text('Save'),
          ),
          const Gap(16),
        ],
      ),
      body: _isLoading && _isInit
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicTab(theme, isDark),
                  _buildConfigTab(theme, isDark),
                  _buildMediaTab(theme, isDark),
                ],
              ),
            ),
    );
  }

  // ── Tab 1: Basic Info ──────────────────────────────────────────────────

  Widget _buildBasicTab(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Template Details',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Gap(16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Fantasy Portrait',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const Gap(16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: AppConstants.templateCategories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const Gap(16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe what this template creates...',
                ),
                maxLines: 3,
              ),
              const Gap(24),

              // Settings row
              Text('Settings',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedAspectRatio,
                      decoration: const InputDecoration(
                          labelText: 'Default Aspect Ratio'),
                      items: _aspectRatios.map((r) {
                        return DropdownMenuItem(value: r, child: Text(r));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedAspectRatio = v);
                        }
                      },
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Premium'),
                      subtitle: Text(
                        _isPremium ? 'Pro users only' : 'Free for all',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AdminColors.textMuted
                              : Colors.grey,
                        ),
                      ),
                      value: _isPremium,
                      onChanged: (v) => setState(() => _isPremium = v),
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Active'),
                      subtitle: Text(
                        _isActive ? 'Visible to users' : 'Hidden',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AdminColors.textMuted
                              : Colors.grey,
                        ),
                      ),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab 2: Configuration ───────────────────────────────────────────────

  Widget _buildConfigTab(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Prompt Template',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Gap(8),
              Text(
                'Use {{field_id}} to insert values from input fields',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AdminColors.textMuted : Colors.grey.shade600,
                ),
              ),
              const Gap(12),
              TextFormField(
                controller: _promptTemplateController,
                decoration: const InputDecoration(
                  hintText:
                      'A {{style}} portrait of a person, high quality, 4k...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const Gap(32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Input Fields',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () {
                      // Format JSON
                      try {
                        final parsed =
                            jsonDecode(_inputFieldsController.text);
                        _inputFieldsController.text =
                            const JsonEncoder.withIndent('  ')
                                .convert(parsed);
                      } catch (_) {
                        // If invalid, don't crash
                      }
                    },
                    icon: const Icon(Icons.code, size: 16),
                    label: const Text('Format JSON'),
                  ),
                ],
              ),
              const Gap(8),
              Text(
                'Define fields as a JSON array. Each object must have "id", "label", "type".',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AdminColors.textMuted : Colors.grey.shade600,
                ),
              ),
              const Gap(8),
              TextFormField(
                controller: _inputFieldsController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: isDark
                      ? AdminColors.background
                      : Colors.grey.shade50,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color:
                      isDark ? AdminColors.textPrimary : Colors.grey.shade900,
                ),
                maxLines: 15,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  try {
                    jsonDecode(v);
                    return null;
                  } catch (e) {
                    return 'Invalid JSON';
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab 3: Media ───────────────────────────────────────────────────────

  Widget _buildMediaTab(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thumbnail',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Gap(16),
              TextFormField(
                controller: _thumbnailUrlController,
                decoration: const InputDecoration(
                  labelText: 'Thumbnail URL',
                  hintText: 'https://example.com/image.png',
                  prefixIcon: Icon(Icons.link),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const Gap(24),
              if (_thumbnailUrlController.text.isNotEmpty) ...[
                Text('Preview',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w500)),
                const Gap(12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    width: double.infinity,
                    color: isDark
                        ? AdminColors.surfaceContainer
                        : Colors.grey.shade100,
                    child: Image.network(
                      _thumbnailUrlController.text,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 48),
                            Gap(8),
                            Text('Invalid or unreachable URL'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ] else
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AdminColors.surfaceContainer
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AdminColors.borderSubtle
                          : Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48,
                        color: isDark
                            ? AdminColors.textHint
                            : Colors.grey.shade400,
                      ),
                      const Gap(8),
                      Text(
                        'Add a thumbnail URL above',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AdminColors.textMuted
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
