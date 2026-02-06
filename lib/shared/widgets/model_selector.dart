import 'package:flutter/material.dart';
import 'package:artio/core/design_system/app_spacing.dart';
import '../../core/constants/ai_models.dart';

/// Dropdown selector for AI models with premium badges and credit costs
class ModelSelector extends StatefulWidget {
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

  @override
  State<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<ModelSelector> {
  List<AiModelConfig> get _availableModels {
    var models = AiModels.all;
    if (widget.filterByType != null) {
      models = models.where((m) => m.type == widget.filterByType).toList();
    }
    return models;
  }

  String? get _effectiveValue {
    if (_availableModels.any((m) => m.id == widget.selectedModelId)) {
      return widget.selectedModelId;
    }
    return _availableModels.isNotEmpty ? _availableModels.first.id : null;
  }

  @override
  void didUpdateWidget(covariant ModelSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync upstream state when selected model not in filtered list
    if (!_availableModels.any((m) => m.id == widget.selectedModelId) &&
        _availableModels.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged(_availableModels.first.id);
      });
    }
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
        SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          value: _effectiveValue,
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
                  SizedBox(width: AppSpacing.sm),
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
            final isDisabled = model.isPremium && !widget.isPremium;

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
                    SizedBox(width: AppSpacing.sm),
                    const Text('\u{1F48E}', style: TextStyle(fontSize: 12)), // Diamond
                    const SizedBox(width: 2),
                    Text(
                      '${model.creditCost}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (model.isNew) ...[
                      SizedBox(width: AppSpacing.sm),
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
                      SizedBox(width: AppSpacing.sm),
                      const Text('\u{1F451}', style: TextStyle(fontSize: 12)), // Crown
                    ],
                    if (widget.selectedModelId == model.id) ...[
                      SizedBox(width: AppSpacing.sm),
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
              if (model != null && (!model.isPremium || widget.isPremium)) {
                widget.onChanged(value);
              }
            }
          },
        ),
      ],
    );
  }
}
