import 'package:flutter/material.dart';
import '../../core/constants/ai_models.dart';

/// Grid selector for aspect ratios with expand functionality
class AspectRatioSelector extends StatefulWidget {
  final String selectedRatio;
  final String selectedModelId;
  final ValueChanged<String> onChanged;

  const AspectRatioSelector({
    super.key,
    required this.selectedRatio,
    required this.selectedModelId,
    required this.onChanged,
  });

  @override
  State<AspectRatioSelector> createState() => _AspectRatioSelectorState();
}

class _AspectRatioSelectorState extends State<AspectRatioSelector> {
  bool _expanded = false;

  // Primary ratios shown by default
  static const _primaryRatios = ['1:1', '4:3', '3:4', '16:9', '9:16'];

  List<String> get _availableRatios {
    final model = AiModels.getById(widget.selectedModelId);
    return model?.supportedAspectRatios ?? AiModels.standardAspectRatios;
  }

  List<String> get _displayedRatios {
    final available = _availableRatios;
    if (_expanded) return available;
    return _primaryRatios.where((r) => available.contains(r)).toList();
  }

  bool get _hasMoreOptions {
    return _availableRatios.length > _primaryRatios.length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aspect Ratio', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ..._displayedRatios.map((ratio) {
              final isSelected = widget.selectedRatio == ratio;
              return ChoiceChip(
                label: Text(ratio),
                selected: isSelected,
                onSelected: (_) => widget.onChanged(ratio),
              );
            }),
            if (_hasMoreOptions)
              ActionChip(
                label: Text(_expanded ? 'Less' : 'More'),
                avatar: Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
                onPressed: () => setState(() => _expanded = !_expanded),
              ),
          ],
        ),
      ],
    );
  }
}
