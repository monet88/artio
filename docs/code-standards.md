# Code Standards

## General Principles

- Prefer simple, direct implementations that match the existing architecture.
- Keep changes local and cohesive.
- Avoid speculative abstractions.
- Do not mutate objects in place when a copy or new value is cleaner.
- Keep documentation aligned with code instead of letting either drift.

## Flutter / Dart Standards

### Architecture

- Use feature-first clean architecture in `lib/features/<feature>/`.
- Keep presentation, domain, and data responsibilities separate.
- Presentation code should depend on domain abstractions, not concrete data
  implementations.
- Use Riverpod code generation (`@riverpod`) for app state and view models.
- Use typed GoRouter routes for navigation.

### Models and state

- Use Freezed for immutable data models and unions.
- Keep generated files untouched.
- Prefer `copyWith` and immutable state transitions.
- Avoid `dynamic`; use explicit types.
- Avoid `!` unless a null value is truly unrecoverable.

### Files and imports

- Use `package:` imports for app code.
- Keep files focused and short; split large widgets or services.
- Use descriptive snake_case file names.
- Mirror `lib/` structure in `test/`.

### UI and design system

- Use design-system tokens instead of hardcoded colors or spacing.
- Reuse `AppColors`, `AppSpacing`, `AppDimensions`, and `AppGradients` in the
  main app.
- Reuse the admin color/theme tokens in the admin surface.
- Keep widgets composable, semantic, and accessible.
- Avoid heavy work inside `build()`.

### Async and error handling

- Use `AsyncValue.guard()` or explicit `try`/`catch` with typed exceptions.
- Prefer explicit failure states over silent fallthrough.
- Call `unawaited()` for intentional fire-and-forget work.
- Check `context.mounted` after `await` when navigation or UI updates follow.

## Admin App Standards

- Keep the admin app simpler than the main app.
- Use plain Riverpod providers where they fit better than full view models.
- Call Supabase directly through the admin app provider layer.
- Keep admin templates and dashboards focused on operational workflows.

## Supabase / TypeScript Standards

- Keep Edge Functions small, explicit, and defensive.
- Validate request method, authentication, and required fields early.
- Use `corsHeaders` consistently across functions.
- Keep service-role access server-side only.
- Preserve idempotency on retry-prone flows.
- Keep `supabase/functions/_shared/model_config.ts` in sync with the client AI
  model list and costs.
- Prefer structured logging with enough context to debug production issues.

## Security Standards

- Never commit secrets or service-role keys.
- Use secure storage for sensitive runtime data on device.
- Validate all user input before sending it to APIs, storage, or navigation.
- Keep subscription, credit, and tier state server-authoritative.
- Treat public client config as configuration, not a secret boundary.

## Testing Standards

- Write behavior-focused tests.
- Keep unit tests for pure logic and state transitions.
- Keep integration tests for system boundaries and external services.
- Keep admin tests scoped to admin features.
- Use `flutter test --tags integration` for tagged integration coverage.
- Keep test fixtures independent and deterministic.

## Build and validation

- Run formatter and analyzer before considering a change done.
- Keep generated code reproducible via build_runner.
- For local Supabase work, confirm the CLI version can read the lockfile.
- When a docs or architecture change introduces new operational commands,
  document them in the relevant guide instead of scattering notes.
