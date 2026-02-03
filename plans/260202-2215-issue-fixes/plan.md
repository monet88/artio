# [Bug Fix] Implementation Plan

**Date**: 2026-02-02  
**Type**: Bug Fix  
**Priority**: High  
**Context Tokens**: 120 words

## Executive Summary
Fix six quality/security issues across config, routing, and settings to prevent dropped Sentry events, inconsistent env loading, duplicate error reporting, notification toggle race, accidental production secrets in assets, and misleading gallery routes.

## Issue Analysis
### Symptoms
- Sentry capture wrapper drops Future, risking lost events on shutdown.
- Development env naming differs from other environments.
- Error mapper sends Sentry events during UI mapping.
- Notifications provider can overwrite a user toggle after async load.
- Production env file bundled in assets.
- Gallery route includes unused `id` parameter.

### Root Cause
Side effects embedded in mapping/initialization layers and inconsistent env conventions; route path includes unused parameter.

### Evidence
- **Affected Components**: `lib/core/config/sentry_config.dart`, `lib/core/config/env_config.dart`, `lib/core/utils/app_exception_mapper.dart`, `lib/features/settings/data/notifications_provider.dart`, `lib/features/settings/presentation/settings_screen.dart`, `pubspec.yaml`, `lib/routing/routes/app_routes.dart`, `lib/features/gallery/presentation/pages/gallery_page.dart`, `lib/features/template_engine/presentation/screens/template_detail_screen.dart`, `lib/features/template_engine/presentation/widgets/template_grid.dart`, `lib/features/template_engine/presentation/view_models/generation_view_model.dart`.

## Context Links
- **Plan Template**: `plans/templates/bug-fix-template.md`
- **Standards**: `docs/code-standards.md`

## Solution Design
### Approach
Move Sentry capture into explicit error-handling points, make capture awaitable, standardize env naming to `.env.<env>`, convert notifications provider to async build, remove production env asset, and drop unused gallery id param.

### Changes Required
1. **Sentry config** (`lib/core/config/sentry_config.dart`): return `Future<void>` from `captureException` and await Sentry.
2. **Env config** (`lib/core/config/env_config.dart`): use `.env.<env>` for all environments.
3. **Exception mapper** (`lib/core/utils/app_exception_mapper.dart`): remove Sentry side effects.
4. **Template error handling** (`lib/features/template_engine/presentation/widgets/template_grid.dart`, `lib/features/template_engine/presentation/screens/template_detail_screen.dart`, `lib/features/template_engine/presentation/view_models/generation_view_model.dart`): capture errors once in error-handling layer.
5. **Notifications provider** (`lib/features/settings/data/notifications_provider.dart`): use async build and AsyncValue state; update Settings screen and tests.
6. **Assets** (`pubspec.yaml`): remove `.env.production` from assets list.
7. **Routes** (`lib/routing/routes/app_routes.dart`, `lib/features/gallery/presentation/pages/gallery_page.dart`): remove unused `:id` param from gallery route.

### Testing Changes
- Update settings screen tests for async notifications provider.
- Add unit coverage for notifications provider if missing.
- Update mapper tests only if interface changes.

## Implementation Steps
1. [ ] Update `sentry_config.dart` to await capture and return Future.
2. [ ] Standardize env filename in `env_config.dart`.
3. [ ] Remove Sentry side effects from `app_exception_mapper.dart`.
4. [ ] Add explicit Sentry capture in template UI error handlers and generation view model.
5. [ ] Refactor notifications provider to async build, update Settings screen and tests.
6. [ ] Remove `.env.production` asset and update any docs if required.
7. [ ] Remove gallery route `:id` param and adjust navigation.
8. [ ] Run `dart run build_runner build --delete-conflicting-outputs` if needed.
9. [ ] Run `lsp_diagnostics` on all modified files.
10. [ ] Run tests and build.

## Verification Plan
### Test Cases
- [ ] Settings screen renders with notifications toggle using async provider.
- [ ] Template detail error rendering does not double-report to Sentry on rebuild.
- [ ] Gallery image route works without unused `id` param.

### Rollback Plan
Revert changes in the above files and restore previous env and routing behavior.

## Risk Assessment
| Risk | Impact | Mitigation |
|------|--------|------------|
| Async provider changes break tests | Medium | Update overrides to AsyncValue and add tests |
| Removing `.env.production` breaks release setup | Medium | Confirm runtime uses dart-define | 

## TODO Checklist
- [ ] Implement fixes
- [ ] Update tests
- [ ] Run analyze/build/tests
- [ ] Code review
