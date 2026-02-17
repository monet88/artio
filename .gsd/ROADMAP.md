# Roadmap

> Derived from verified brainstorm: `artifacts/superpowers/brainstorm.md`
> Discovery Level: 0 (Skip) — all fixes follow established patterns, no new dependencies

## Phase 1: Edge Case Fixes
**Priority:** Critical — user-facing bugs (crashes, race conditions, infinite loading)
**Source:** `plans/260217-1648-fix-edge-cases/` (with corrections from brainstorm)
**Status:** PLANNED

Fixes:
1. DateTime parsing crash (`gallery_repository.dart:63,67`)
2. Concurrent sign-in double-submit (no guard in auth methods)
3. Profile creation TOCTOU race condition (no 23505 handling)
4. 429 rate limit not retried (wrong exception type at 2 locations)
5. No timeout on Edge Function calls
6. TLS errors not retried (missing HandshakeException)
7. `_notifyRouter()` missing in 2 code paths
8. `writeAsBytes` no error handling (FileSystemException → wrong AppException type)

**Corrections applied:**
- Timeout: 90s (not 30s — generation takes 30-120s)
- Fix BOTH 429 paths (line 47 AND 70 in generation_repository.dart)
- Drop fake `_hasEnoughSpace()` — keep error classification + cleanup only
- `AppException.storage` confirmed to exist (Serena verified)

## Phase 2: Codebase Improvement
**Priority:** High — maintainability, not user-facing
**Source:** `plans/260217-1647-codebase-improvement/` (with corrections from brainstorm)
**Status:** PENDING (after Phase 1)

Fixes:
1. CORS `*` wildcard in Edge Function
2. Widget extraction (files >200 lines, only extract widgets >50 lines)
3. Architecture violations (2 of 3 — `auth_view_model` is false positive)
4. Test coverage improvement

**Corrections applied:**
- Remove `auth_view_model.dart` from arch violations (Riverpod convention, Serena confirmed)
- Reduce widget extraction from 16 to ~8-10 files (skip trivially small widgets)
- Merge test coverage phase with Phase 1 testing

## Dependencies

```
Phase 1 (Edge Cases) ──► Phase 2 (Codebase Improvement)
```

Phase 2 depends on Phase 1 because:
- Both touch `generation_repository.dart` and `gallery_repository.dart`
- Edge case fixes must be stable before refactoring
