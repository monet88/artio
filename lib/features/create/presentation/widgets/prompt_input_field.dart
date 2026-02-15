import 'package:flutter/material.dart';
import 'package:artio/core/design_system/app_spacing.dart';

class PromptInputField extends StatefulWidget {
  const PromptInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final String hintText;
  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<PromptInputField> createState() => _PromptInputFieldState();
}

class _PromptInputFieldState extends State<PromptInputField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant PromptInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller when external value changes (e.g., after reset).
    // Only update if the value actually differs to avoid cursor jumps.
    if (widget.value != oldWidget.value &&
        widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleSmall),
        SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: _controller,
          onChanged: widget.onChanged,
          minLines: 3,
          maxLines: 6,
          maxLength: 1000,
          decoration: InputDecoration(
            hintText: widget.hintText,
            errorText: widget.errorText,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
