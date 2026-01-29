---
title: "Code Review Fixes - 17 Verified Issues"
description: "Fix security vulnerabilities, cleanup sensitive data, improve code quality across 11 parallel-optimized phases"
status: pending
priority: P1
effort: 6h
branch: master
tags: [security, cleanup, code-quality, tests]
created: 2026-01-29
---

# Code Review Fixes Implementation Plan

## Dependency Graph

```
Group A (Security)     Group B (Cleanup)      Group C (Flutter)       Group D        Group E (Tests)
[Phase 01] ----+       [Phase 03] ----+       [Phase 05] ----+       [Phase 09]     [Phase 10]
               |                      |                      |       (anytime)              |
[Phase 02] ----+-----> [Phase 04] ----+-----> [Phase 06] ----+                     [Phase 11]
                                              [Phase 07] ----+
                                              [Phase 08] ----+
```

## Parallel Execution Groups

| Group | Phases | Can Start After | Est. Time |
|-------|--------|-----------------|-----------|
| A (Security) | 01, 02 | Immediately | 45min |
| B (Cleanup) | 03, 04 | Group A | 30min |
| C (Flutter) | 05, 06, 07, 08 | Group B | 2h |
| D (Docs) | 09 | Anytime | 15min |
| E (Tests) | 10, 11 | Group C | 2h |

## File Ownership Matrix

| Phase | Exclusive Files |
|-------|-----------------|
| 01 | `supabase/functions/generate-image/index.ts` |
| 02 | `integration_test/template_e2e_test.dart`, `.env.test.example` |
| 03 | `.gitignore`, `repomix-output.xml`, `supabase/migrations/20260128094706_create_admin_user.sql` |
| 04 | `admin/analysis_options.yaml` |
| 05 | `lib/features/auth/domain/entities/user_model.dart`, `lib/features/settings/ui/settings_screen.dart`, `lib/features/auth/presentation/view_models/auth_view_model.dart` |
| 06 | `lib/features/template_engine/presentation/screens/template_detail_screen.dart`, `lib/features/template_engine/presentation/widgets/input_field_builder.dart`, `lib/features/template_engine/domain/entities/input_field_model.dart` |
| 07 | `lib/features/gallery/presentation/pages/image_viewer_page.dart` |
| 08 | `admin/lib/features/templates/presentation/pages/templates_page.dart`, `admin/lib/features/templates/domain/entities/admin_template_model.dart`, `admin/lib/features/templates/presentation/widgets/template_card.dart` |
| 09 | `docs/gemini/image-generation.md` |
| 10 | `test/features/template_engine/data/repositories/*_repository_test.dart` |
| 11 | SKIP - No CI configuration found |

## Phase Status

- [ ] [Phase 01: Security - Edge Function IDOR Fix](./phase-01-security-edge-function-idor.md)
- [ ] [Phase 02: Security - Test Credentials Cleanup](./phase-02-security-test-credentials.md)
- [ ] [Phase 03: Repository Hygiene](./phase-03-repository-hygiene.md)
- [ ] [Phase 04: Admin Project Sync](./phase-04-admin-project-sync.md)
- [ ] [Phase 05: Flutter Code Quality - Auth & Settings](./phase-05-flutter-auth-settings.md)
- [ ] [Phase 06: Flutter Code Quality - Template Engine](./phase-06-flutter-template-engine.md)
- [ ] [Phase 07: Flutter Code Quality - Gallery](./phase-07-flutter-gallery.md)
- [ ] [Phase 08: Admin Type Safety](./phase-08-admin-type-safety.md)
- [ ] [Phase 09: Documentation Fixes](./phase-09-documentation-fixes.md)
- [ ] [Phase 10: Test Rewrites](./phase-10-test-rewrites.md)
- [ ] [Phase 11: CI Verification](./phase-11-ci-verification.md)

## Validation Summary

**Validated:** 2026-01-29
**Questions asked:** 6

### Confirmed Decisions

| Decision | User Choice |
|----------|-------------|
| IDOR backward compatibility | Keep userId optional, validate if present |
| Auth layer abstraction | Add resetPassword() and signOut() to AuthViewModel |
| Testing approach | Unit tests with mocked SupabaseClient |
| Edge Function deployment | Deploy to production immediately |
| Build runner timing | Run once after Group C completes |
| Commit strategy | One commit per parallel group |

### Implementation Notes

- Phase 01: Accept userId in request body for backward compat, but ignore it - always use JWT
- Phase 05: Must add 2 new methods to AuthViewModel before updating settings_screen
- Phases 05-08: Run `dart run build_runner build` once after all complete
- Commits: 5 commits total (Group A, B, C, D, E)
