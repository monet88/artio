import 'package:artio_admin/core/constants/app_constants.dart';
import 'package:artio_admin/core/theme/admin_colors.dart';
import 'package:flutter/material.dart';

/// Search bar + category/filter chips shown above the templates list.
class TemplateSearchBar extends StatelessWidget {
  final String searchQuery;
  final String? selectedCategory;
  final bool showPremiumOnly;
  final bool showInactiveOnly;
  final bool isDark;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<bool> onPremiumChanged;
  final ValueChanged<bool> onInactiveChanged;
  final VoidCallback onClearFilters;

  const TemplateSearchBar({
    super.key,
    required this.searchQuery,
    required this.selectedCategory,
    required this.showPremiumOnly,
    required this.showInactiveOnly,
    required this.isDark,
    required this.onSearchChanged,
    required this.onCategoryChanged,
    required this.onPremiumChanged,
    required this.onInactiveChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search templates...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => onSearchChanged(''),
                    )
                  : null,
            ),
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: selectedCategory == null &&
                      !showPremiumOnly &&
                      !showInactiveOnly,
                  onSelected: (_) => onClearFilters(),
                ),
                const SizedBox(width: 8),
                ...AppConstants.templateCategories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (selected) =>
                          onCategoryChanged(selected ? cat : null),
                    ),
                  ),
                ),
                FilterChip(
                  label: const Text('Premium'),
                  avatar: Icon(
                    Icons.workspace_premium,
                    size: 16,
                    color: showPremiumOnly
                        ? AdminColors.statAmber
                        : (isDark ? AdminColors.textMuted : Colors.grey),
                  ),
                  selected: showPremiumOnly,
                  onSelected: onPremiumChanged,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Inactive'),
                  selected: showInactiveOnly,
                  onSelected: onInactiveChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
