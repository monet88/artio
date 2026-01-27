# Phase 3: Error Message Mapper

## Context Links

- [Flutter Expert Review](../reports/flutter-expert-260125-1503-phase45-review.md) - M2 finding
- [AppException Definition](../../lib/exceptions/app_exception.dart)

## Overview

**Priority**: P2 (Medium)
**Status**: completed
**Effort**: 1.5 hours
**Depends on**: Phase 1 complete (uses new path structure)

Create `AppExceptionMapper` utility to convert `AppException` types to user-friendly messages. Update all `AsyncValue.when(error:)` handlers to use mapper.

## Key Insights

1. Current UI shows raw `$e` - technical messages exposed to users
2. `AppException` is a sealed class with 6 variants
3. Pattern matching on sealed class = exhaustive, compile-safe
4. Need centralized mapper for consistency

## Requirements

### Functional
- Map each `AppException` variant to user-friendly message
- Fallback for non-AppException errors
- Localization-ready (but not implementing l10n now)

### Non-Functional
- Single source of truth for error messages
- Extensible for future exception types

## Architecture

### Current Pattern (BEFORE)

```dart
error: (e, _) => Center(child: Text('Error: $e')),
```

### Target Pattern (AFTER)

```dart
error: (e, _) => Center(
  child: Text(AppExceptionMapper.toUserMessage(e)),
),
```

### AppExceptionMapper Design

```dart
/// Maps AppException variants to user-friendly messages.
class AppExceptionMapper {
  AppExceptionMapper._();

  static String toUserMessage(Object error) {
    if (error is! AppException) {
      return 'An unexpected error occurred. Please try again.';
    }

    return switch (error) {
      NetworkException(:final message, :final statusCode) =>
        _networkMessage(message, statusCode),
      AuthException(:final message) =>
        _authMessage(message),
      StorageException(:final message) =>
        message,
      PaymentException(:final message) =>
        _paymentMessage(message),
      GenerationException(:final message) =>
        message, // Already user-friendly
      UnknownException() =>
        'Something went wrong. Please try again.',
    };
  }

  static String _networkMessage(String message, int? statusCode) {
    if (statusCode == 404) return 'Resource not found.';
    if (statusCode == 401) return 'Session expired. Please sign in again.';
    if (statusCode == 403) return 'You don\'t have permission for this action.';
    if (statusCode == 500) return 'Server error. Please try again later.';
    return 'Connection error. Check your internet and try again.';
  }

  static String _authMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid') && lower.contains('credentials')) {
      return 'Invalid email or password.';
    }
    if (lower.contains('email') && lower.contains('taken')) {
      return 'This email is already registered.';
    }
    if (lower.contains('weak password')) {
      return 'Password must be at least 6 characters.';
    }
    return 'Authentication failed. Please try again.';
  }

  static String _paymentMessage(String message) {
    return 'Payment could not be processed. Please try again.';
  }
}
```

## Related Code Files

### Files to Create

- `lib/core/utils/app_exception_mapper.dart`

### Files to Modify (error handlers)

- `lib/features/template_engine/presentation/screens/template_detail_screen.dart`
- Any other screens with `AsyncValue.when(error:)` patterns

## Implementation Steps

### Step 1: Create AppExceptionMapper (30 min)

Create `lib/core/utils/app_exception_mapper.dart`:

```dart
import '../../exceptions/app_exception.dart';

/// Maps [AppException] variants to user-friendly messages.
///
/// Usage:
/// ```dart
/// asyncValue.when(
///   error: (e, _) => Text(AppExceptionMapper.toUserMessage(e)),
///   // ...
/// )
/// ```
class AppExceptionMapper {
  AppExceptionMapper._(); // Private constructor, static methods only

  /// Converts an error to a user-displayable message.
  ///
  /// Handles all [AppException] variants with appropriate messages.
  /// Non-AppException errors get a generic fallback.
  static String toUserMessage(Object error) {
    if (error is! AppException) {
      return 'An unexpected error occurred. Please try again.';
    }

    return switch (error) {
      NetworkException(:final message, :final statusCode) =>
        _networkMessage(message, statusCode),
      AuthException(:final message) =>
        _authMessage(message),
      StorageException(:final message) =>
        message,
      PaymentException(:final message) =>
        _paymentMessage(message),
      GenerationException(:final message) =>
        message,
      UnknownException() =>
        'Something went wrong. Please try again.',
    };
  }

  static String _networkMessage(String message, int? statusCode) {
    return switch (statusCode) {
      404 => 'The requested resource was not found.',
      401 => 'Your session has expired. Please sign in again.',
      403 => 'You don\'t have permission for this action.',
      429 => 'Too many requests. Please wait a moment.',
      >= 500 && < 600 => 'Server error. Please try again later.',
      _ => 'Connection error. Check your internet and try again.',
    };
  }

  static String _authMessage(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('invalid') && lower.contains('credentials') ||
        lower.contains('invalid login credentials')) {
      return 'Invalid email or password.';
    }
    if (lower.contains('email') && lower.contains('taken') ||
        lower.contains('already registered')) {
      return 'This email is already registered. Try signing in.';
    }
    if (lower.contains('weak password') || lower.contains('password') && lower.contains('short')) {
      return 'Password must be at least 6 characters.';
    }
    if (lower.contains('rate limit') || lower.contains('too many')) {
      return 'Too many attempts. Please wait and try again.';
    }

    return 'Authentication failed. Please try again.';
  }

  static String _paymentMessage(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('cancelled') || lower.contains('canceled')) {
      return 'Payment was cancelled.';
    }
    if (lower.contains('declined')) {
      return 'Payment was declined. Please try another method.';
    }

    return 'Payment could not be processed. Please try again.';
  }
}
```

### Step 2: Find All Error Handlers (10 min)

Search for patterns:
- `error: (e, _) =>`
- `AsyncValue.when(`
- `.when(error:`

```bash
grep -rn "error: (e" lib/features/
```

### Step 3: Update template_detail_screen.dart (15 min)

Update both error handlers:

```dart
import '../../../core/utils/app_exception_mapper.dart';

// Line ~50
error: (e, _) => Center(
  child: Text(AppExceptionMapper.toUserMessage(e)),
),

// Line ~117
error: (error, _) => Column(
  children: [
    Text(
      AppExceptionMapper.toUserMessage(error),
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
    // ...
  ],
),
```

### Step 4: Update Other Screens (20 min)

Find and update any other screens with error handlers.

### Step 5: Verify (15 min)

```bash
flutter analyze
flutter test
```

## Todo List

- [x] Create `lib/core/utils/app_exception_mapper.dart`
- [x] Search for all AsyncValue error handlers
- [x] Update template_detail_screen.dart error handlers
- [x] Update other screens if found
- [x] Run flutter analyze
- [x] Run flutter test
- [x] Manual test: trigger network error, verify friendly message

## Success Criteria

- [x] `AppExceptionMapper` exists with exhaustive pattern matching
- [x] All `AsyncValue.when(error:)` handlers use `AppExceptionMapper.toUserMessage()`
- [x] No raw `$e` or `.toString()` in error UI
- [x] Compile-time safety via sealed class pattern matching

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Missing error handler locations | Medium | Low | Grep search before/after |
| Message too generic | Low | Low | Add more patterns to mapper later |
| New AppException variant added | Low | None | Compiler enforces exhaustive match |

## Security Considerations

- Do NOT expose stack traces or internal details in user messages
- Sanitize any dynamic content before display
- Consider logging original error for debugging (not displaying)

## Next Steps

After completing Phase 3:
1. Proceed to Phase 4: Code Quality
2. Consider adding error logging (non-blocking)
