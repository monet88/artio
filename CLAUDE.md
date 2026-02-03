# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Role & Responsibilities

Your role is to analyze user requirements, implement features following the established architecture, and ensure code quality standards are met.

## Development Rules

**IMPORTANT:** You must follow strictly the development rules in `.claude/rules/development-rules.md` file.

**Core Principles:**
- **YAGNI**: You Aren't Gonna Need It - implement only what's needed now
- **KISS**: Keep It Simple, Stupid - prefer simple solutions
- **DRY**: Don't Repeat Yourself - extract reusable code

## Recommended Skills

### P0 - Critical (Auto-activate)

| Skill | Trigger | Use Case |
|-------|---------|----------|
| `flutter-dart-best-practices` | `lib/**/*.dart` | Flutter/Dart patterns, Riverpod, GoRouter, Clean Architecture |
| `fix` | Bug reports, errors | Intelligent bug fixing with routing |
| `cook` | Feature implementation | Standalone feature development |
| `supabase-postgres-best-practices` | Migrations, RLS, SQL | Database operations |

### P1 - Operational

| Skill | Use Case |
|-------|----------|
| `debug` / `debugging` | Root cause analysis, tracing |
| `ai-multimodal` | Gemini API for image analysis (AI art generation) |
| `databases` | Supabase/PostgreSQL queries, schema design |
| `payment-integration` | SePay/Polar for subscription & credits |

### P2 - Supporting

| Skill | Use Case |
|-------|----------|
| `code-review` | Post-implementation review |
| `planning` | Complex feature planning |
| `scout` | Fast codebase exploration |
| `ui-ux-pro-max` | UI/UX design decisions |

## Development Workflow

### New Feature (Complex)
```
/brainstorm → /plan → /code → /test → /review:codebase → /git:cm
```

### New Feature (Simple)
```
/cook → /test → /git:cm
```

### Bug Fix
```
/debug → /fix → /test → /git:cm
```

### End of Session
```
/watzup → /git:cm
```

### Quick Reference

| Situation | Command |
|-----------|---------|
| Unclear approach, need debate | `/brainstorm` |
| Feature with clear requirements | `/plan` → `/code` |
| Small/simple feature | `/cook` |
| Bug report from user | `/debug` → `/fix` |
| Error during coding | `/fix` |
| After implementation | `/test` → `/review:codebase` |
| Wrap up session | `/watzup` → `/git:cm` |

## Project-Specific Guidelines

### Architecture Pattern

**Artio follows Feature-First Clean Architecture:**

```
lib/features/{feature}/
├── domain/              # Business logic + Interfaces
│   ├── entities/        # Freezed models
│   └── repositories/    # Abstract interfaces
├── data/                # Implementation
│   └── repositories/    # Concrete implementations
└── presentation/        # UI + State
    ├── providers/       # @riverpod providers
    ├── screens/         # Full-screen pages
    └── widgets/         # Reusable components
```

### Dependency Rule

**Presentation → Domain ← Data**

- Presentation depends on Domain (interfaces only)
- Data depends on Domain (implements interfaces)
- Domain depends on nothing (pure business logic)
- Never import Data directly in Presentation

### State Management (Riverpod)

- **Always use `@riverpod` annotations** (code generation)
- Never use manual providers
- Use `AsyncValue.guard` for error handling
- Inject repositories via constructor

### Data Models (Freezed)

- All domain entities use Freezed
- Include `part 'model.freezed.dart'` and `part 'model.g.dart'`
- Use factory constructors for JSON serialization

### Navigation (GoRouter)

- Use `ShellRoute` for main shell (bottom nav)
- Implement auth guards via redirect callback
- Route paths defined in `lib/routing/app_router.dart`

### Error Handling

- Throw `AppException` from data layer
- Use `AppExceptionMapper` for user-friendly messages
- Never expose stack traces to users

## Implemented Features

| Feature | Status | Notes |
|---------|--------|-------|
| Authentication | ✅ Complete | Email, OAuth, password reset |
| Template Engine | ✅ Complete | Browse, generate, track progress |
| Gallery | ✅ Complete | Masonry grid, view, download, share, delete |
| Settings | ✅ Complete | Theme switcher |
| Subscription & Credits | 🔲 Pending | Plan 3 |

