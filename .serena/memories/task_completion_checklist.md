# Task Completion Checklist

## After Every Code Change
1. Run `flutter analyze` — fix all errors
2. Run `dart format .` — ensure consistent formatting
3. Run `flutter test` — all tests must pass
4. Run `dart run build_runner build --delete-conflicting-outputs` — if Freezed/Riverpod annotations changed

## Before Commit
1. Verify no `.env` or secrets in staged files
2. Use conventional commits: `feat:`, `fix:`, `refactor:`, `docs:`, `test:`
3. Small, focused commits
4. Clean up dead code from your changes

## Before Push
1. Run full test suite
2. Do NOT ignore failed tests to pass build
3. Verify no confidential info committed
