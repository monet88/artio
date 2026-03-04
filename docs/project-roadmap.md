# Project Roadmap

**Project**: Artio - AI Image Generation SaaS
**Updated**: 2026-03-04
**Status**: Phase 6 in progress (~90%); Phase 8 in progress (~85%); 12 post-phase milestones complete

---

## Project Overview

**Artio** ("Art Made Simple") - Cross-platform AI image generation SaaS with dual generation modes:
- **Template Engine** (Home tab): Image-to-image with preset templates
- **Text-to-Image** (Create tab): Custom prompt generation

**Tech Stack**:
- Flutter (Android, iOS, Web, Windows)
- Riverpod + riverpod_generator + Freezed
- Supabase (auth, db, storage, edge functions, realtime)
- go_router with auth guards
- RevenueCat (mobile) + Stripe (web)
- AI Providers: Kie (primary), Gemini (fallback)

---

## Current Status

### ✓ Completed

**Phase 1-3: Foundation** (14h)
- Project setup with Flutter + dependencies
- go_router with auth guards
- Theme system (light/dark/system)
- Supabase auth (email/password + OAuth)
- Session persistence

**Phase 4: Template Engine** (8h)
- Template model with Freezed/JSON serialization
- Generation job tracking with realtime updates
- Repository pattern with Supabase integration
- Template grid UI with category filtering
- Input field builder for dynamic template forms
- Generation progress tracking
- Edge Function skeleton (KIE integration pending)

**Phase 4.6 (Plan 1): Architecture Hardening** (8.5h) - *2026-01-27*
- 3-layer clean architecture (auth, template_engine features)
- Repository DI with Supabase constructor injection
- Error mapper for user-friendly messages (AppExceptionMapper)
- Code quality improvements (const linting enabled)
- Constants extraction (OAuth URLs, defaults, aspect ratios)
- Dead code removal (Dio, subscription placeholders)
- Tech debt addressed: H1, M2, M3, M5, M6, M8, L3, L4
- Grade: B+ → A- architecture
- **Results**: 80 files changed, 5117+ insertions, 267 deletions

**Content Update: 25 AI Templates** - *2026-01-28*
- Added 25 production-quality templates via SQL migration
- Categories: Portrait, Removal, Art Style, Enhancement, Creative
- 5 templates per category, all free tier

**Phase 5: Gallery Feature** (4h) - *Completed 2026-01-28*
- User gallery with pagination
- Masonry image grid
- Fullscreen viewer with hero animations
- Download/share functionality
- Pull-to-refresh
- **Results**: Fully functional gallery with Supabase realtime updates

**Phase 7: Settings Feature** (3h) - *Completed 2026-01-28*
- Theme mode switcher (persisted)
- Sign out functionality
- About dialog
- **Results**: Settings screen integrated with app shell

**E2E Testing Infrastructure** - *2026-01-28*
- Added `integration_test` package
- Created `template_e2e_test.dart`
- Configured Windows desktop test runner
- Repository tests for auth and template features
- **Test Coverage**: Needs verification (run `flutter test --coverage`)

**Phase 8: Admin App (Partial)** - *2026-01-28 to 2026-02-28*
- Created admin web app structure (11 source files)
- Admin auth with Supabase
- Template model and router setup
- Freezed/JSON deps configured
- **Remaining**: Production deployment/hardening

### 🔄 In Progress

**Phase 6: Subscription & Credits** (8h) - *IN PROGRESS (~90% complete)*
- ✓ Credits system for free users (`user_credits`, `deduct_credits`/`refund_credits`, Edge Function + UI handling complete)
- ✓ Premium-model gating (insufficient credit + premium sheets implemented)
- ✓ Rewarded ads with SSV (AdMob + `reward-ad` Edge Function)
- ✓ RevenueCat SDK initialized + user identity linked
- ✓ RevenueCat purchase/restore wiring (iOS/Android)
- ✓ RevenueCat webhook (subscription status sync + credit grant)
- ✓ Subscription tiers (Free/Pro/Ultra) with paywall UI
- Stripe integration (Web) - pending (final item)

**Phase 8: Admin App** (~0.5h remaining - ~85% complete)
- ✓ Separate Flutter web app for template management (22 Dart files)
- ✓ Admin role enforcement via RLS
- ✓ Template model and router setup
- ✓ Template CRUD UI (complete)
- ✓ Drag-to-reorder templates (complete)
- Production deployment/hardening (pending)

### ⏸ Pending

