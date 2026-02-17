import 'package:artio/shared/widgets/model_selector.dart' as shared;
import 'package:flutter/material.dart';

class ModelSelector extends StatelessWidget {
  const ModelSelector({
    required this.selectedModelId, required this.onChanged, super.key,
    this.isPremium = false,
  });

  final String selectedModelId;
  final ValueChanged<String> onChanged;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return shared.ModelSelector(
      selectedModelId: selectedModelId,
      isPremium: isPremium,
      onChanged: onChanged,
      filterByType: 'text-to-image',
    );
  }
}
