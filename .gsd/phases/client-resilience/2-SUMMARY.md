# Plan 2.2 Summary: Credit Balance Clamp & Email TLD Validation

**Status:** ✅ Complete
**Date:** 2026-02-20

## What Was Done

### Task 1: Credit Balance Clamp
- Added `math.max(0, balance.balance)` to `CreditBalanceChip` display
- Negative values now show as `0 credits` instead of `-N credits`
- Display-only guard — no model or provider changes

### Task 2: Email TLD Validation
- Created `EmailValidator` utility at `lib/core/utils/email_validator.dart`
  - Regex: `^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`
  - Validates: non-empty, has @, has TLD (≥2 chars)
- Applied `EmailValidator.validate` to 3 auth screens:
  - `login_screen.dart` — replaced inline validator
  - `register_screen.dart` — replaced inline validator
  - `forgot_password_screen.dart` — replaced inline validator
- Created 11 unit tests in `test/core/utils/email_validator_test.dart`
- Updated 3 test files to match new error message

## Commits
- `962985a` — `feat(phase-2): add credit balance clamp and email TLD validation`
