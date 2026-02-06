import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/sentry_config.dart';
import '../../../../core/design_system/app_spacing.dart';
import '../../../../core/utils/app_exception_mapper.dart';
import '../../../../shared/widgets/loading_state_widget.dart';
import '../providers/template_provider.dart';
import 'template_card.dart';

class TemplateGrid extends ConsumerWidget {
  const TemplateGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(templatesProvider);

    return templatesAsync.when(
      data: (templates) {
        if (templates.isEmpty) {
          return const Center(child: Text('No templates available'));
        }
        return GridView.builder(
          padding: AppSpacing.screenPadding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            return TemplateCard(template: templates[index]);
          },
        );
      },
      loading: () => const LoadingStateWidget(),
      error: (error, stack) => _ErrorMessage(error: error, stackTrace: stack),
    );
  }
}

class _ErrorMessage extends ConsumerStatefulWidget {
  const _ErrorMessage({required this.error, required this.stackTrace});

  final Object error;
  final StackTrace? stackTrace;

  @override
  ConsumerState<_ErrorMessage> createState() => _ErrorMessageState();
}

class _ErrorMessageState extends ConsumerState<_ErrorMessage> {
  bool _didCapture = false;
  @override
  void initState() {
    super.initState();
    _captureOnce();
  }

  @override
  void _captureOnce() {
    if (_didCapture) {
      return;
    }
    _didCapture = true;
    SentryConfig.captureException(widget.error, stackTrace: widget.stackTrace);
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(AppExceptionMapper.toUserMessage(widget.error)));
  }
}
