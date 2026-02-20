---
phase: 2
plan: 2
wave: 1
---

# Plan 2.2: Credit Balance Clamp & Email TLD Validation

## Objective
Add negative balance UI clamp in credit balance display and email TLD validation in auth screens. Both are UI safety guards — preventing display of impossible states and improving input validation.

## Context
- `plans/reports/review-260220-1533-edge-cases-verification.md` — Partial #9 (negative balance) and Partial #1 (email TLD)
- `lib/features/create/presentation/widgets/credit_balance_chip.dart` — 45 lines
- `lib/features/auth/presentation/screens/login_screen.dart` — L134-142 (email validator)
- `lib/features/auth/presentation/screens/register_screen.dart` — L144-152 (email validator)
- `lib/features/auth/presentation/screens/forgot_password_screen.dart` — L132-140 (email validator)

## Tasks

<task type="auto">
  <name>Clamp negative credit balance in UI</name>
  <files>
    - lib/features/create/presentation/widgets/credit_balance_chip.dart
  </files>
  <action>
    On L28, change:
    ```dart
    label: Text('${balance.balance} credits'),
    ```
    to:
    ```dart
    label: Text('${balance.balance.clamp(0, double.infinity).toInt()} credits'),
    ```

    This ensures negative values (which shouldn't occur due to DB constraints, but are possible in race conditions) display as 0.

    Simpler alternative using `math.max`:
    ```dart
    import 'dart:math' as math;
    // ...
    label: Text('${math.max(0, balance.balance)} credits'),
    ```

    Use `math.max` approach — it's cleaner and more readable.

    What to AVOID:
    - Do NOT change the `CreditBalance` model — this is a display-only guard
    - Do NOT add logic to the provider — keep transformation in the widget
  </action>
  <verify>
    1. `flutter analyze` — no issues
    2. `flutter test` — all tests pass
  </verify>
  <done>
    - `CreditBalanceChip` displays 0 instead of negative numbers
    - No changes to data model or provider
  </done>
</task>

<task type="auto">
  <name>Add email TLD validation to auth screens</name>
  <files>
    - lib/core/utils/email_validator.dart (NEW)
    - lib/features/auth/presentation/screens/login_screen.dart
    - lib/features/auth/presentation/screens/register_screen.dart
    - lib/features/auth/presentation/screens/forgot_password_screen.dart
    - test/core/utils/email_validator_test.dart (NEW)
  </files>
  <action>
    1. Create `lib/core/utils/email_validator.dart`:
       ```dart
       /// Simple email validation with TLD check.
       ///
       /// Validates that the email:
       /// - Contains exactly one `@`
       /// - Has a non-empty local part before `@`
       /// - Has a domain with at least one `.` (TLD check)
       /// - TLD is at least 2 characters
       class EmailValidator {
         static final _emailRegex = RegExp(
           r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
         );

         /// Returns null if valid, error message if invalid.
         static String? validate(String? value) {
           if (value == null || value.trim().isEmpty) {
             return 'Please enter your email';
           }
           if (!_emailRegex.hasMatch(value.trim())) {
             return 'Please enter a valid email address';
           }
           return null;
         }
       }
       ```

    2. In all 3 auth screens, replace the inline `validator:` with:
       ```dart
       import 'package:artio/core/utils/email_validator.dart';
       // ...
       validator: EmailValidator.validate,
       ```

       Files and lines to change:
       - `login_screen.dart` L134-142 → `validator: EmailValidator.validate,`
       - `register_screen.dart` L144-152 → `validator: EmailValidator.validate,`
       - `forgot_password_screen.dart` L132-140 → `validator: EmailValidator.validate,`

    3. Create `test/core/utils/email_validator_test.dart`:
       ```dart
       import 'package:artio/core/utils/email_validator.dart';
       import 'package:flutter_test/flutter_test.dart';

       void main() {
         group('EmailValidator', () {
           test('returns null for valid email', () {
             expect(EmailValidator.validate('user@example.com'), isNull);
           });

           test('returns error for empty', () {
             expect(EmailValidator.validate(''), isNotNull);
             expect(EmailValidator.validate(null), isNotNull);
           });

           test('returns error for missing @', () {
             expect(EmailValidator.validate('userexample.com'), isNotNull);
           });

           test('returns error for missing TLD', () {
             expect(EmailValidator.validate('user@example'), isNotNull);
           });

           test('returns error for single-char TLD', () {
             expect(EmailValidator.validate('user@example.c'), isNotNull);
           });

           test('accepts multi-part domain', () {
             expect(EmailValidator.validate('user@sub.example.com'), isNull);
           });
         });
       }
       ```

    What to AVOID:
    - Do NOT use a complex RFC 5322 regex — keep it simple and practical
    - Do NOT change error messages for the empty/null case (keep consistent)
    - Do NOT add the validator to Supabase/backend — this is client-side only
  </action>
  <verify>
    1. `flutter analyze` — no issues
    2. `flutter test test/core/utils/email_validator_test.dart` — all pass
    3. `flutter test` — all tests pass (no regression)
  </verify>
  <done>
    - `EmailValidator` utility class created with regex-based TLD check
    - All 3 auth screens use shared `EmailValidator.validate`
    - Unit tests for valid, empty, no @, no TLD, single-char TLD, multi-part domain
    - No inline validators remain in auth screens for email
  </done>
</task>

## Success Criteria
- [ ] `CreditBalanceChip` clamps negative balance to 0
- [ ] `EmailValidator` utility with TLD regex validation
- [ ] All 3 auth screens use `EmailValidator.validate`
- [ ] Email validator unit tests pass
- [ ] `flutter analyze` clean
- [ ] All tests pass (existing + new)
