# Development Roadmap

**Project**: Artio - AI Image Generation SaaS
**Updated**: 2026-01-27 21:24
**Status**: Plan 1 Complete (Architecture Hardening) → Plan 2 Next

---

## Project Overview

**Artio** ("Art Made Simple") - Cross-platform AI image generation SaaS with dual generation modes:
- **Template Engine** (Home tab): Image-to-image with preset templates
- **Text-to-Image** (Create tab): Custom prompt generation

**Tech Stack**:
- Flutter (Android, iOS, Web)
- Riverpod + riverpod_generator + Freezed
- Supabase (auth, db, storage, edge functions, realtime)
- go_router with auth guards
- RevenueCat (mobile) + Stripe (web)
- KIE API (Google Imagen 4, Nano Banana)

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

**Documentation Standardization** (2h) - *2026-01-27*
- Standardized 8 phase files to 12-section template format
- Added Priority/Status/Effort blocks
- Converted Success Criteria to checkbox format
- Expanded Risk Assessment to 4-column tables

### 🔄 In Progress

None - awaiting Plan 2 execution.

### ⏸ Pending

**Plan 2: Credit, Premium & Rate Limit** (6h) - *NEXT*
- Database schema for credits/limits
- Edge Function enforcement
- Client-side credit UI with realtime sync
- Rate limiting & cooldown (5 daily for free)
- Premium hybrid sync (RevenueCat + Supabase)
- Input validation

**Phase 5: Gallery Feature** (4h)
- User gallery with pagination
- Image grid with cached_network_image
- Fullscreen viewer with hero animations
- Download/share functionality
- Delete with cascade to storage
- Pull-to-refresh

**Phase 6: Subscription & Credits** (8h)
- Subscription model (Free/Pro tiers)
- Credits system for free users
- RevenueCat integration (iOS/Android)
- Stripe integration (Web)
- Payment abstraction layer
- Rewarded ads (mobile)
- Real-time subscription sync

**Phase 7: Settings Feature** (3h)
- Theme mode switcher
- Account management (change password, delete account)
- Sign out
- About dialog with version info
- Offline-first settings persistence

**Phase 8: Admin App** (3h)
- Separate Flutter web app for template management
- Admin role enforcement via RLS
- Template CRUD interface
- Visual JSON editor for input fields
- Drag-to-reorder templates
- Deployment to admin.artio.app

**Phase 4.5: Architecture Hardening** (8.5h) - *Completed 2026-01-27*
- 3-layer clean architecture refactor (auth, template_engine)
- Repository DI with abstract interfaces
- Presentation/Domain/Data separation
- Dependency rule enforcement
- Error mapper implementation
- Constants extraction
- Dead code cleanup

---

## Milestones

### M1: MVP Core (Phases 1-3) - 14h
**Goal**: Working app with auth and navigation
**Deliverables**:
- [ ] Users can sign up/login
- [ ] App launches on iOS, Android, Web
- [ ] Theme switching works
- [ ] Router redirects based on auth state

**Target**: Week 1

---

### M2: Core Features (Phases 4-5) - 12h
**Goal**: Image generation and gallery
**Deliverables**:
- [x] Templates load from Supabase
- [x] Generation jobs track in realtime
- [ ] Users can view/download/delete generated images
- [ ] Infinite scroll gallery works

**Target**: Week 2
**Status**: 66% complete (Phase 4 done)

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
- [ ] Settings screen functional
- [ ] Admin can CRUD templates without code changes
- [ ] All Success Criteria from phases 7-8 met

**Target**: Week 4

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
| **Core Setup** | 0% | Pending (Phase 1-2) |
| **Authentication** | 0% | Pending (Phase 3) |
| **Generation Engine** | 100% | ✓ Complete (Phase 4) |
| **Architecture Quality** | 100% | ✓ Complete (Phase 4.6) |
| **User Features** | 0% | Pending (Phase 5, 7) |
| **Monetization** | 0% | Pending (Phase 6) |
| **Admin Tools** | 0% | Pending (Phase 8) |
| **Documentation** | 100% | ✓ Standardized (8 phase files) |

**Total Project**: 20% (13.5h / 48.5h total estimated)

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
| KIE API rate limits | High | Implement queue + backoff | Pending |
| RevenueCat web beta limitations | Medium | Use Stripe directly for web | Mitigated in plan |
| Cross-platform payment testing | High | Budget iOS/Android test devices | Pending |
| Supabase free tier limits | Medium | Monitor usage, upgrade early | Pending |
| Template content creation | Medium | MVP with 10 seed templates | Pending |

---

## Next Steps

### Immediate (This Week)
1. **Decision**: Choose execution path
   - Option A: Resume Phase 1 (bootstrap from scratch)
   - Option B: Continue from Phase 5 (assume 1-3 complete)
   - Option C: Prioritize Phase 6 (monetization first)

2. **If Phase 1**: Run `/cook phase-01-project-setup.md`
3. **If Phase 5**: Verify Phase 1-3 completion, then `/cook phase-05-gallery-feature.md`

### Short-term (Next 2 Weeks)
- Complete Phases 1-5 (M1 + M2)
- KIE API integration testing
- First production deploy to staging

### Long-term (Month 1-2)
- Phase 6-8 completion
- Marketing site launch
- Beta user onboarding
- App Store submissions

---

## Success Metrics

### Technical
- [ ] `flutter analyze` 0 errors
- [ ] All phase Success Criteria met
- [ ] 80%+ test coverage on business logic
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

---

## References

- **Bootstrap Plan**: `plans/260125-0120-artio-bootstrap/plan.md`
- **Phase Files**: `plans/260125-0120-artio-bootstrap/phase-*.md`
- **Standardization Report**: `plans/reports/cook-260127-1406-standardize-artio-phases-final.md`
- **Project Structure**: See Phase 1 Architecture section
