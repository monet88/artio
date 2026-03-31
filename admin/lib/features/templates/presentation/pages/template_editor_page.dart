import 'dart:convert';

import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:artio_admin/features/templates/presentation/widgets/basic_info_tab.dart';
import 'package:artio_admin/features/templates/presentation/widgets/prompt_section.dart'
    show ConfigTab;
import 'package:artio_admin/features/templates/presentation/widgets/thumbnail_section.dart';
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

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _promptTemplateController = TextEditingController();
  final _inputFieldsController = TextEditingController();
  final _thumbnailUrlController = TextEditingController();

  String? _selectedCategory;
  String _selectedAspectRatio = '1:1';
  bool _isPremium = false;
  bool _isActive = true;

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
          'id': 'style',
          'label': 'Style',
          'type': 'select',
          'options': ['Realistic', 'Anime', 'Oil Painting'],
          'defaultValue': 'Realistic',
        },
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

      final ratio = data['default_aspect_ratio'] as String?;
      setState(() {
        _selectedCategory = data['category'] as String?;
        if (ratio != null &&
            ['1:1', '16:9', '9:16', '4:3', '3:4'].contains(ratio)) {
          _selectedAspectRatio = ratio;
        }
        _isPremium = data['is_premium'] ?? false;
        _isActive = data['is_active'] ?? true;
      });

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
    if (!_formKey.currentState!.validate()) return;

    Object? inputFieldsJson;
    try {
      inputFieldsJson = jsonDecode(_inputFieldsController.text);
      if (inputFieldsJson is! List) {
        throw const FormatException('Input fields must be a JSON list');
      }
    } catch (e) {
      _tabController.animateTo(1);
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
            .select('sort_order')
            .order('sort_order', ascending: false)
            .limit(1)
            .maybeSingle();
        final nextOrder = (maxOrderRes?['sort_order'] as int? ?? 0) + 1;
        await Supabase.instance.client.from('templates').insert({
          ...updates,
          'sort_order': nextOrder,
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
          widget.templateId != null ? 'Edit Template' : 'New Template',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: 'Basic'),
            Tab(icon: Icon(Icons.tune), text: 'Config'),
            Tab(icon: Icon(Icons.image_outlined), text: 'Media'),
          ],
        ),
        actions: [
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
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
                  BasicInfoTab(
                    nameController: _nameController,
                    descriptionController: _descriptionController,
                    selectedCategory: _selectedCategory,
                    selectedAspectRatio: _selectedAspectRatio,
                    isPremium: _isPremium,
                    isActive: _isActive,
                    onCategoryChanged: (v) =>
                        setState(() => _selectedCategory = v),
                    onAspectRatioChanged: (v) {
                      if (v != null) setState(() => _selectedAspectRatio = v);
                    },
                    onPremiumChanged: (v) => setState(() => _isPremium = v),
                    onActiveChanged: (v) => setState(() => _isActive = v),
                    isDark: isDark,
                  ),
                  ConfigTab(
                    promptController: _promptTemplateController,
                    inputFieldsController: _inputFieldsController,
                    isDark: isDark,
                  ),
                  ThumbnailSection(
                    thumbnailUrlController: _thumbnailUrlController,
                    templateId: widget.templateId,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
    );
  }
}
