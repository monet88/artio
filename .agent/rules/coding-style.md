# Coding Style

## Principles

**YAGNI · KISS · DRY** — Always.

## Immutability (CRITICAL)

Always create new objects, never mutate existing ones:
- Use `copyWith()` (Freezed) instead of modifying fields in-place
- Prevents hidden side effects, enables safe concurrency

## File Organization & Modularization

Many small files > few large files:
- Target: ≤ 250 lines per file (project convention)
- **If a file exceeds 200 lines, consider modularizing it**
- High cohesion, low coupling
- Organize by feature/domain, not by type
- Use composition over inheritance for complex widgets
- Extract utility functions into separate modules
- Write descriptive code comments

Before modularizing:
1. Check if existing modules already cover the concern
2. Analyze logical separation boundaries (functions, classes, concerns)
3. After modularization, continue with main task

When **NOT** to modularize: Markdown, plain text, bash scripts, config files, `.env` files.

## Naming

- Dart files: `snake_case` (Dart convention)
- Use long descriptive names — file names should be self-documenting for LLM tools (Grep, Glob, Search)

## Error Handling

- Handle errors explicitly at every level
- Use `AppException` (freezed union) for typed errors
- Provide user-friendly messages in UI-facing code
- Log detailed context server-side (Sentry)
- Never silently swallow errors

## Input Validation

- Validate all user input before processing
- Fail fast with clear error messages
- Never trust external data (API responses, user input)

## Quality Checklist

Before marking work complete:
- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (≤250 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling
- [ ] No hardcoded values (use constants or config)
- [ ] Immutable patterns used (Freezed `copyWith`)
