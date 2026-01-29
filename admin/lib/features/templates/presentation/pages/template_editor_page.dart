import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:artio/core/constants/app_constants.dart';

class TemplateEditorPage extends ConsumerStatefulWidget {
  final String? templateId;

  const TemplateEditorPage({super.key, this.templateId});

  @override
  ConsumerState<TemplateEditorPage> createState() => _TemplateEditorPageState();
}

class _TemplateEditorPageState extends ConsumerState<TemplateEditorPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInit = true;

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

  static const _aspectRatios = [
    '1:1',
    '16:9',
    '9:16',
    '4:3',
    '3:4',
  ];

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
      // Default JSON for new template
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
      
      // Set dropdowns
      final category = data['category'] as String?;
      if (category != null && AppConstants.templateCategories.contains(category)) {
        _selectedCategory = category;
      } else {
        _selectedCategory = category; // Allow custom values if they exist in DB
      }
      
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate JSON
    dynamic inputFieldsJson;
    try {
      inputFieldsJson = jsonDecode(_inputFieldsController.text);
      if (inputFieldsJson is! List) {
        throw const FormatException('Input fields must be a JSON list');
      }
    } catch (e) {
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
        // Get max order to append at end
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
        context.pop();
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _promptTemplateController.dispose();
    _inputFieldsController.dispose();
    _thumbnailUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.templateId != null ? 'Edit Template' : 'New Template'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _save,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Basic Info'),
                        const Gap(16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(labelText: 'Name'),
                                validator: (v) => v?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                            const Gap(16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedCategory,
                                decoration: const InputDecoration(labelText: 'Category'),
                                items: AppConstants.templateCategories.map((c) {
                                  return DropdownMenuItem(value: c, child: Text(c));
                                }).toList(),
                                onChanged: (v) => setState(() => _selectedCategory = v),
                                validator: (v) => v == null ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(labelText: 'Description'),
                          maxLines: 2,
                        ),
                        const Gap(24),

                        _buildSectionHeader('Configuration'),
                        const Gap(16),
                        TextFormField(
                          controller: _promptTemplateController,
                          decoration: const InputDecoration(
                            labelText: 'Prompt Template',
                            helperText: 'Use {{field_id}} to insert input values',
                          ),
                          maxLines: 3,
                          validator: (v) => v?.isEmpty == true ? 'Required' : null,
                        ),
                        const Gap(16),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedAspectRatio,
                                decoration: const InputDecoration(
                                  labelText: 'Default Aspect Ratio',
                                ),
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
                                title: const Text('Premium Template'),
                                value: _isPremium,
                                onChanged: (v) => setState(() => _isPremium = v),
                              ),
                            ),
                            Expanded(
                              child: SwitchListTile(
                                title: const Text('Active'),
                                value: _isActive,
                                onChanged: (v) => setState(() => _isActive = v),
                              ),
                            ),
                          ],
                        ),
                        const Gap(24),

                        _buildSectionHeader('Input Fields (JSON)'),
                        const Gap(8),
                        const Text(
                          'Define fields as a JSON array. Each object must have "id", "label", "type".',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const Gap(8),
                        TextFormField(
                          controller: _inputFieldsController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
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
                        const Gap(24),

                        _buildSectionHeader('Media'),
                        const Gap(16),
                        TextFormField(
                          controller: _thumbnailUrlController,
                          decoration: const InputDecoration(labelText: 'Thumbnail URL'),
                          onChanged: (_) => setState(() {}),
                        ),
                        if (_thumbnailUrlController.text.isNotEmpty) ...[
                          const Gap(16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _thumbnailUrlController.text,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox(
                                height: 50,
                                child: Center(child: Text('Invalid URL')),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const Divider(),
      ],
    );
  }
}
