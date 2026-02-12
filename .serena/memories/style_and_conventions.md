# Style & Conventions

## Naming
- **Files**: kebab-case, descriptive (e.g. `auth-view-model.dart`, `app-exception-mapper.dart`)
- **Classes**: PascalCase (`AuthViewModel`, `TemplateEngine`)
- **Variables/functions**: camelCase
- **Constants**: camelCase or SCREAMING_SNAKE for top-level

## Code Style
- Max file size: 200-400 lines (800 absolute max)
- Prefer immutability — never mutate objects/arrays
- No emojis in code/comments/docs
- No hardcoding — use config/env
- Clean up dead code after changes

## State Management
- Riverpod with `@riverpod` code generation ONLY (no manual providers)
- Use `AsyncValue.guard` for error handling
- Generated files: `part 'file.g.dart'`

## Data Models
- Freezed with `part 'model.freezed.dart'` + `part 'model.g.dart'`
- Factory constructors for JSON serialization

## Error Handling
- `AppException` from data layer
- `AppExceptionMapper` for user-friendly messages
- Never expose stack traces
- Use try-catch, cover security standards

## Architecture Rules
- 3-layer per feature: domain / data / presentation
- Dependency rule: Presentation -> Domain <- Data
- Never import Data in Presentation
- Composition over inheritance

## Principles
- YAGNI, KISS, DRY strictly enforced
- No over-engineering or speculative features
- Surgical changes — touch only what you must
