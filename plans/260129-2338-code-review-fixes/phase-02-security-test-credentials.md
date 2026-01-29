# Phase 02: Security - Test Credentials Cleanup

## Parallelization Info

| Property | Value |
|----------|-------|
| Group | A (Security) |
| Can Run With | Phase 01 |
| Blocked By | None |
| Blocks | Group B (Phases 03, 04) |

## File Ownership (Exclusive)

- `integration_test/template_e2e_test.dart`
- `.env.test.example` (create new)

## Priority: CRITICAL

**Issue**: Hardcoded Supabase URL and anon key in test file. While anon keys are public, hardcoding promotes bad practices and makes key rotation difficult.

## Current State (Problematic)

```dart
await Supabase.initialize(
  url: 'https://yqzhmmyovpnbelybadgp.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```

## Implementation Steps

### Step 1: Create `.env.test.example`

```bash
# .env.test.example
# Copy to .env.test and fill in values for integration testing

SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### Step 2: Add `.env.test` to `.gitignore`

Verify `.env.test` is covered by existing patterns:
```
.env
.env.*
!.env.example
```

Already covered by `!.env.example` pattern - `.env.test.example` is safe.

### Step 3: Update `integration_test/template_e2e_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Templates E2E Test', () {
    setUpAll(() async {
      // Load test environment variables
      await dotenv.load(fileName: '.env.test');

      final supabaseUrl = dotenv.env['SUPABASE_URL'];
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

      if (supabaseUrl == null || supabaseAnonKey == null) {
        throw Exception(
          'Missing required environment variables. '
          'Copy .env.test.example to .env.test and fill in values.',
        );
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    });

    // ... rest of tests unchanged
  });
}
```

### Step 4: Add flutter_dotenv dependency (if not present)

Check `pubspec.yaml` for `flutter_dotenv`. If missing:
```yaml
dev_dependencies:
  flutter_dotenv: ^5.1.0
```

### Step 5: Update CI workflow (if exists)

For GitHub Actions, use secrets:
```yaml
env:
  SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
  SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
```

## Success Criteria

- [ ] No hardcoded credentials in source code
- [ ] `.env.test.example` created with placeholder values
- [ ] Integration tests load credentials from environment
- [ ] Tests fail gracefully with clear error if env vars missing
- [ ] Documentation for running integration tests locally

## Conflict Prevention

- This phase has exclusive ownership of integration test files
- Phase 03 handles `.gitignore` but patterns already cover `.env.test`

## Security Considerations

- Anon keys are technically public but should still be rotatable
- Environment-based config enables key rotation without code changes
- CI/CD should use secrets, not committed env files
