import 'package:flutter/material.dart';

enum UserFilter {
  all('All'),
  premium('Premium'),
  free('Free'),
  banned('Banned');

  const UserFilter(this.label);

  final String label;
}

class UserSearchBar extends StatelessWidget {
  final String searchQuery;
  final UserFilter activeFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<UserFilter> onFilterChanged;

  const UserSearchBar({
    super.key,
    required this.searchQuery,
    required this.activeFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by email or name...',
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
              children: UserFilter.values.map((f) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f.label),
                    selected: activeFilter == f,
                    onSelected: (_) => onFilterChanged(f),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
