---
title: "Routing tests review + gallery viewer constraints"
description: "Review routing tests, minor refactor for clarity, document /gallery/viewer constraints."
status: complete
priority: P2
effort: 3h
branch: chore/project-optimization
tags: [routing, tests, docs]
created: 2026-02-03
---

## Scope
- Review routing tests and apply minimal refactor for clarity/DRY.
- Document constraints for `/gallery/viewer` route in code docs.
- No behavior changes beyond docs/test refactor.

## Phases
1. [Phase 01: Review/refactor routing tests](phase-01-review-routing-tests.md) — status: complete
2. [Phase 02: Document gallery viewer constraints](phase-02-document-gallery-viewer-constraints.md) — status: complete

## Dependencies
- Existing GoRouter typed routes in `lib/routing/routes/app_routes.dart`.
- Test helpers in `test/core/helpers/pump_app.dart`.

## Verification (required)
- `lsp_diagnostics` on touched files.
- `flutter test test/routing/app_router_test.dart`.

## Notes
- `set-active-plan.cjs` failed due to missing module; retry if tooling fixed.
- Completed: routing test refactor + gallery viewer constraints docs.
