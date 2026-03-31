import 'package:artio_admin/core/constants/app_constants.dart';
import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BasicInfoTab extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final String? selectedCategory;
  final String selectedAspectRatio;
  final bool isPremium;
  final bool isActive;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String?> onAspectRatioChanged;
  final ValueChanged<bool> onPremiumChanged;
  final ValueChanged<bool> onActiveChanged;
  final bool isDark;

  static const _aspectRatios = ['1:1', '16:9', '9:16', '4:3', '3:4'];

  const BasicInfoTab({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.selectedAspectRatio,
    required this.isPremium,
    required this.isActive,
    required this.onCategoryChanged,
    required this.onAspectRatioChanged,
    required this.onPremiumChanged,
    required this.onActiveChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Template Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Fantasy Portrait',
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const Gap(16),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: AppConstants.templateCategories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: onCategoryChanged,
                validator: (v) => v == null ? 'Required' : null,
              ),
              const Gap(16),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe what this template creates...',
                ),
                maxLines: 3,
              ),
              const Gap(24),
              Text(
                'Settings',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedAspectRatio,
                      decoration: const InputDecoration(
                        labelText: 'Default Aspect Ratio',
                      ),
                      items: _aspectRatios.map((r) {
                        return DropdownMenuItem(value: r, child: Text(r));
                      }).toList(),
                      onChanged: onAspectRatioChanged,
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Premium'),
                      subtitle: Text(
                        isPremium ? 'Pro users only' : 'Free for all',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AdminColors.textMuted : Colors.grey,
                        ),
                      ),
                      value: isPremium,
                      onChanged: onPremiumChanged,
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      title: const Text('Active'),
                      subtitle: Text(
                        isActive ? 'Visible to users' : 'Hidden',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AdminColors.textMuted : Colors.grey,
                        ),
                      ),
                      value: isActive,
                      onChanged: onActiveChanged,
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
}
