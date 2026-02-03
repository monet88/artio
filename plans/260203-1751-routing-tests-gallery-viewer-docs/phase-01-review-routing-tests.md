---
title: "Phase 01: Review/refactor routing tests"
description: "Tighten routing tests with minimal refactors and clearer assertions."
status: complete
priority: P2
effort: 2h
branch: chore/project-optimization
tags: [tests, routing]
created: 2026-02-03
---

## Context Links
- `lib/routing/routes/app_routes.dart`
- `test/core/helpers/pump_app.dart`
- `test/routing/app_router_test.dart`

## Overview
Review `app_router_test.dart` for duplication and clarity. Apply minimal refactors (e.g., helper for router setup, reduce repeated assertions) without changing behavior. Ensure tests still cover redirect cases for `/gallery/viewer`.

## Key Insights
- Existing tests already cover valid/invalid extra cases and route paths.
- Repeated setup (`ProviderContainer`, overrides, `pumpAppWithRouter`) can be centralized in helper within the test file.
- Avoid behavior change; focus on readability and DRY.

## Requirements
### Functional
- Keep same test coverage for route path checks and viewer redirects.
- Preserve redirect behavior expectations (falls back to `GalleryPage` in invalid cases).

### Non-functional
- Minimal code churn (surgical edits only).
- Use existing helpers and patterns; no new test utilities unless necessary.

## Architecture
- No architecture changes. Only test refactor within `test/routing/app_router_test.dart`.

## Related Code Files
### Modify
- `test/routing/app_router_test.dart`

### Possibly modify
- `test/core/helpers/pump_app.dart` (only if small doc clarification or extra param needed)

### No new files

## Implementation Steps
1. Scan `app_router_test.dart` for duplicated setup and assertions.
2. Introduce a small local helper (inside test file) to build router + pump using `pumpAppWithRouter`.
3. Consolidate common expectations into helper(s) if it reduces duplication without hiding intent.
4. Keep test names and coverage intact; adjust only for clarity.
5. Ensure no new dependencies or additional helpers in other files unless unavoidable.

## Todo List
- [x] Identify duplication in router setup and redirects
- [x] Refactor using local helpers in test file
- [ ] Re-run tests for `app_router_test.dart`

## Success Criteria
- Tests remain green and cover same cases.
- `app_router_test.dart` reads simpler with less repetition.
- No changes to production routing behavior.

## Risk Assessment
- Risk: Over-refactor hides intent or changes timing. Mitigation: keep helpers minimal and explicit; verify with test run.

## Security Considerations
- None; test-only changes.

## Next Steps
- Phase 02: document `/gallery/viewer` constraints in routing docs (inline or comments).
