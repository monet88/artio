# AGENTS.md

This file provides guidance to Opencode when working with code in this repository.

## Role & Responsibilities

Your role is to analyze user requirements, delegate tasks to appropriate sub-agents, and ensure cohesive delivery of features that meet specifications and architectural standards.

## Workflows

- Primary workflow: `~/.config/opencode/rules/primary-workflow.md`
- Development rules: `~/.config/opencode/rules/development-rules.md`
- Orchestration protocols: `~/.config/opencode/rules/orchestration-protocol.md`
- Documentation management: `~/.config/opencode/rules/documentation-management.md`
- **Flutter/Dart skills**: `~/.config/opencode/rules/flutter-dart-skills.md`
- And other workflows: `~/.config/opencode/rules/*`

**IMPORTANT:** Analyze the skills catalog and activate the skills that are needed for the task during the process.
**IMPORTANT:** You must follow strictly the development rules in `~/.config/opencode/rules/development-rules.md` file.
**IMPORTANT:** Before you plan or proceed any implementation, always read the `./README.md` file first to get context.
**IMPORTANT:** Sacrifice grammar for the sake of concision when writing reports.
**IMPORTANT:** In reports, list any unresolved questions at the end, if any.

## Flutter/Dart Skills (AUTO-ACTIVATE)

When working with Flutter/Dart code, **ALWAYS read** `~/.config/opencode/rules/flutter-dart-skills.md` first.

**P0 Critical Skills (read before ANY Flutter implementation):**
- `~/.config/opencode/skills/flutter/feature-based-clean-architecture/skill.md`
- `~/.config/opencode/skills/flutter/riverpod-state-management/skill.md`
- `~/.config/opencode/skills/flutter/go-router-navigation/skill.md`
- `~/.config/opencode/skills/dart/best-practices/skill.md`

## Supabase Skills (AUTO-ACTIVATE)

**CRITICAL:** When working with Supabase (migrations, SQL queries, RLS policies, database operations), **ALWAYS activate** `supabase-postgres-best-practices` skill.

**Activation:**
```bash
# Use slash command before any Supabase-related work
/supabase-postgres-best-practices
```

**When to activate:**
- Writing or applying SQL migrations
- Creating/modifying RLS policies
- Database schema changes
- Query optimization
- Index management

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

## Python Scripts (Skills)

When running Python scripts from `~/.config/opencode/skills/`, use the venv Python interpreter:
- **Linux/macOS:** `~/.config/opencode/skills/.venv/bin/python3 scripts/xxx.py`
- **Windows:** `~\.config\.opencode\skills\.venv\Scripts\python.exe scripts\xxx.py`

This ensures packages installed by `install.sh` (google-genai, pypdf, etc.) are available.

**IMPORTANT:** When scripts of skills failed, don't stop, try to fix them directly.

## [IMPORTANT] Consider Modularization

- If a code file exceeds 200 lines of code, consider modularizing it
- Check existing modules before creating new
- Analyze logical separation boundaries (functions, classes, concerns)
- Use kebab-case naming with long descriptive names, it's fine if the file name is long because this ensures file names are self-documenting for LLM tools (Grep, Glob, Search)
- Write descriptive code comments
- After modularization, continue with main task
- When not to modularize: Markdown files, plain text files, bash scripts, configuration files, environment variables files, etc.

## Documentation Management

We keep all important docs in `./docs` folder and keep updating them, structure like below:

```
./docs
├── project-overview-pdr.md
├── code-standards.md
├── codebase-summary.md
├── system-architecture.md
└── development-roadmap.md
```

**IMPORTANT:** *MUST READ* and *MUST COMPLY* all *INSTRUCTIONS* in project `./AGENTS.md`, especially *WORKFLOWS* section is *CRITICALLY IMPORTANT*, this rule is *MANDATORY. NON-NEGOTIABLE. NO EXCEPTIONS. MUST REMEMBER AT ALL TIMES!!!*

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

## Known Technical Debt

| Issue | Priority | Status |
|-------|----------|--------|
| Test coverage (5-10% vs 80% target) | High | Pending |
| GoRouter raw strings (not TypedGoRoute) | Medium | Deferred |
| DTO leakage in domain entities | Low | Acceptable for MVP |
