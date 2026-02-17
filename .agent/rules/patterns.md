# Common Patterns

## Repository Pattern

All data access goes through repositories (Clean Architecture):
- Abstract repository in `domain/` defines the interface
- Concrete implementation in `data/` handles Supabase/storage details
- Presentation layer accesses data via Riverpod providers, never directly

## Immutable Data Classes

Use Freezed for all domain entities:
- Define with `@freezed` annotation
- JSON serialization via `@JsonSerializable`
- Use `copyWith()` for updates, never mutate

## State Management

Riverpod with codegen (`@riverpod` annotation):
- `AsyncNotifier` for async state with mutations
- `FutureProvider` for simple async reads
- `Provider` for synchronous computed values
- Watch selectively (`select()`) to minimize rebuilds

## Error Handling Pattern

```
Raw exception → AppExceptionMapper → AppException (typed) → UI message
```

- Catch at repository/provider level
- Map to `AppException` union type (network, server, auth, timeout, validation, unknown)
- Use `retry()` with exponential backoff for transient failures
