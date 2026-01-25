import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/generation_job_model.dart';
import '../model/template_model.dart';
import '../ui/providers/template_provider.dart';
import '../ui/view_model/generation_view_model.dart';
import '../ui/widgets/generation_progress.dart';
import '../ui/widgets/input_field_builder.dart';

class TemplateDetailScreen extends ConsumerStatefulWidget {
  final String templateId;

  const TemplateDetailScreen({super.key, required this.templateId});

  @override
  ConsumerState<TemplateDetailScreen> createState() => _TemplateDetailScreenState();
}

class _TemplateDetailScreenState extends ConsumerState<TemplateDetailScreen> {
  final Map<String, String> _inputValues = {};
  String _selectedAspectRatio = '1:1';

  String _buildPrompt(TemplateModel template) {
    var prompt = template.promptTemplate;
    for (final entry in _inputValues.entries) {
      prompt = prompt.replaceAll('{${entry.key}}', entry.value);
    }
    return prompt;
  }

  void _handleGenerate(TemplateModel template) {
    final prompt = _buildPrompt(template);
    ref.read(generationViewModelProvider.notifier).generate(
          templateId: template.id,
          prompt: prompt,
          aspectRatio: _selectedAspectRatio,
          imageCount: 1,
        );
  }

  @override
  Widget build(BuildContext context) {
    final templateAsync = ref.watch(templateByIdProvider(widget.templateId));
    final jobAsync = ref.watch(generationViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Generate')),
      body: templateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (template) {
          if (template == null) {
            return const Center(child: Text('Template not found'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (template.thumbnailUrl.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      template.thumbnailUrl,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(height: 200, child: Icon(Icons.broken_image, size: 50)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Text(template.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(template.description),
                const SizedBox(height: 24),

                for (final field in template.inputFields) ...[
                  InputFieldBuilder(
                    field: field,
                    onChanged: (value) => _inputValues[field.name] = value,
                  ),
                  const SizedBox(height: 16),
                ],

                const Text('Aspect Ratio'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['1:1', '4:3', '3:4', '16:9', '9:16'].map((ratio) {
                    return ChoiceChip(
                      label: Text(ratio),
                      selected: _selectedAspectRatio == ratio,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedAspectRatio = ratio);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                _buildGenerationState(jobAsync, template),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenerationState(AsyncValue<GenerationJobModel?> jobAsync, TemplateModel template) {
    return jobAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Column(
        children: [
          Text(
            error.toString(),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () {
              ref.read(generationViewModelProvider.notifier).reset();
              _handleGenerate(template);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
      data: (job) {
        if (job == null) {
          return FilledButton(
            onPressed: () => _handleGenerate(template),
            child: const Text('Generate'),
          );
        }

        return Column(
          children: [
            GenerationProgress(job: job),
            const SizedBox(height: 16),
            if (job.status == JobStatus.completed)
              FilledButton(
                onPressed: () => ref.read(generationViewModelProvider.notifier).reset(),
                child: const Text('Generate Another'),
              ),
          ],
        );
      },
    );
  }
}
