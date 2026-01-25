---
title: "Phase 4.6: Architecture Hardening & Code Quality"
description: "Migrate to 3-layer clean architecture, add repository DI, improve error UX, enable const lints, extract constants"
status: pending
priority: P1
effort: 10h
branch: master
tags: [architecture, clean-code, refactoring, dx]
created: 2026-01-25
updated: 2026-01-25
audit_ref: "../reports/flutter-expert-260125-1548-tech-debt-audit.md"
---

# Phase 4.6: Architecture Hardening & Code Quality

## Objective

Elevate codebase from B+ to A-grade per Tech Debt Audit (15 issues: 3H, 8M, 4L).

## Phases Overview

| Phase | Focus | Effort | Status | Issues Addressed |
|-------|-------|--------|--------|------------------|
| [Phase 1](phase-01-three-layer-restructure.md) | 3-Layer Architecture Restructure | 4h | pending | H1, M6 |
| [Phase 2](phase-02-repository-di.md) | Repository Dependency Injection | 1h | pending | M5 |
| [Phase 3](phase-03-error-mapper.md) | Error Message Mapper | 1.5h | pending | - |
| [Phase 4](phase-04-code-quality.md) | Code Quality & Linting | 1.5h | pending | M4 |
| [Phase 5](phase-05-constants-extraction.md) | Constants Extraction | 1h | pending | M2, M3, M8 |
| [Phase 6](phase-06-cleanup.md) | Dead Code & Cleanup | 1h | pending | L3, L4, M1 |

## Tech Debt Coverage

| Issue | Severity | Description | Phase |
|-------|----------|-------------|-------|
| H1 | Critical | Feature structure violates Clean Architecture | Phase 1 |
| H2 | Critical | GoRouter uses raw path strings | DEFERRED |
| H3 | Critical | Navigation uses raw string paths | DEFERRED |
| M1 | Medium | Empty features (create, gallery, settings) | Phase 6 |
| M2 | Medium | Hardcoded OAuth redirect URLs | Phase 5 |
| M3 | Medium | Hardcoded defaults in profile creation | Phase 5 |
| M4 | Medium | `var` usage (justified - reassignment) | Phase 4 |
| M5 | Medium | Supabase client not injected | Phase 2 |
| M6 | Medium | DTO leakage in domain models | Phase 1 |
| M7 | Medium | Theme provider async race condition | Phase 6 |
| M8 | Medium | Aspect ratio options hardcoded in UI | Phase 5 |
| L1 | Low | Deprecated Riverpod annotations | Monitor |
| L2 | Low | Missing const on ErrorPage | Phase 4 |
| L3 | Low | Subscription feature empty | Phase 6 |
| L4 | Low | Unused Dio client | Phase 6 |

## Scope

**Features to restructure:**
- `template_engine` - 3 repos, 3 models
- `auth` - 1 repo, 1 model

**Naming convention verified:**
- Project uses `*_screen.dart` (not `*_page.dart`)
- Keep `presentation/screens/` folder naming

**Out of scope (tech debt - separate plan):**
- TypedGoRoute migration (H2, H3) - blocked by go_router_builder compatibility
- Requires separate plan due to scope

## Known Tech Debt (Pragmatic Trade-offs)

These are acknowledged impurities kept for scope management:

| Item | Description | Future Fix |
|------|-------------|------------|
| DTO Leakage | Models in `domain/entities/` use `freezed` + `json_serializable` (fromJson/toJson). Domain layer technically impure. | Split to `UserEntity` (Domain) + `UserDto` (Data) + mapper when app scales |
| DataSource Skip | Repositories call Supabase directly (no DataSource layer). Couples repos to backend implementation. | Add DataSource layer if need to swap backends |
| Sealed Class JSON | `AppException` sealed class works but relies on pattern matching at boundaries | Keep as-is, sealed provides exhaustive checking |

## Execution Rules

⚠️ **CRITICAL: Run after EVERY step:**
```bash
flutter test
flutter analyze
```

High-risk phases (1 & 2) can break imports and DI wiring. Frequent testing catches issues early.

## Success Criteria

- [ ] All features follow `domain/data/presentation` structure
- [ ] Repositories injectable via constructor
- [ ] Error UI shows user-friendly messages
- [ ] `prefer_const_constructors` lint enabled with 0 violations
- [ ] Constants extracted to `lib/core/constants/`
- [ ] Dead code removed (subscription, Dio if unused)
- [ ] Theme loading race condition fixed
- [ ] All tests pass
- [ ] `flutter analyze` clean

## Dependencies

- Existing `AppException` hierarchy (no changes needed)
- Riverpod provider pattern established
- Freezed models in place

## Risks

| Risk | Mitigation |
|------|------------|
| Import breaks during restructure | Run `flutter analyze` after each file move |
| Generated files stale | Run `dart run build_runner build` after restructure |
| Provider references break | Search/replace provider imports systematically |
| Theme race condition hard to fix | Consider FutureProvider or splash screen delay |
