# TODOs - Execution Order

**Last Updated**: 2026-01-27 21:24
**Current**: Plan 1 Complete → Plan 2 Next

---

## Execution Queue

### 1. ✅ Plan 0: Artio Bootstrap (Foundation)
**Path**: `plans/260125-0120-artio-bootstrap/`
**Status**: Phase 1-4 Complete (Phase 5-8 deferred)
**Effort**: 40h total

- [x] Phase 1: Project Setup (3h)
- [x] Phase 2: Core Infrastructure (6h)
- [x] Phase 3: Auth Feature (5h)
- [x] Phase 4: Template Engine (8h)
- [ ] Phase 5: Gallery Feature (4h) - *deferred*
- [ ] Phase 6: Subscription & Credits (8h) - *deferred*
- [ ] Phase 7: Settings Feature (3h) - *deferred*
- [ ] Phase 8: Admin App (3h) - *deferred*

---

### 2. ✅ Plan 0.5: Documentation Standardization
**Path**: `plans/260127-1336-standardize-artio-bootstrap-phases/`
**Status**: Complete
**Effort**: 2h

- [x] Standardize 8 phase files to 12-section template
- [x] Add Priority/Status/Effort blocks
- [x] Convert Success Criteria to checkboxes
- [x] Expand Risk Assessment to 4 columns
- [x] Update ROADMAP.md

---

### 3. ✅ Plan 1: Architecture Hardening
**Path**: `plans/260125-1516-phase46-architecture-hardening/`
**Status**: Complete (2026-01-27)
**Effort**: 8.5h (actual) / 10h (planned)
**Priority**: P1

**Phases**:
- [x] Phase 1: 3-Layer Architecture Restructure (4h)
  - Restructure `template_engine` + `auth` to `domain/data/presentation`
  - Create abstract repository interfaces
- [x] Phase 2: Repository Dependency Injection (1h)
  - Inject SupabaseClient via constructor
- [x] Phase 3: Error Message Mapper (1.5h)
  - Centralize error message mapping
- [x] Phase 4: Code Quality & Linting (1.5h)
  - Enable `prefer_const_constructors`
- [x] Phase 5: Constants Extraction (1h)
  - Extract hardcoded values
- [x] Phase 6: Dead Code & Cleanup (1h)
  - Remove Dio, unused subscription code

**Success Criteria**:
- [x] All features follow 3-layer structure
- [x] Repositories injectable via constructor
- [x] `flutter analyze` clean
- [x] All tests pass

**Results**:
- 80 files changed, 5117 insertions(+), 267 deletions(-)
- Grade: B+ → A- architecture
- Tech debt resolved: H1, M2, M3, M5, M6, M8, L3, L4

---

### 4. 🔲 Plan 2: Credit, Premium & Rate Limit
**Path**: `plans/260125-1517-credit-premium-rate-limit/`
**Status**: Pending
**Effort**: 6h
**Priority**: P1 - Execute NEXT
**Depends on**: Plan 1 complete ✓

**Phases**:
- [ ] Phase 1: Database & Edge Function (1.5h)
  - Add daily generation count index
  - Edge Function enforces limits
- [ ] Phase 2: Credit Availability System (1.5h)
  - Client-side credit UI
  - Real-time credit sync
- [ ] Phase 3: Rate Limiting & Cooldown (1h)
  - Button cooldown (prevent double-tap)
  - Daily limit: 5 for free users
- [ ] Phase 4: Premium Hybrid Sync (1.5h)
  - RevenueCat + Supabase Realtime
  - Premium unlock <1s latency
- [ ] Phase 5: Input Validation (0.5h)
  - Input length validation

**Success Criteria**:
- [ ] Zero credit desync errors
- [ ] Premium unlock <1s latency
- [ ] No duplicate generation requests
- [ ] Rate limit bypass blocked

---

### 5. 🔲 Plan 0 (Resumed): Bootstrap Phases 5-8
**Path**: `plans/260125-0120-artio-bootstrap/`
**Status**: Pending
**Effort**: 18h
**Depends on**: Plan 1-2 complete

**Phases**:
- [ ] Phase 5: Gallery Feature (4h)
  - User gallery with pagination
  - Download/share/delete
- [ ] Phase 6: Subscription & Credits (8h)
  - RevenueCat + Stripe integration
  - Payment abstraction layer
  - Rewarded ads (mobile)
- [ ] Phase 7: Settings Feature (3h)
  - Theme switcher
  - Account management
- [ ] Phase 8: Admin App (3h)
  - Separate Flutter web app
  - Template CRUD interface

---

### 6. ⏸️ Plan 3: TypedGoRoute Migration
**Path**: TBD
**Status**: Deferred
**Effort**: 4h
**Priority**: P2
**Blocked by**: `go_router_builder` compatibility

**When to execute**:
- After Plans 1-2 stable
- When `go_router_builder` releases compatible version
- When adding significant new routes

---

## Quick Commands

```bash
# Execute Plan 2
/cook plans/260125-1517-credit-premium-rate-limit/

# Resume Plan 0 (Phases 5-8)
/cook plans/260125-0120-artio-bootstrap/phase-05-gallery-feature.md
```

---

## Progress Summary

| Plan | Status | Progress | Time |
|------|--------|----------|------|
| Plan 0 | Partial | 50% (Phase 1-4) | 22h / 40h |
| Plan 0.5 | ✅ Complete | 100% | 2h / 2h |
| Plan 1 | ✅ Complete | 100% | 8.5h / 10h |
| Plan 2 | Pending | 0% | 0h / 6h |
| Plan 0 (cont.) | Pending | 0% | 0h / 18h |
| Plan 3 | Deferred | 0% | 0h / 4h |

**Total Progress**: 32.5h / 80h (41%)

---

## Legend

- ✅ Complete
- 🔲 Pending
- 🔄 In Progress
- ⏸️ Blocked/Deferred
