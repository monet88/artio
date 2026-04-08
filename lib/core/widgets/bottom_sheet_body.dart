import 'package:artio/core/design_system/app_spacing.dart';
import 'package:flutter/widgets.dart';

/// A widget that wraps bottom sheet content to avoid being obscured by
/// the Android gesture navigation bar or iOS home indicator.
///
/// Applies `SafeArea(top: false)` which automatically insets content by
/// `MediaQuery.padding.bottom`, keeping interactive elements above system UI.
class BottomSheetBody extends StatelessWidget {
  const BottomSheetBody({required this.child, this.padding, super.key});

  final Widget child;

  /// Padding to apply around [child].
  ///
  /// Defaults to `EdgeInsets.all(AppSpacing.lg)` when `null`.
  /// Bottom system inset is handled by the inner `SafeArea` — do not add
  /// `MediaQuery.viewPadding.bottom` here or the inset will be double-counted.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final base = padding ?? const EdgeInsets.all(AppSpacing.lg);
    return SafeArea(
      top: false,
      child: Padding(padding: base, child: child),
    );
  }
}
