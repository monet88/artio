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

## Flutter/Dart Skills (AUTO-ACTIVATE)

When working with Flutter/Dart code, **ALWAYS active** `.claude/skills/flutter/flutter-expert/SKILL.md"` skill first.

**P0 Critical Skills (read before ANY Flutter implementation):**
- `.claude/skills/flutter/feature-based-clean-architecture/SKILL.md`
- `.claude/skills/flutter/riverpod-state-management/SKILL.md`
- `.claude/skills/flutter/go-router-navigation/SKILL.md`
- `.claude/skills/dart/best-practices/SKILL.md`

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

## Known Technical Debt

| Issue | Priority | Status |
|-------|----------|--------|
| Test coverage (5-10% vs 80% target) | High | Pending |
| GoRouter raw strings (not TypedGoRoute) | Medium | Deferred |
| DTO leakage in domain entities | Low | Acceptable for MVP |
