---
phase: 1
plan: 3
wave: 1
depends_on: []
files_modified:
  - lib/features/template_engine/data/repositories/generation_repository.dart
  - lib/core/utils/retry.dart
autonomous: true
must_haves:
  truths:
    - "429 responses trigger retry mechanism"
    - "Edge Function calls have a timeout"
    - "TLS errors are treated as transient"
  artifacts:
    - "AppException.network for 429 in both code paths"
    - ".timeout(Duration(seconds: 90)) on functions.invoke"
    - "HandshakeException in _isTransient"
---

# Plan 1.3: Network Retry Improvements

<objective>
Fix three network resilience bugs:
1. 429 rate limit throws `AppException.generation` (wrong type) — retry only catches `AppException.network`
2. No timeout on `functions.invoke('generate-image')` — can hang forever
3. `HandshakeException` (TLS errors) not in retry's transient error list

Purpose: Ensure rate limits are retried, stuck calls time out, and TLS errors recover.
Output: Correct exception types, timeouts, and complete transient error coverage
</objective>

<context>
Load for context:
- lib/features/template_engine/data/repositories/generation_repository.dart (full file, 148 lines)
- lib/core/utils/retry.dart (full file, 42 lines)
- lib/core/exceptions/app_exception.dart (sealed class definition)
- artifacts/superpowers/brainstorm.md (dual 429 path evidence)
</context>

<tasks>

<task type="auto">
  <name>Fix 429 exception type and add timeout in generation_repository</name>
  <files>
    lib/features/template_engine/data/repositories/generation_repository.dart
  </files>
  <action>
    TWO locations need fixing (brainstorm verified both):

    1. **Line 47-51** (response status check):
       Change from:
       ```dart
       throw const AppException.generation(
         message: 'Too many requests. Please wait a moment and try again.',
       );
       ```
       To:
       ```dart
       throw const AppException.network(
         message: 'Too many requests. Please wait a moment and try again.',
         statusCode: 429,
       );
       ```

    2. **Line 70-74** (FunctionException catch):
       Change from:
       ```dart
       throw const AppException.generation(
         message: 'Too many requests. Please wait a moment and try again.',
       );
       ```
       To:
       ```dart
       throw const AppException.network(
         message: 'Too many requests. Please wait a moment and try again.',
         statusCode: 429,
       );
       ```

    3. **Add timeout** to the `functions.invoke` call at line 35:
       ```dart
       final response = await _supabase.functions.invoke(
         'generate-image',
         body: { ... },
       ).timeout(const Duration(seconds: 90));
       ```
       Use 90s, NOT 30s — image generation via Replicate/KIE.ai takes 30-120s.
       Add `import 'dart:async';` if not already present (it IS already imported at line 1).

    4. **Add TimeoutException catch** after the FunctionException catch:
       ```dart
       on TimeoutException {
         throw const AppException.network(
           message: 'Image generation timed out. Please try again.',
           statusCode: 408,
         );
       }
       ```

    AVOID: Don't change the non-429 error paths — they correctly use AppException.generation for actual generation failures.
    AVOID: Don't use 30s timeout — generation takes 30-120s, so 30s would cause constant false failures.
  </action>
  <verify>
    flutter analyze lib/features/template_engine/
    grep -n "AppException.generation" lib/features/template_engine/data/repositories/generation_repository.dart → 429 lines should NOT appear
    grep -n "statusCode: 429" lib/features/template_engine/data/repositories/generation_repository.dart → should find 2 matches
    grep -n "timeout" lib/features/template_engine/data/repositories/generation_repository.dart → should find Duration(seconds: 90)
  </verify>
  <done>
    - Both 429 paths throw AppException.network with statusCode: 429
    - functions.invoke has 90s timeout
    - TimeoutException caught and wrapped as AppException.network
  </done>
</task>

<task type="auto">
  <name>Add HandshakeException to retry transient errors</name>
  <files>
    lib/core/utils/retry.dart
  </files>
  <action>
    Update `_isTransient()` function (line 28-41) to include `HandshakeException`:

    1. Add import: `import 'dart:io' show HandshakeException;`
       (SocketException is already imported via `dart:io`)
    2. Update the function:
       ```dart
       bool _isTransient(Object error) {
         if (error is SocketException || error is TimeoutException || error is HandshakeException) return true;
         // ... rest unchanged
       }
       ```

    AVOID: Don't add CertificateException — that usually indicates a real cert problem, not a transient issue.
    AVOID: Don't change the retry logic itself — only the transient error detection.
  </action>
  <verify>
    flutter analyze lib/core/utils/retry.dart
    grep -n "HandshakeException" lib/core/utils/retry.dart → should find it
  </verify>
  <done>
    - HandshakeException treated as transient error
    - TLS handshake failures trigger retry with backoff
    - Existing retry behavior unchanged for other error types
  </done>
</task>

</tasks>

<verification>
After all tasks, verify:
- [ ] `flutter test test/features/template_engine/` passes
- [ ] `flutter test test/core/utils/` passes
- [ ] `flutter analyze` clean
- [ ] 429 → AppException.network (not generation)
- [ ] Timeout present on functions.invoke
- [ ] HandshakeException in _isTransient
</verification>

<success_criteria>
- [ ] Rate limits automatically retried
- [ ] Stuck function calls time out after 90s
- [ ] TLS errors treated as transient
- [ ] No regression in generation flow
</success_criteria>