**Plan 2: Credit, Premium & Rate Limit** (6h) - *Merged into Phase 6*
- Database schema for credits/limits (complete)
- Edge Function enforcement (complete)
- Rate limiting & cooldown (implemented via `check_rate_limit`)

### ✓ Post-Phase Milestones (Complete)

The following milestones were completed after the initial phase plan:

| # | Milestone | Date | Key Deliverables |
|---|-----------|------|------------------|
| 1 | **Codebase Improvement** | 2026-02 | Large file refactoring, code quality |
| 2 | **Test Coverage & Prod Readiness** | 2026-02 | 651+ unit + 15 integration tests |
| 3 | **Widget Cleanup** | 2026-02 | Widget refactoring, UI polish |
| 4 | **Model Sync** | 2026-02 | 16 AI models, exact ID + cost validation |
| 5 | **Data Integrity & Performance** | 2026-02 | Database optimization, query tuning |
| 6 | **UI & Concurrency Polish** | 2026-02 | UI consistency, async flow improvements |
| 7 | **Edge Case Fixes 2** | 2026-02 | Error handling edge cases |
| 8 | **Edge Case Hardening** | 2026-02 | Defensive coding improvements |
| 9 | **Reward Ad SSV** | 2026-02 | AdMob rewarded ads + Edge Function SSV |
| 10 | **Edge Case Resilience** | 2026-02-20 | Init try-catch, SocketException/Timeout, select validation |
| 11 | **Supabase Security Audit** | 2026-03-04 | RLS policy fixes, function signature normalization, SECURITY DEFINER hardening, search_path enforcement |
| 12 | **RevenueCat Integration Fixes** | 2026-03-04 | 7 blocking bugs fixed, webhook handler, subscription sync, credit grant on purchase |

---

## Milestones

### M1: MVP Core (Phases 1-3) - 14h
**Goal**: Working app with auth and navigation
**Deliverables**:
- [x] Users can sign up/login
- [x] App launches on iOS, Android, Web, Windows
- [x] Theme switching works
- [x] Router redirects based on auth state

**Target**: Week 1
**Status**: ✓ Complete

---

### M2: Core Features (Phases 4-5) - 12h
**Goal**: Image generation and gallery
**Deliverables**:
- [x] Templates load from Supabase
- [x] Generation jobs track in realtime
- [x] Users can view/download/delete generated images
- [x] Infinite scroll gallery works

**Target**: Week 2
**Status**: ✓ Complete

---

### M3: Monetization (Phase 6) - 8h
**Goal**: Payment infrastructure
**Deliverables**:
- [ ] Free users see credit balance
- [ ] Subscription purchase works (iOS/Android/Web)
- [ ] Pro users have unlimited access
- [ ] Credits deduct on generation
- [ ] Rewarded ads work on mobile

**Target**: Week 3

---

### M4: Polish & Admin (Phases 7-8) - 6h
**Goal**: Production-ready UX and content management
**Deliverables**:
- [x] Settings screen functional
- [ ] Admin can CRUD templates without code changes
- [ ] All Success Criteria from phases 7-8 met

**Target**: Week 4
**Status**: ~85% complete (Phase 7 done, Phase 8 deployment pending)

---

### M5: Hardening (Phase 4.5/4.6) - 8.5h
**Goal**: Clean architecture compliance
**Deliverables**:
- [x] Auth and template_engine features follow 3-layer structure
- [x] Abstract repository interfaces in domain layer
- [x] Zero direct data layer imports in presentation
- [x] flutter analyze reports 0 errors
- [x] Error mapper for user-friendly messages
- [x] Constants extracted to core/constants

**Target**: Post-Phase 4
**Status**: ✓ Complete (2026-01-27)

---

## Progress Tracking

### Overall Completion

| Category | Progress | Status |
|----------|----------|--------|
| **Core Setup** | 100% | ✓ Complete (Phase 1-2) |
| **Authentication** | 100% | ✓ Complete (Phase 3) |
| **Generation Engine** | 100% | ✓ Complete (Phase 4) |
| **Architecture Quality** | 100% | ✓ Complete (Phase 4.6) |
| **User Features** | 100% | ✓ Complete (Phase 5, 7) |
| **Monetization** | ~90% | In Progress (Phase 6) - Credits + ads + RevenueCat done, Stripe web pending |
| **Admin Tools** | ~85% | In Progress (Phase 8) - CRUD + reorder done, deployment pending |
| **Security** | 100% | ✓ Complete (Supabase audit: RLS, SECURITY DEFINER, search_path) |
| **Post-Phase Quality** | 100% | ✓ Complete (12 milestones: testing, edge cases, resilience, security, RevenueCat) |
| **Documentation** | 100% | Current (2026-03-04 v1.7 refresh) |

