import 'package:flutter/material.dart';
import '../../core/constants/ai_models.dart';

/// Dropdown selector for AI models with premium badges and credit costs
class ModelSelector extends StatelessWidget {
  final String selectedModelId;
  final bool isPremium;
  final ValueChanged<String> onChanged;
  final String? filterByType; // text-to-image, image-to-image, image-editing

  const ModelSelector({
    super.key,
    required this.selectedModelId,
    required this.isPremium,
    required this.onChanged,
    this.filterByType,
  });

  List<AiModelConfig> get _availableModels {
    var models = AiModels.all;
    if (filterByType != null) {
      models = models.where((m) => m.type == filterByType).toList();
    }
    return models;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Model', style: theme.textTheme.titleSmall),
            const SizedBox(width: 4),
            Tooltip(
              message: 'Choose AI model for generation',
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedModelId,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          selectedItemBuilder: (context) {
            return _availableModels.map((model) {
              return Row(
                children: [
                  Expanded(child: Text(model.displayName)),
                  const SizedBox(width: 8),
                  const Text('\u{1F48E}', style: TextStyle(fontSize: 12)), // Diamond
                  const SizedBox(width: 2),
                  Text(
                    '${model.creditCost}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              );
            }).toList();
          },
          items: _availableModels.map((model) {
            final isDisabled = model.isPremium && !isPremium;

            return DropdownMenuItem(
              value: model.id,
              enabled: !isDisabled,
              child: Opacity(
                opacity: isDisabled ? 0.5 : 1.0,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        model.displayName,
                        style: isDisabled
                            ? TextStyle(color: theme.colorScheme.outline)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('\u{1F48E}', style: TextStyle(fontSize: 12)), // Diamond
                    const SizedBox(width: 2),
                    Text(
                      '${model.creditCost}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (model.isNew) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'NEW',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (model.isPremium) ...[
                      const SizedBox(width: 8),
                      const Text('\u{1F451}', style: TextStyle(fontSize: 12)), // Crown
                    ],
                    if (selectedModelId == model.id) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              final model = AiModels.getById(value);
              if (model != null && (!model.isPremium || isPremium)) {
                onChanged(value);
              }
            }
          },
        ),
      ],
    );
  }
}
