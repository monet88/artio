import 'package:artio/core/design_system/app_spacing.dart';
import 'package:flutter/widgets.dart';

/// A widget that wraps bottom sheet content to avoid being obscured by
/// the Android gesture navigation bar.
///
/// Applies [SafeArea] (bottom only) and adds `viewPadding.bottom` to the
/// base padding so content is never hidden behind system UI.
class BottomSheetBody extends StatelessWidget {
  const BottomSheetBody({
    required this.child,
    this.padding,
    super.key,
  });

  final Widget child;

  /// Padding to apply around [child].
  ///
  /// Defaults to `EdgeInsets.all(AppSpacing.lg)` when `null`.
  /// The bottom value is further extended by `MediaQuery.viewPadding.bottom`
  /// at runtime to clear the system navigation bar.
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;
    final base = padding ?? const EdgeInsets.all(AppSpacing.lg);
    return SafeArea(
      top: false,
      child: Padding(
        padding: base.copyWith(bottom: base.bottom + bottomInset),
        child: child,
      ),
    );
  }
}
