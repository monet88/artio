import 'dart:convert';

import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class PromptSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const PromptSection({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prompt Template',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(8),
        Text(
          'Use {{field_id}} to insert values from input fields',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isDark ? AdminColors.textMuted : Colors.grey.shade600,
          ),
        ),
        const Gap(12),
        TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'A {{style}} portrait of a person, high quality, 4k...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          validator: (v) => v?.isEmpty == true ? 'Required' : null,
        ),
      ],
    );
  }
}

class InputFieldsSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const InputFieldsSection({
    super.key,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Input Fields',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                try {
                  final parsed = jsonDecode(controller.text);
                  controller.text =
                      const JsonEncoder.withIndent('  ').convert(parsed);
                } catch (_) {}
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
          controller: controller,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            filled: true,
            fillColor:
                isDark ? AdminColors.background : Colors.grey.shade50,
            contentPadding: const EdgeInsets.all(16),
          ),
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: isDark ? AdminColors.textPrimary : Colors.grey.shade900,
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
    );
  }
}

/// Wraps PromptSection + InputFieldsSection in a scrollable container.
class ConfigTab extends StatelessWidget {
  final TextEditingController promptController;
  final TextEditingController inputFieldsController;
  final bool isDark;

  const ConfigTab({
    super.key,
    required this.promptController,
    required this.inputFieldsController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PromptSection(controller: promptController, isDark: isDark),
              const Gap(32),
              InputFieldsSection(
                controller: inputFieldsController,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