## Code Generation

```bash
# Run after modifying Freezed/Riverpod annotations
dart run build_runner build --delete-conflicting-outputs

# Watch mode for development
dart run build_runner watch
```

## Code Quality

```bash
# Analyze code
flutter analyze

# Run tests
flutter test

# Format code
dart format .
```

## Code Search Tools

### Semantic Search (claude-context MCP)

Index codebase để search theo ý nghĩa, không chỉ text match:

```bash
# Index codebase (chạy 1 lần, hoặc khi code thay đổi nhiều)
mcp__claude-context__index_codebase path=F:/CodeBase/flutter-app/aiart splitter=ast

# Search theo semantic
mcp__claude-context__search_code query="nơi xử lý lỗi từ API"

# Check indexing status
mcp__claude-context__get_indexing_status
```

| Tool | Use Case |
|------|----------|
| `search_code` | Tìm code theo ý nghĩa: "authentication flow", "error handling" |
| `Grep` | Exact match: `class AuthRepository`, `@riverpod` |
| Dart MCP | Symbol navigation: go-to-definition, find-references |

### Tool Limitations

| Tool | Dart Support | Alternative |
|------|--------------|-------------|
| `ast-grep` (sg) | ❌ Not supported | `rg` (ripgrep), `dart analyze`, MCP dart LSP |
| `ripgrep` (rg) | ✅ Text search | - |

## Windows Bash Workarounds

Claude Code uses Git Bash which doesn't resolve `.cmd` scripts. Use direct calls when needed.

## Dart MCP Tools Setup

Before using Dart MCP tools (`dart_*`, `lsp_*`), add project root first:

```
mcp__dart__add_roots with uri: file:///F:/CodeBase/flutter-app/aiart
```

## Modularization Guidelines

- If a code file exceeds 200 lines of code, consider modularizing it
- Check existing modules before creating new
- Analyze logical separation boundaries (functions, classes, concerns)
- Use kebab-case naming with long descriptive names
- Write descriptive code comments
- When not to modularize: Markdown files, plain text files, bash scripts, configuration files

## Documentation

We keep all important docs in `./docs` folder:

```
./docs
├── project-overview-pdr.md
├── code-standards.md
├── codebase-summary.md
├── system-architecture.md
└── development-roadmap.md
```

**IMPORTANT:** Before implementing anything, always read the `./README.md` file first to get context.

## Quick File Reference

| Resource | Path |
|----------|------|
| Main entry | `lib/main.dart` |
| Router config | `lib/routing/app_router.dart` |
| Supabase provider | `lib/core/providers/supabase_provider.dart` |
| Error mapper | `lib/core/utils/app_exception_mapper.dart` |
| Constants | `lib/core/constants/app_constants.dart` |
| Auth feature | `lib/features/auth/` |
| Template engine | `lib/features/template_engine/` |
| Gallery feature | `lib/features/gallery/` |
| Settings feature | `lib/features/settings/` |
| Create feature | `lib/features/create/` |

## AI Model API Reference

When working with AI image generation models (KIE API, Gemini, etc.):

| Resource | Path | Description |
|----------|------|-------------|
| **Model Map (Index)** | `docs/kie-api/kie-model-map.md` | Master index of all models |
| **Full Model List** | `docs/kie-api/kie-api-llms.txt` | Complete KIE API model catalog |
| **Google/Imagen** | `docs/kie-api/google/` | Imagen4, Nano Banana, Pro models |
| **Flux-2** | `docs/kie-api/flux2/` | Flex and Pro variants |
| **GPT Image** | `docs/kie-api/gpt-image/` | GPT Image 1.5 models |
| **Seedream** | `docs/kie-api/seedream/` | Seedream 4.5 models |

**IMPORTANT:** The `docs/kie-api/` folder is the **source of truth** for all AI model API specifications. Always reference these docs when:
- Adding new models to the app
- Updating Edge Functions for generation
- Debugging API issues
- Understanding model-specific parameters

## Known Technical Debt

| Issue | Priority | Status |
|-------|----------|--------|
| Test coverage (5-10% vs 80% target) | High | Pending |
| GoRouter raw strings (not TypedGoRoute) | Medium | Deferred |
| DTO leakage in domain entities | Low | Acceptable for MVP |
