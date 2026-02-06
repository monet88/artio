# Development Roadmap

**Project**: Artio - AI Image Generation SaaS
**Updated**: 2026-02-03
**Status**: Phase 5, 7, 8 (partial) Complete → Phase 6 Next

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
- **Test Coverage**: 324 tests passing, 80%+ coverage achieved

**Phase 8: Admin App (Partial)** - *2026-01-28*
- Created admin web app structure (11 source files)
- Admin auth with Supabase
- Template model and router setup
- Freezed/JSON deps configured
- **Remaining**: Template CRUD UI, drag-to-reorder, deployment

### 🔄 In Progress

**Phase 8: Admin App** (remaining ~1.5h of 3h)
- Template CRUD UI
- Drag-to-reorder templates
- Deployment to admin.artio.app

### ⏸ Pending

**Phase 6: Subscription & Credits** (8h) - *NEXT*
- Subscription model (Free/Pro tiers)
- Credits system for free users
- RevenueCat integration (iOS/Android)
- Stripe integration (Web)
- Rewarded ads (mobile)

**Plan 2: Credit, Premium & Rate Limit** (6h) - *Merged into Phase 6*
- Database schema for credits/limits
- Edge Function enforcement
- Rate limiting & cooldown

**Phase 8: Admin App** (~1.5h remaining)
- ~~Separate Flutter web app for template management~~ ✓
- ~~Admin role enforcement via RLS~~ ✓
- Template CRUD interface (pending)
- Visual JSON editor for input fields (pending)
- Drag-to-reorder templates (pending)
- Deployment to admin.artio.app (pending)

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
**Status**: 70% complete (Phase 7 done, Phase 8 in progress)

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
| **Monetization** | 0% | Pending (Phase 6) |
| **Admin Tools** | 50% | In Progress (Phase 8) |
| **Documentation** | 100% | ✓ Standardized |

**Total Project**: 81% (39.5h / 48.5h total estimated)

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
1. **Execute Phase 6**: Implement Subscription & Credits system
   - Database schema setup
   - RevenueCat integration
   - Credit deduction logic

2. **Testing**:
   - Expand E2E test coverage to Auth flow
   - Verify all 25 templates generate correctly

### Short-term (Next 2 Weeks)
- Complete Monetization (Phase 6)
- Build Admin App (Phase 8)
- Prepare for Beta Launch

### Long-term (Month 1-2)
- Marketing site launch
- Beta user onboarding
- App Store submissions

---

## Success Metrics

### Technical
- [x] `flutter analyze` 0 errors
- [ ] All phase Success Criteria met
- [x] 80%+ test coverage on business logic (324 tests passing)
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

---

## References

- **Bootstrap Plan**: `plans/260125-0120-artio-bootstrap/plan.md`
- **Phase Files**: `plans/260125-0120-artio-bootstrap/phase-*.md`
- **Standardization Report**: `plans/reports/cook-260127-1406-standardize-artio-phases-final.md`
- **Project Structure**: See Phase 1 Architecture section

---

**Last Updated**: 2026-02-03
