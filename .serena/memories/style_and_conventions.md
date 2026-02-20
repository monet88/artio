# Style and Conventions

## Naming Conventions
- **Files**: kebab-case (e.g., `auth_repository.dart`, `user_model.dart`)
- **Classes**: PascalCase (e.g., `AuthRepository`, `UserModel`)
- **Methods/Functions**: camelCase (e.g., `signInWithEmail`, `getUserById`)
- **Private members**: prefix with `_` (e.g., `_authClient`, `_handleError`)

## Code Style
- Use `const` constructors where possible
- Prefer final fields over mutable
- Strict null safety - no nullable unless necessary
- Type annotations on public APIs

## Architecture Rules
1. **3-layer separation**: domain/data/presentation
2. **Dependency rule**: Presentation -> Domain <- Data
3. **No Data in Presentation**: Never import data layer in presentation
4. **Repository pattern**: Use interfaces in domain, implement in data

## Flutter Specific
- Use `@riverpod` annotations for code generation
- Prefer `AsyncValue` for async state
- Use `Freezed` for immutable models
- Use `go_router` for navigation with auth guards

## Error Handling
- Use `AppException` sealed hierarchy
- Map to user-friendly messages via `AppExceptionMapper`
- Never expose raw exceptions to UI

## Testing
- Unit tests in `test/features/{feature}/`
- Widget tests alongside components
- Integration tests in `integration_test/`
- Mock Supabase with `mocktail`

## Documentation
- dartdoc on public APIs
- Explain "why" not "what" in comments
- Keep docs in `docs/` directory
