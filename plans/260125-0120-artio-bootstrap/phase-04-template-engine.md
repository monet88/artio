---
title: "Phase 4: Template Engine"
status: completed
effort: 8h
---

# Phase 4: Generation Features (KIE Integration)

## Context Links

- [KIE API Docs](https://docs.kie.ai/index.md)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Supabase Background Tasks](https://supabase.com/docs/guides/functions/background-tasks)

## Overview

Build generation features using **KIE API** as the unified gateway.
1. **Template Engine** (Home tab) - Image-to-image with preset templates (Gemini/Nano)
2. **Text-to-Image** (Create tab) - Custom prompt generation (Imagen 4)

## AI Models (via KIE)

| Tier | Display Name | KIE Model ID | Use Case |
|------|--------------|--------------|----------|
| **Free** | Nano Edit | `google/nano-banana-edit` | Fast image editing/templates |
| **Paid** | Nano Pro | `google/pro-image-to-image` | High quality image-to-image |
| **Free** | Imagen Fast | `google/imagen4-fast` | Fast text-to-image generation |
| **Paid** | Imagen 4 | `google/imagen4` | Standard text-to-image quality |
| **Pro** | Imagen Ultra | `google/imagen4-ultra` | Highest quality generation |

## Key Insights

- **Single API Key**: Use `KIE_API_KEY` for all models.
- **Unified Payload**: All requests go to `https://api.kie.ai/api/v1/jobs/createTask`.
- **Async Workflow**: KIE returns a `taskId`. We must poll `Get Task Details` or use `callBackUrl`.
- **Edge Function**:
  - Handles credit check.
  - Calls KIE API.
  - Stores `taskId` in `generation_jobs`.
  - Polling/Callback updates job status in DB.

## Requirements

### Functional
- **Template Engine**: Fetch templates, map inputs to prompt, call KIE Image-to-Image models.
- **Text-to-Image**: UI for prompts, aspect ratios, style picker.
- **Model Selection**: Logic to select `fast`, `standard`, or `ultra` based on user tier.
- **Background Processing**:
  - Edge Function initiates task.
  - Webhook (Callback) or Polling (Edge/Cron) to update status.
- **Real-time**: Supabase Realtime updates UI when job completes.

### Credit Costs (Estimated)

| Model | Credits |
|-------|---------|
| Nano Edit | 1 |
| Nano Pro | 4 |
| Imagen Fast | 1 |
| Imagen 4 | 2 |
| Imagen Ultra | 4 |


### Non-Functional
- Generation queue for rate limiting
- Retry failed generations
- Cache templates locally
- Handle offline gracefully

## Architecture

### Template Structure
```
Template {
  id: UUID
  name: String
  description: String
  thumbnail_url: String
  category: String  // "3D Render", "Photo Editing", etc.
  prompt_template: String  // "A {style} 3D render of {subject}..."
  input_fields: JSON  // [{name: "style", type: "select", options: [...]}]
  default_aspect_ratio: String
  is_premium: Boolean
  order: Int
}
```

### Generation Flow
```
1. User selects template → TemplateDetailPage
2. User fills input fields → prompt assembled
3. Click Generate → POST to Edge Function
4. Edge Function:
   a. Check credits/subscription
   b. Create job record (status: pending)
   c. Return job_id immediately
   d. waitUntil(generateImage())
5. Flutter subscribes to job via Realtime
6. Edge Function updates job (generating → complete/failed)
7. Flutter receives update → shows result
```

### Feature Structure
```
lib/features/template_engine/          # Image-to-image (Home tab)
├── domain/
│   └── generation_notifier.dart
├── data/
│   ├── models/
│   │   ├── template_model.dart
│   │   ├── template_model.freezed.dart
│   │   ├── template_model.g.dart
│   │   ├── input_field_model.dart
│   │   ├── input_field_model.freezed.dart
│   │   ├── input_field_model.g.dart
│   │   ├── generation_job_model.dart
│   │   ├── generation_job_model.freezed.dart
│   │   └── generation_job_model.g.dart
│   └── repositories/
│       ├── template_repository.dart
│       ├── template_repository.g.dart
│       ├── generation_repository.dart
│       └── generation_repository.g.dart
└── presentation/
    ├── providers/
    │   ├── template_provider.dart
    │   └── template_provider.g.dart
    ├── pages/
    │   ├── home_page.dart
    │   └── template_detail_page.dart
    └── widgets/
        ├── template_card.dart
        ├── template_grid.dart
        ├── input_field_builder.dart
        └── generation_progress.dart

lib/features/create/                    # Text-to-image (Create tab)
├── domain/
│   ├── entities/
│   │   └── generation_request.dart
│   └── repositories/
│       └── i_generation_repository.dart
├── data/
│   ├── data_sources/
│   │   └── generation_remote_data_source.dart
│   ├── dtos/
│   │   └── generation_job_dto.dart
│   └── repositories/
│       └── generation_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── generation_provider.dart
    ├── pages/
    │   └── create_page.dart
    └── widgets/
        ├── style_picker.dart
        ├── quality_selector.dart
        ├── aspect_ratio_selector.dart
        ├── recent_prompts.dart
        └── generation_progress.dart
```

## Related Code Files

### Create
- `lib/features/template_engine/data/models/template_model.dart`
- `lib/features/template_engine/data/models/generation_job_model.dart`
- `lib/features/template_engine/data/models/input_field_model.dart`
- `lib/features/template_engine/data/repositories/template_repository.dart`
- `lib/features/template_engine/data/repositories/generation_repository.dart`
- `lib/features/template_engine/domain/generation_notifier.dart`
- `lib/features/template_engine/presentation/providers/template_provider.dart`
- `lib/features/template_engine/presentation/pages/home_page.dart` (update)
- `lib/features/template_engine/presentation/pages/template_detail_page.dart` (update)
- `lib/features/template_engine/presentation/widgets/template_card.dart`
- `lib/features/template_engine/presentation/widgets/template_grid.dart`
- `lib/features/template_engine/presentation/widgets/input_field_builder.dart`
- `lib/features/template_engine/presentation/widgets/generation_progress.dart`
- `supabase/functions/generate-image/index.ts` (Edge Function)

### Supabase Tables
- `templates` - Template definitions
- `generation_jobs` - Job tracking

## Implementation Steps

### 1. Template Model
```dart
// lib/features/template_engine/data/models/template_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'input_field_model.dart';

part 'template_model.freezed.dart';
part 'template_model.g.dart';

@freezed
class TemplateModel with _$TemplateModel {
  const factory TemplateModel({
    required String id,
    required String name,
    required String description,
    required String thumbnailUrl,
    required String category,
    required String promptTemplate,
    required List<InputFieldModel> inputFields,
    @Default('1:1') String defaultAspectRatio,
    @Default(false) bool isPremium,
    @Default(0) int order,
  }) = _TemplateModel;

  factory TemplateModel.fromJson(Map<String, dynamic> json) =>
      _$TemplateModelFromJson(json);
}

@freezed
class InputFieldModel with _$InputFieldModel {
  const factory InputFieldModel({
    required String name,
    required String label,
    required String type, // text, select, slider, toggle
    String? placeholder,
    String? defaultValue,
    List<String>? options,
    double? min,
    double? max,
    @Default(false) bool required,
  }) = _InputFieldModel;

  factory InputFieldModel.fromJson(Map<String, dynamic> json) =>
      _$InputFieldModelFromJson(json);
}
```

### 2. Generation Job Model
```dart
// lib/features/template_engine/data/models/generation_job_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generation_job_model.freezed.dart';
part 'generation_job_model.g.dart';

enum JobStatus { pending, generating, completed, failed }

@freezed
class GenerationJobModel with _$GenerationJobModel {
  const factory GenerationJobModel({
    required String id,
    required String userId,
    required String templateId,
    required String prompt,
    required JobStatus status,
    String? aspectRatio,
    int? imageCount,
    List<String>? resultUrls,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
  }) = _GenerationJobModel;

  factory GenerationJobModel.fromJson(Map<String, dynamic> json) =>
      _$GenerationJobModelFromJson(json);
}
```

### 3. Template Repository
```dart
// lib/features/template_engine/data/repositories/template_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/template_model.dart';

part 'template_repository.g.dart';

@riverpod
TemplateRepository templateRepository(TemplateRepositoryRef ref) =>
    TemplateRepository();

class TemplateRepository {
  final _supabase = Supabase.instance.client;

  Future<List<TemplateModel>> fetchTemplates() async {
    final response = await _supabase
        .from('templates')
        .select()
        .eq('is_active', true)
        .order('order', ascending: true);

    return (response as List)
        .map((json) => TemplateModel.fromJson(json))
        .toList();
  }

  Future<TemplateModel?> fetchTemplate(String id) async {
    final response = await _supabase
        .from('templates')
        .select()
        .eq('id', id)
        .maybeSingle();

    return response != null ? TemplateModel.fromJson(response) : null;
  }

  Future<List<TemplateModel>> fetchByCategory(String category) async {
    final response = await _supabase
        .from('templates')
        .select()
        .eq('category', category)
        .eq('is_active', true)
        .order('order', ascending: true);

    return (response as List)
        .map((json) => TemplateModel.fromJson(json))
        .toList();
  }

  Stream<List<TemplateModel>> watchTemplates() {
    return _supabase
        .from('templates')
        .stream(primaryKey: ['id'])
        .order('order', ascending: true)
        .map((data) => data.map((e) => TemplateModel.fromJson(e)).toList());
  }
}
```

### 4. Generation Repository
```dart
// lib/features/template_engine/data/repositories/generation_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/generation_job_model.dart';

part 'generation_repository.g.dart';

@riverpod
GenerationRepository generationRepository(GenerationRepositoryRef ref) =>
    GenerationRepository();

class GenerationRepository {
  final _supabase = Supabase.instance.client;

  /// Start a generation job via Edge Function
  Future<String> startGeneration({
    required String templateId,
    required String prompt,
    String aspectRatio = '1:1',
    int imageCount = 1,
  }) async {
    final response = await _supabase.functions.invoke(
      'generate-image',
      body: {
        'template_id': templateId,
        'prompt': prompt,
        'aspect_ratio': aspectRatio,
        'image_count': imageCount,
      },
    );

    if (response.status != 200) {
      throw Exception(response.data['error'] ?? 'Generation failed');
    }

    return response.data['job_id'] as String;
  }

  /// Subscribe to job updates via Realtime
  Stream<GenerationJobModel> watchJob(String jobId) {
    return _supabase
        .from('generation_jobs')
        .stream(primaryKey: ['id'])
        .eq('id', jobId)
        .map((data) => GenerationJobModel.fromJson(data.first));
  }

  /// Fetch user's generation history
  Future<List<GenerationJobModel>> fetchUserJobs({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await _supabase
        .from('generation_jobs')
        .select()
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return (response as List)
        .map((json) => GenerationJobModel.fromJson(json))
        .toList();
  }

  Future<GenerationJobModel?> fetchJob(String jobId) async {
    final response = await _supabase
        .from('generation_jobs')
        .select()
        .eq('id', jobId)
        .maybeSingle();

    return response != null ? GenerationJobModel.fromJson(response) : null;
  }
}
```

### 5. Template Provider (for fetching single template)
```dart
// lib/features/template_engine/presentation/providers/template_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/template_model.dart';
import '../../data/repositories/template_repository.dart';

part 'template_provider.g.dart';

@riverpod
Future<TemplateModel?> templateById(Ref ref, String id) =>
    ref.read(templateRepositoryProvider).fetchTemplate(id);

@riverpod
Future<List<TemplateModel>> templates(Ref ref) =>
    ref.read(templateRepositoryProvider).fetchTemplates();

@riverpod
Future<List<TemplateModel>> templatesByCategory(Ref ref, String category) =>
    ref.read(templateRepositoryProvider).fetchByCategory(category);
```

### 6. Generation Notifier
```dart
// lib/features/template_engine/domain/generation_notifier.dart
import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/generation_job_model.dart';
import '../data/repositories/generation_repository.dart';

part 'generation_notifier.g.dart';

@riverpod
class GenerationNotifier extends _$GenerationNotifier {
  StreamSubscription? _jobSubscription;

  @override
  GenerationJobModel? build() {
    ref.onDispose(() => _jobSubscription?.cancel());
    return null;
  }

  bool get isLoading => _isLoading;
  bool _isLoading = false;

  String? get error => _error;
  String? _error;

  Future<void> generate({
    required String templateId,
    required String prompt,
    String aspectRatio = '1:1',
    int imageCount = 1,
  }) async {
    _isLoading = true;
    _error = null;
    state = null;

    try {
      final repo = ref.read(generationRepositoryProvider);
      final jobId = await repo.startGeneration(
        templateId: templateId,
        prompt: prompt,
        aspectRatio: aspectRatio,
        imageCount: imageCount,
      );

      // Subscribe to job updates
      _jobSubscription?.cancel();
      _jobSubscription = repo.watchJob(jobId).listen(
        (job) {
          state = job;
          if (job.status == JobStatus.completed ||
              job.status == JobStatus.failed) {
            _isLoading = false;
            _jobSubscription?.cancel();
          }
        },
        onError: (e, st) {
          _error = e.toString();
          _isLoading = false;
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
    }
  }

  void reset() {
    _jobSubscription?.cancel();
    _isLoading = false;
    _error = null;
    state = null;
  }
}
```

### 7. Edge Function (Deno/TypeScript)
```typescript
// supabase/functions/generate-image/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const KIE_API_KEY = Deno.env.get('KIE_API_KEY')!
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface GenerateRequest {
  template_id?: string
  prompt: string
  mode: 'text-to-image' | 'image-to-image'
  model_id?: string // e.g., 'google/imagen4-fast'
  image_urls?: string[]
  aspect_ratio?: string
}

serve(async (req) => {
  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)

  // Get user from auth header
  const authHeader = req.headers.get('Authorization')!
  const token = authHeader.replace('Bearer ', '')
  const { data: { user } } = await supabase.auth.getUser(token)

  if (!user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 })
  }

  const body: GenerateRequest = await req.json()
  const { prompt, mode, image_urls = [], aspect_ratio = '1:1' } = body

  // Determine model based on input or default
  let model = body.model_id
  if (!model) {
    model = mode === 'text-to-image' ? 'google/imagen4-fast' : 'google/nano-banana-edit'
  }

  // Check credits (Simplified logic)
  // ... (Credit check code here)

  // Create job record
  const { data: job, error: jobError } = await supabase
    .from('generation_jobs')
    .insert({
      user_id: user.id,
      prompt,
      status: 'pending',
      model_used: model
    })
    .select()
    .single()

  if (jobError) return new Response(JSON.stringify({ error: jobError.message }), { status: 500 })

  // Start background generation
  EdgeRuntime.waitUntil(callKieApi(supabase, job.id, model!, prompt, image_urls, aspect_ratio))

  return new Response(JSON.stringify({ job_id: job.id }), { status: 200 })
})

async function callKieApi(
  supabase: any,
  jobId: string,
  model: string,
  prompt: string,
  imageUrls: string[],
  aspectRatio: string
) {
  try {
    await supabase.from('generation_jobs').update({ status: 'generating' }).eq('id', jobId)

    const payload = {
      model: model,
      input: {
        prompt: prompt,
        image_urls: imageUrls.length > 0 ? imageUrls : undefined,
        aspect_ratio: aspectRatio,
        output_format: "png"
      }
    }

    const response = await fetch('https://api.kie.ai/api/v1/jobs/createTask', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${KIE_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    })

    const data = await response.json()
    
    if (data.code !== 200) {
      throw new Error(`KIE API Error: ${data.msg}`)
    }

    const taskId = data.data.taskId

    // Update job with provider task_id
    await supabase
      .from('generation_jobs')
      .update({ 
        provider_task_id: taskId,
        status: 'processing' // Separate status for provider processing
      })
      .eq('id', jobId)

    // Note: In a real implementation, you would trigger a separate polling function 
    // or rely on a webhook callback to update the final status.
    // For this example, we'll assume a separate process handles completion.

  } catch (error) {
    console.error('Generation error:', error)
    await supabase
      .from('generation_jobs')
      .update({ status: 'failed', error_message: error.message })
      .eq('id', jobId)
  }
}
```

### 8. Template Detail Page
```dart
// lib/features/template_engine/presentation/pages/template_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/generation_notifier.dart';
import '../../data/models/template_model.dart';
import '../providers/template_provider.dart';
import '../widgets/input_field_builder.dart';
import '../widgets/generation_progress.dart';

class TemplateDetailPage extends ConsumerStatefulWidget {
  final String templateId;

  const TemplateDetailPage({super.key, required this.templateId});

  @override
  ConsumerState<TemplateDetailPage> createState() => _TemplateDetailPageState();
}

class _TemplateDetailPageState extends ConsumerState<TemplateDetailPage> {
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
    ref.read(generationNotifierProvider.notifier).generate(
      templateId: template.id,
      prompt: prompt,
      aspectRatio: _selectedAspectRatio,
      imageCount: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final templateAsync = ref.watch(templateByIdProvider(widget.templateId));
    final job = ref.watch(generationNotifierProvider);
    final notifier = ref.watch(generationNotifierProvider.notifier);

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
                // Template header
                Text(template.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(template.description),
                const SizedBox(height: 24),

                // Input fields
                for (final field in template.inputFields) ...[
                  InputFieldBuilder(
                    field: field,
                    onChanged: (value) => _inputValues[field.name] = value,
                  ),
                  const SizedBox(height: 16),
                ],

                // Aspect ratio selector
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

                // Generation state
                if (notifier.error != null) ...[
                  Text(
                    notifier.error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () {
                      ref.read(generationNotifierProvider.notifier).reset();
                      _handleGenerate(template);
                    },
                    child: const Text('Retry'),
                  ),
                ] else if (notifier.isLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                ] else if (job != null) ...[
                  GenerationProgress(job: job),
                ] else ...[
                  FilledButton(
                    onPressed: () => _handleGenerate(template),
                    child: const Text('Generate'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
```

## Supabase Schema

```sql
-- Templates table
CREATE TABLE templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  thumbnail_url TEXT,
  category TEXT NOT NULL,
  prompt_template TEXT NOT NULL,
  input_fields JSONB NOT NULL DEFAULT '[]',
  default_aspect_ratio TEXT DEFAULT '1:1',
  is_premium BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  "order" INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Generation jobs table
CREATE TABLE generation_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  template_id UUID REFERENCES templates(id),
  prompt TEXT NOT NULL,
  aspect_ratio TEXT DEFAULT '1:1',
  image_count INTEGER DEFAULT 1,
  status TEXT NOT NULL DEFAULT 'pending',
  result_urls TEXT[],
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  completed_at TIMESTAMPTZ
);

-- RLS policies
ALTER TABLE templates ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Templates readable by all" ON templates FOR SELECT USING (true);

ALTER TABLE generation_jobs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own jobs" ON generation_jobs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own jobs" ON generation_jobs FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Realtime for jobs
ALTER PUBLICATION supabase_realtime ADD TABLE generation_jobs;

-- Credit deduction function
CREATE OR REPLACE FUNCTION deduct_credits(user_id UUID, amount INTEGER)
RETURNS void AS $$
BEGIN
  UPDATE profiles SET credits = credits - amount WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Todo List

- [x] Create Supabase tables (templates, generation_jobs)
- [x] Set up RLS policies
- [x] Enable Realtime on generation_jobs
- [x] Create input_field_model.dart with Freezed
- [x] Create template_model.dart with Freezed
- [x] Create generation_job_model.dart with Freezed
- [x] Run `dart run build_runner build` for generated files
- [x] Implement template_repository.dart
- [x] Implement generation_repository.dart
- [x] Implement template_provider.dart
- [x] Implement generation_notifier.dart
- [ ] Create Edge Function for image generation (KIE integration)
- [ ] Set KIE_API_KEY in Edge Function secrets
- [x] Create template_card.dart widget
- [x] Create template_grid.dart widget
- [x] Update home_page.dart with template grid
- [x] Create input_field_builder.dart widget
- [x] Create generation_progress.dart widget
- [x] Update template_detail_page.dart
- [ ] Create Supabase Storage bucket (generated-images)
- [ ] Test end-to-end generation flow
- [ ] Add seed templates to database

## Success Criteria

- Templates load from Supabase
- Generation job starts and updates in real-time
- Images saved to Storage and URLs returned
- Credits deducted (non-premium users)
- Error states handled gracefully

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Imagen API rate limits | Queue jobs, implement backoff |
| Large images timeout | Use background tasks |
| Storage quota exceeded | Implement cleanup policy |
| Job stuck in generating | Add timeout + cleanup cron |

## Security Considerations

- KIE_API_KEY only in Edge Function secrets
 (not client)
- RLS ensures users only see their jobs
- Service role key for Edge Function only
- Validate prompt content (optional moderation)

## Next Steps

→ Phase 5: Gallery Feature
