# Development Roadmap

**Project**: Artio - AI Art Generation App
**Last Updated**: 2026-01-27
**Current Phase**: Plan 0.5 Complete → Plan 1 Next

---

## Execution Order

| # | Plan | Status | Effort | Priority |
|---|------|--------|--------|----------|
| 0 | [Artio Bootstrap](#plan-0-artio-bootstrap-foundation) | ✅ Phase 1-4 Done | 40h | P0 |
| 0.5 | [Documentation Standardization](#plan-05-documentation-standardization) | ✅ Complete | 2h | P1 |
| 1 | [Architecture Hardening](#plan-1-architecture-hardening) | 🔲 Pending | 10h | P1 |
| 2 | [Credit, Premium & Rate Limit](#plan-2-credit-premium--rate-limit) | 🔲 Pending | 6h | P1 |
| 3 | [TypedGoRoute Migration](#plan-3-typedgoroute-migration) | ⏸️ Deferred | 4h | P2 |

---

## Plan 0: Artio Bootstrap (Foundation)

**Path**: `plans/260125-0120-artio-bootstrap/`
**Status**: ✅ Phase 1-4 Complete
**Effort**: 40h
**Branch**: `master`

### Objective
Bootstrap Flutter AI art generation app with core infrastructure.

### Phases

| Phase | Focus | Effort | Status |
|-------|-------|--------|--------|
| 1 | Project Setup | 3h | ✅ |
| 2 | Core Infrastructure | 6h | ✅ |
| 3 | Auth Feature | 5h | ✅ |
| 4 | Template Engine | 8h | ✅ |
| 5 | Gallery Feature | 4h | 🔲 |
| 6 | Subscription & Credits | 8h | 🔲 |
| 7 | Settings Feature | 3h | 🔲 |
| 8 | Admin App | 3h | 🔲 |

### Remaining Work
- Phase 5-8 will be executed after Architecture Hardening & Credit system
- Gallery depends on working generation flow
- Subscription depends on credit system (Plan 2)

---

## Plan 0.5: Documentation Standardization

**Path**: `plans/260127-1336-standardize-artio-bootstrap-phases/`
**Status**: ✅ Complete
**Effort**: 2h
**Branch**: `master`
**Completed**: 2026-01-27

### Objective
Standardize 8 phase files in Plan 0 to production-ready template format.

### What Was Done
- ✅ Added Priority/Status/Effort blocks to all Overview sections
- ✅ Converted Success Criteria to checkbox format (8/8 files)
- ✅ Expanded Risk Assessment to 4-column tables (Risk/Likelihood/Impact/Mitigation)
- ✅ Standardized Related Code Files structure (Create/Modify/Delete subsections)
- ✅ Merged domain-specific sections (AI Models → Architecture, Supabase Schema → Database subsection)
- ✅ Achieved strict 12-section compliance (all 8 files)

### Sections Template
All phase files now follow this structure:
1. Context Links
2. Overview (with Priority/Status/Effort)
3. Key Insights
4. Requirements
5. Architecture
6. Related Code Files
7. Implementation Steps
8. Todo List
9. Success Criteria (checkboxes)
10. Risk Assessment (4 columns)
11. Security Considerations
12. Next Steps

### Success Criteria
- [x] All 8 phase files have 12 standard sections
- [x] Section order matches reference template
- [x] Success Criteria uses `[ ]` checkbox format
- [x] Risk Assessment uses 4-column table format
- [x] No existing content removed (100% preservation)
- [x] Format consistent across all phases

### Reports
- `plans/reports/cook-260127-1406-standardize-artio-phases-final.md`



## Plan 1: Architecture Hardening

**Path**: `plans/260125-1516-phase46-architecture-hardening/`
**Status**: 🔲 Pending
**Effort**: 10h
**Branch**: `master`

### Objective
Elevate codebase from B+ to A-grade. Fix 12/15 tech debt issues.

### Phases

| Phase | Focus | Effort | Status |
|-------|-------|--------|--------|
| 1 | 3-Layer Architecture Restructure | 4h | 🔲 |
| 2 | Repository Dependency Injection | 1h | 🔲 |
| 3 | Error Message Mapper | 1.5h | 🔲 |
| 4 | Code Quality & Linting | 1.5h | 🔲 |
| 5 | Constants Extraction | 1h | 🔲 |
| 6 | Dead Code & Cleanup | 1h | 🔲 |

### Key Changes
- Restructure features to `domain/data/presentation`
- Inject SupabaseClient via constructor
- Centralize error message mapping
- Enable `prefer_const_constructors` lint
- Extract hardcoded values to constants
- Remove dead code (Dio, subscription feature)

### Success Criteria
- [ ] All features follow 3-layer structure
- [ ] Repositories injectable via constructor
- [ ] `flutter analyze` clean
- [ ] All tests pass

---

## Plan 2: Credit, Premium & Rate Limit

**Path**: `plans/260125-1517-credit-premium-rate-limit/`
**Status**: 🔲 Pending
**Effort**: 6h
**Branch**: `master`
**Depends on**: Plan 1 complete

### Objective
Implement calculated credit availability, hybrid premium sync, defense-in-depth rate limiting.

### Phases

| Phase | Focus | Effort | Status |
|-------|-------|--------|--------|
| 1 | Database & Edge Function | 1.5h | 🔲 |
| 2 | Credit Availability System | 1.5h | 🔲 |
| 3 | Rate Limiting & Cooldown | 1h | 🔲 |
| 4 | Premium Hybrid Sync | 1.5h | 🔲 |
| 5 | Input Validation | 0.5h | 🔲 |

### Key Changes
- Add daily generation count index
- Edge Function enforces daily limit (5 for free)
- Client-side credit availability UI
- Button cooldown prevents double-tap
- RevenueCat + Supabase Realtime for premium sync
- Input length validation

### Success Criteria
- [ ] Zero credit desync errors
- [ ] Premium unlock < 1s latency
- [ ] No duplicate generation requests
- [ ] Rate limit bypass blocked

---

## Plan 3: TypedGoRoute Migration

**Path**: TBD
**Status**: ⏸️ Deferred
**Effort**: 4h
**Priority**: P2
**Blocked by**: `go_router_builder` compatibility with `go_router: ^14.8.1`

### Objective
Migrate from raw path strings to type-safe navigation.

### Key Changes
- Add `@TypedGoRoute` annotations
- Create `GoRouteData` subclasses
- Replace `context.go('/path')` with `MyRoute().go(context)`
- Generate typed routes via build_runner

### When to Execute
- After Plans 1 & 2 stable
- When `go_router_builder` releases compatible version
- When adding significant new routes

---

## Quick Reference

### Commands

```bash
# Verify after each change
flutter test && flutter analyze

# Regenerate code
dart run build_runner build --delete-conflicting-outputs

# Check current status
git status
```

### File Locations

| Resource | Path |
|----------|------|
| Plan 0 | `plans/260125-0120-artio-bootstrap/` |
| Plan 0.5 | `plans/260127-1336-standardize-artio-bootstrap-phases/` |
| Plan 1 | `plans/260125-1516-phase46-architecture-hardening/` |
| Plan 2 | `plans/260125-1517-credit-premium-rate-limit/` |
| Tech Debt Audit | `plans/reports/flutter-expert-260125-1548-tech-debt-audit.md` |
| Standardization Report | `plans/reports/cook-260127-1406-standardize-artio-phases-final.md` |
| Development Roadmap (Detailed) | `docs/development-roadmap.md` |
| This Roadmap | `ROADMAP.md` |

---

## Legend

| Symbol | Meaning |
|--------|---------|
| 🔲 | Pending |
| 🔄 | In Progress |
| ✅ | Complete |
| ⏸️ | Blocked/Deferred |
