import 'package:flutter/material.dart';
import 'package:artio/shared/widgets/model_selector.dart' as shared;

class ModelSelector extends StatelessWidget {
  const ModelSelector({
    super.key,
    required this.selectedModelId,
    required this.onChanged,
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
