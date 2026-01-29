# Test Directory

Mirrors `lib/` structure. Unit, widget, and integration tests.

## Structure

```
test/
├── core/
│   ├── fixtures/          # Shared test data factories
│   ├── mocks/             # Mocktail mock classes
│   └── helpers/           # pump_app, riverpod_test_utils
├── features/              # Mirrors lib/features/
│   ├── auth/
│   ├── gallery/
│   └── template_engine/
integration_test/          # E2E flow tests (separate dir)
```

## Where to Look

| Task | Location |
|------|----------|
| Add fixture | `core/fixtures/{entity}_fixtures.dart` |
| Add mock | `core/mocks/mock_repositories.dart` |
| Test helper | `core/helpers/` |
| Feature test | `features/{feature}/{layer}/` |

## Conventions

| Pattern | Rule |
|---------|------|
| Mock library | `mocktail` (not mockito) |
| File naming | `*_test.dart` for tests, `*_fixtures.dart` for data |
| Mock naming | `Mock{ClassName}` in `core/mocks/` |
| Test structure | Mirror exact path from `lib/` |

## Anti-Patterns (Learned)

| Forbidden | Do Instead |
|-----------|------------|
| Mock Supabase internals (`PostgrestFilterBuilder`) | Mock repository interface (`IAuthRepository`) |
| `Future.delayed(Duration(days: 1))` for loading state | Use `Completer<T>()` that never completes |
| `find.text('X')` when multiple matches | Use `find.widgetWithText(AppBar, 'X')` |
| Test PageView.builder internal text | Test widget structure instead |

## Commands

```bash
flutter test                              # All tests
flutter test test/features/auth/          # Feature tests
flutter test --coverage                   # With coverage
```

## Current Status

- **232 tests passing**
- **0 skipped**
- **0 failed**
