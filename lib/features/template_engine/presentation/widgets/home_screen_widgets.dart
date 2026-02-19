import 'package:artio/core/design_system/app_typography.dart';
import 'package:artio/features/template_engine/presentation/providers/template_provider.dart';
import 'package:artio/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Template count badge shown in the home screen header.
class TemplateCountBadge extends ConsumerWidget {
  const TemplateCountBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);

    return templatesAsync.when(
      data: (templates) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryCta.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.dashboard_rounded,
              size: 14,
              color: AppColors.primaryCta,
            ),
            const SizedBox(width: 4),
            Text(
              '${templates.length}',
              style: AppTypography.captionEmphasis.copyWith(
                color: AppColors.primaryCta,
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Horizontal category filter chips for the home screen.
class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key});

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  int _selectedIndex = 0;

  static const _categories = [
    'All',
    'Portrait',
    'Landscape',
    'Abstract',
    'Anime',
    'Realistic',
    'Fantasy',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryCta
                    : isDark
                        ? AppColors.darkSurface2
                        : AppColors.lightSurface2,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : isDark
                        ? Border.all(color: AppColors.white10, width: 0.5)
                        : null,
              ),
              child: Text(
                _categories[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : isDark
                          ? AppColors.textSecondary
                          : AppColors.textSecondaryLight,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
