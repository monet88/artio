---
title: "Phase 1: Project Setup"
status: pending
effort: 3h
---

# Phase 1: Project Setup

## Context Links

- [Flutter Docs](https://docs.flutter.dev)
- [Riverpod Generator](https://riverpod.dev/docs/concepts/about_code_generation)
- [Freezed](https://pub.dev/packages/freezed)

## Overview

Initialize Flutter project with all required dependencies, code generation setup, and folder structure.

## Key Insights

- Use `riverpod_generator` with `@riverpod` annotation for type-safe providers
- Freezed generates immutable data classes with copyWith, equality, JSON serialization
- Build runner required: `dart run build_runner build --delete-conflicting-outputs`

## Requirements

### Functional
- Flutter project targeting Android, iOS, Web
- All dependencies installed and verified
- Code generation working

### Non-Functional
- Clean folder structure matching feature-first architecture
- Git initialized with .gitignore

## Architecture

3-layer architecture per feature (Domain → Data → Presentation):

```
lib/
├── l10n/                           # Localization
├── core/
│   ├── router/                     # go_router setup
│   ├── theme/                      # flex_color_scheme
│   ├── network/                    # dio_client
│   ├── exceptions/                 # Custom exceptions
│   ├── constants/                  # App constants
│   └── utils/                      # Utilities
├── shared/
│   ├── providers/                  # Global providers
│   ├── widgets/                    # Shared widgets
│   └── utils/                      # Helpers, extensions
├── features/
│   ├── auth/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/       # Interfaces
│   │   ├── data/
│   │   │   ├── data_sources/
│   │   │   ├── dtos/
│   │   │   └── repositories/       # Implementations
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── pages/
│   │       └── widgets/
│   ├── template_engine/            # Image-to-image (Home tab)
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── create/                     # Text-to-image (Create tab)
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── gallery/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   ├── subscription/
│   │   ├── domain/
│   │   ├── data/
│   │   └── presentation/
│   └── settings/
│       ├── domain/
│       ├── data/
│       └── presentation/
└── main.dart
```

## Related Code Files

### Create
- `lib/main.dart` - Entry point with ProviderScope
- `lib/core/constants/app_constants.dart` - App-wide constants
- `lib/core/constants/env_constants.dart` - Environment variables
- `analysis_options.yaml` - Lint rules
- `build.yaml` - Build runner config

## Implementation Steps

1. **Create Flutter project**
   ```bash
   flutter create --org com.artio --project-name artio .
   flutter config --enable-web
   ```

2. **Add dependencies to pubspec.yaml**
   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     flutter_localizations:
       sdk: flutter
     # State Management
     flutter_riverpod: ^2.6.1
     riverpod_annotation: ^2.6.1
     # Data Classes
     freezed_annotation: ^2.4.4
     json_annotation: ^4.9.0
     # Backend
     supabase_flutter: ^2.11.0
     # Routing
     go_router: ^14.8.1
     # HTTP
     dio: ^5.7.0
     # Theme
     flex_color_scheme: ^8.2.0
     # Payments
     purchases_flutter: ^9.0.0
     # Ads (mobile only)
     google_mobile_ads: ^6.0.0
     # Utils
     intl: ^0.20.1
     cached_network_image: ^3.4.1
     flutter_svg: ^2.0.17
     image_picker: ^1.1.2
     path_provider: ^2.1.5
     shared_preferences: ^2.3.4
     connectivity_plus: ^6.1.1
     flutter_dotenv: ^5.2.1
     logger: ^2.5.0
     equatable: ^2.0.7

   dev_dependencies:
     flutter_test:
       sdk: flutter
     flutter_lints: ^5.0.0
     build_runner: ^2.4.14
     riverpod_generator: ^2.6.3
     freezed: ^2.5.8
     json_serializable: ^6.9.2
     go_router_builder: ^2.8.0
     mockito: ^5.4.4
     mocktail: ^1.0.4
   ```

3. **Create folder structure**
   ```bash
   mkdir -p lib/l10n
   mkdir -p lib/core/{router,theme,network,exceptions,constants,utils}
   mkdir -p lib/shared/{providers,widgets,utils}

   # Create features with 3-layer architecture
   mkdir -p lib/features/auth/{domain/{entities,repositories},data/{data_sources,dtos,repositories},presentation/{providers,pages,widgets}}
   mkdir -p lib/features/template_engine/{domain,data,presentation}
   mkdir -p lib/features/create/{domain,data,presentation}
   mkdir -p lib/features/gallery/{domain,data,presentation}
   mkdir -p lib/features/subscription/{domain,data,presentation}
   mkdir -p lib/features/settings/{domain,data,presentation}
   ```

4. **Create build.yaml for Freezed union key config**
   ```yaml
   targets:
     $default:
       builders:
         freezed:
           options:
             union_key: "type"
             union_value_case: pascal
   ```

5. **Create .env file structure**
   ```
   SUPABASE_URL=
   SUPABASE_ANON_KEY=
   GEMINI_API_KEY=
   REVENUECAT_APPLE_KEY=
   REVENUECAT_GOOGLE_KEY=
   REVENUECAT_WEB_KEY=
   STRIPE_PUBLISHABLE_KEY=
   ADMOB_ANDROID_APP_ID=
   ADMOB_IOS_APP_ID=
   ```

6. **Create main.dart skeleton**
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   import 'package:supabase_flutter/supabase_flutter.dart';

   Future<void> main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await dotenv.load();
     await Supabase.initialize(
       url: dotenv.env['SUPABASE_URL']!,
       anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
     );
     runApp(const ProviderScope(child: ArtioApp()));
   }

   class ArtioApp extends ConsumerWidget {
     const ArtioApp({super.key});

     @override
     Widget build(BuildContext context, WidgetRef ref) {
       // Router and theme will be added in Phase 2
       return const MaterialApp(
         title: 'Artio',
         home: Scaffold(body: Center(child: Text('Artio'))),
       );
     }
   }
   ```

7. **Run code generation**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

8. **Verify build on all platforms**
   ```bash
   flutter build apk --debug
   flutter build ios --debug --no-codesign
   flutter build web
   ```

## Todo List

- [ ] Create Flutter project with correct organization
- [ ] Add all dependencies to pubspec.yaml
- [ ] Create folder structure
- [ ] Configure build.yaml for Freezed
- [ ] Create .env and .env.example
- [ ] Update .gitignore for .env and generated files
- [ ] Create main.dart with Supabase init
- [ ] Run build_runner and verify no errors
- [ ] Test build on Android, iOS, Web

## Success Criteria

- `flutter pub get` succeeds
- `dart run build_runner build` succeeds
- App launches on all 3 platforms
- Folder structure matches architecture

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Dependency conflicts | Pin exact versions |
| Code gen failures | Check Dart/Flutter SDK compatibility |
| Platform-specific issues | Test early on each platform |

## Security Considerations

- Never commit .env files
- Add .env to .gitignore before first commit
- Use flutter_dotenv for env management

## Next Steps

→ Phase 2: Core Infrastructure (router, theme, exceptions)
