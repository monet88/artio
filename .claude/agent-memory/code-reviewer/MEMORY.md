# Code Reviewer Memory

## Project Patterns

- ai_models.dart (Dart) must stay in sync with model_config.ts (TS) -- credit costs, premium flags, model IDs
- model_config_test.ts has sync-validation tests that must be updated whenever models are added/removed
- The Create flow (lib/features/create/) and Template Engine flow (lib/features/template_engine/) share the Generation repository but have separate ViewModels
- Supabase storage bucket generated-images is PRIVATE with RLS enforcing auth.uid() = foldername[1]
- Storage bucket file_size_limit is 10MB (migration 20260128115551)

## API Knowledge

- Google Gemini models (gemini-*) use :generateContent endpoint
- Google Imagen models (imagen-4.0-*) use :predict endpoint with different schema (instances/parameters)
- KIE API models have model-specific input field names (image_urls, input_urls, image_input) -- see buildKieInput()

## Common Issues Found

- Tests not updated when model list changes (model count, credit costs, premium flags)
- ImageUploadService hardcodes JPEG content type -- needs MIME detection
- GenerationViewModel (template flow) does not forward modelId/outputFormat to repository
- initState guards may race with async template loading

## Test Infrastructure

- Flutter tests: flutter test test/path/file_test.dart
- Deno tests: deno test supabase/functions/_shared/model_config_test.ts
- Flutter analyze succeeds on changed files (info-level warnings only)