**Total Project**: ~95% (core features + quality milestones + security audit complete)

---

## Dependencies

### Critical Path
1. Phase 1 (Setup) → **blocks all phases**
2. Phase 2 (Infrastructure) → **blocks Phase 3-8**
3. Phase 3 (Auth) → **blocks Phase 4-8** (auth-gated features)
4. Phase 4 (Template Engine) → **completed**
5. Phase 6 (Payments) → **blocks production launch**

### Parallel Execution Opportunities
- Phase 5 (Gallery) + Phase 7 (Settings) - independent features
- Phase 8 (Admin) - separate codebase, can start after Phase 2

---

## Risk Assessment

| Risk | Impact | Mitigation | Status |
|------|--------|------------|--------|
| Kie API rate limits | High | Implement queue + backoff | Pending |
| RevenueCat web beta limitations | Medium | Use Stripe directly for web | Mitigated in plan |
| Cross-platform payment testing | High | Budget iOS/Android test devices | Pending |
| Supabase free tier limits | Medium | Monitor usage, upgrade early | Monitoring |
| Template content creation | Medium | MVP with 25 seed templates | ✓ Complete |

---

## Next Steps

### Immediate
1. **Complete Phase 6**: Stripe web integration (final monetization item)
2. **Admin deployment**: Production hardening for admin app

### Pre-Release Checklist
- [ ] **AdMob production IDs**: Replace placeholder ad unit IDs in `lib/core/services/rewarded_ad_service.dart` with real IDs from AdMob dashboard (Android + iOS)
- [ ] **Privacy Policy URL**: Host privacy policy and update URL in `lib/features/settings/presentation/widgets/settings_sections.dart`
- [ ] **Terms of Service URL**: Host ToS and update URL in same file
- [ ] **Help & FAQ URL**: Host help centre and update URL in same file

### Short-term (Next 2 Weeks)
- Stripe web payments
- Admin app deployment
- Pre-release checklist items above
- Beta launch preparation
- Expand E2E test coverage

### Long-term (Month 1-2)
- App Store / Play Store submissions
- Marketing site launch
- Beta user onboarding

---

## Success Metrics

### Technical
- [x] `flutter analyze` 0 errors
- [ ] All phase Success Criteria met
- [ ] 80%+ test coverage on business logic (needs verification)
- [ ] <2s cold start time
- [ ] <500ms template grid load

### Product
- [ ] 100 beta users
- [ ] 5 subscription conversions
- [ ] <5% error rate in production
- [ ] 4.5+ app store rating

---

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2026-01-25 | 0.1 | Bootstrap plan created (8 phases) |
| 2026-01-27 | 0.2 | Phase 4 completed, docs standardized |
| 2026-01-27 | 0.3 | Phase 4.6 completed (architecture hardening) |
| 2026-01-28 | 1.0 | Phases 5 & 7 complete, 25 templates added |
| 2026-01-30 | 1.1 | Test coverage 80%+, Admin app 50%, documentation sync |
| 2026-02-03 | 1.1.1 | Fix TemplateDetailScreen listener lifecycle (tests) |
| 2026-02-10 | 1.2 | Documentation accuracy sync - updated file counts, schemas, navigation patterns |
| 2026-02-19 | 1.3 | Phase progress update (Phase 6: 50%, Phase 8: 70%), date refresh, metrics verification |
| 2026-02-20 | 1.4 | Tech Debt Cleanup (7 debts resolved, 651+15 tests) |
| 2026-02-20 | 1.5 | Edge Case Resilience (init try-catch, SocketException/Timeout), Reward Ad SSV, 10 post-phase milestones documented |
| 2026-02-28 | 1.6 | Renamed to project-roadmap.md, updated Phase 6 (~80%), Phase 8 (~85%), overall ~92% |
| 2026-03-04 | 1.7 | Supabase security audit + RevenueCat fixes, Phase 6 (~90%), 12 milestones, overall ~95% |

---

## References

- **Bootstrap Plan**: `plans/260125-0120-artio-bootstrap/plan.md`
- **Phase Files**: `plans/260125-0120-artio-bootstrap/phase-*.md`
- **Standardization Report**: `plans/reports/cook-260127-1406-standardize-artio-phases-final.md`
- **Project Structure**: See Phase 1 Architecture section

---

**Last Updated**: 2026-03-04
