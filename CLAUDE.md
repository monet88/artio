# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Rules

Follow `.claude/rules/development-rules.md` strictly. Core principles: **YAGNI, KISS, DRY**.

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Code generation (required after modifying Freezed/Riverpod annotations)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate during development)
dart run build_runner watch

# Run app
flutter run                # Default device
flutter run -d chrome      # Web
flutter run -d windows     # Windows

# Compile check (run after modifying any .dart file)
flutter analyze

# Format
dart format .
```

## Testing

```bash
# All tests
flutter test

# Single test file
flutter test test/features/auth/data/repositories/auth_repository_test.dart

# With coverage
flutter test --coverage

# Integration tests (requires Supabase credentials in .env.test)
flutter test integration_test/template_e2e_test.dart
```

## Environment Setup

Create `.env` from `.env.example`:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Environment files loaded as Flutter assets (see `pubspec.yaml` flutter.assets). Do NOT bundle `.env.test` in release assets.

## Architecture

**Artio** is a cross-platform AI image generation SaaS (Flutter 3.10+, Dart 3.10+).

### Feature-First Clean Architecture

```
lib/
+-- core/                   # Cross-cutting: constants, exceptions, providers, utils
+-- features/               # Each feature follows 3-layer pattern below
|   +-- auth/               # Email/OAuth/password reset
|   +-- template_engine/    # CORE: AI template-based image generation
|   +-- gallery/            # Masonry grid, download/share/delete
|   +-- settings/           # Theme switcher
|   +-- create/             # Text-to-image (placeholder)
+-- routing/                # GoRouter config
+-- shared/                 # MainShell, ErrorPage
+-- theme/                  # Theme management
+-- main.dart               # Entry point
```

### 3-Layer Pattern per Feature

```
features/{name}/
+-- domain/                 # Business logic (depends on nothing)
|   +-- entities/           # Freezed models
|   +-- repositories/       # Abstract interfaces
+-- data/                   # Implementation (depends on Domain)
|   +-- repositories/       # Concrete Supabase implementations
+-- presentation/           # UI + State (depends on Domain only)
    +-- providers/          # @riverpod annotated providers
    +-- screens/            # Full-screen pages
    +-- widgets/            # Reusable components
```

**Dependency rule**: Presentation -> Domain <- Data. Never import Data in Presentation.

### Key Patterns

- **State Management**: Riverpod with `@riverpod` code generation only (no manual providers). Use `AsyncValue.guard` for error handling.
- **Data Models**: Freezed with `part 'model.freezed.dart'` + `part 'model.g.dart'`. Factory constructors for JSON.
- **Navigation**: GoRouter with `ShellRoute` for bottom nav, auth guards via redirect. Config in `lib/routing/app_router.dart`.
- **Error Handling**: `AppException` from data layer -> `AppExceptionMapper` for user-friendly messages. Never expose stack traces.
- **Backend**: Supabase (Auth, PostgreSQL with RLS, Storage, Edge Functions, Realtime).

## Quick File Reference

| Resource | Path |
|----------|------|
| Main entry | `lib/main.dart` |
| Router config | `lib/routing/app_router.dart` |
| Supabase provider | `lib/core/providers/supabase_provider.dart` |
| Error mapper | `lib/core/utils/app_exception_mapper.dart` |
| Constants | `lib/core/constants/app_constants.dart` |
| Env config | `lib/core/config/env_config.dart` |

## AI Model API Reference

`docs/kie-api/` is the source of truth for all AI model API specs. Key files:

| Resource | Path |
|----------|------|
| Model Map (Index) | `docs/kie-api/kie-model-map.md` |
| Full Model List | `docs/kie-api/kie-api-llms.txt` |
| Google/Imagen | `docs/kie-api/google/` |
| Flux-2 | `docs/kie-api/flux2/` |
| GPT Image | `docs/kie-api/gpt-image/` |
| Seedream | `docs/kie-api/seedream/` |

Reference these when adding models, updating Edge Functions, or debugging API issues.

## Feature Status

| Feature | Status |
|---------|--------|
| Authentication | Complete |
| Template Engine | Complete |
| Gallery | Complete |
| Settings | Complete |
| Subscription & Credits | Pending |

## Known Technical Debt

| Issue | Priority |
|-------|----------|
| Test coverage ~5-10% (target 80%) | High |
| GoRouter uses raw strings (not TypedGoRoute) | Medium |
| DTO leakage in domain entities | Low (acceptable for MVP) |

## Tool Limitations

- `ast-grep` (sg) does not support Dart. Use `rg` (ripgrep), `flutter analyze`, or Dart LSP instead.
- On Windows, Claude Code uses Git Bash which may not resolve `.cmd` scripts.

## Documentation

All project docs in `./docs/`: project-overview-pdr.md, code-standards.md, codebase-summary.md, system-architecture.md, development-roadmap.md. Read `./README.md` for full project context.
