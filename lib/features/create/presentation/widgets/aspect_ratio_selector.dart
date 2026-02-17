import 'package:artio/core/constants/ai_models.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import 'package:flutter/material.dart';

class AspectRatioSelector extends StatelessWidget {
  const AspectRatioSelector({
    required this.selectedRatio, required this.selectedModelId, required this.onChanged, super.key,
  });

  final String selectedRatio;
  final String selectedModelId;
  final ValueChanged<String> onChanged;

  List<String> get _ratios {
    final model = AiModels.getById(selectedModelId);
    return model?.supportedAspectRatios ?? AiModels.standardAspectRatios;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aspect Ratio', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final ratio in _ratios)
              ChoiceChip(
                label: Text(ratio),
                selected: ratio == selectedRatio,
                onSelected: (_) => onChanged(ratio),
              ),
          ],
        ),
      ],
    );
  }
}
