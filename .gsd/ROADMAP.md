# ROADMAP.md

> **Current Milestone**: Data Integrity & Performance
> **Goal**: Sync model registry between app and Edge Function; add local data caching for templates and gallery

---

## Completed Milestones

### Edge Case Fixes (Phase 1) ✅
- DateTime parsing, concurrent sign-in guards, profile TOCTOU race, 429 retry, timeout, TLS retry, router notify, file error handling
- 5 plans, 8 tasks, 453 tests passing

### Freemium Monetization ✅
- Remove login wall, credit system, rewarded ads, RevenueCat subscriptions, premium gate, watermark
- 7 phases, 530 tests passing
- All must-haves delivered, PR #13 merged

### Codebase Improvement ✅
- CORS DRY, widget extraction, architecture violations, test coverage, analyzer warnings
- 5 phases, 9 plans, 606 tests passing
- All must-haves delivered, 0 deferrals

### Widget Cleanup ✅
- Theme & screen extraction: app_component_themes, home_screen, create_screen, register_screen
- 1 phase, flutter analyze clean, 606/606 tests passing

### Code Health ✅
- Admin web dependencies, dart:io fix, deprecated Ref types, flutter analyze clean
- 3 phases, PR #19

---

## Current Milestone: Data Integrity & Performance

### Must-Haves
- [ ] Model list in app (`ai_models.dart`) and Edge Function (`index.ts`) are 100% in sync
- [ ] All models in `MODEL_CREDIT_COSTS` have corresponding `AiModelConfig` entries
- [ ] All app models are correctly routed to the right provider (`kie` or `gemini`)
- [ ] Template list loads instantly from local cache on subsequent opens
- [ ] Gallery metadata cached locally for faster gallery loads
- [ ] `flutter analyze` remains clean (0 errors)

### Nice-to-Haves
- [ ] Cache invalidation strategy (TTL or stale-while-revalidate)
- [ ] Offline mode indicator when data is served from cache

### Phase 1: Model Registry Sync ✅
**Status**: ✅ Complete
**Objective**: Create single source of truth for AI models — sync app constants with Edge Function model lists and credit costs. Remove orphan models, add missing models, ensure `getProvider()` routing covers all models explicitly.

### Phase 2: Template Data Caching ✅
**Status**: ✅ Complete
**Objective**: Add local persistence for template data so template list loads instantly from cache with network refresh in background. Reduce Supabase API calls on app open.

### Phase 3: Gallery Data Caching
**Status**: ⬜ Not Started
**Objective**: Cache gallery metadata locally for faster gallery screen loads. Implement stale-while-revalidate pattern — show cached data immediately, refresh from network.

---

## Backlog

- [ ] Stripe integration for web payments
- [ ] Priority generation queue for subscribers
- [ ] Credit history / transaction log UI
- [ ] Subscription management settings page
- [ ] Referral / affiliate system
- [ ] Replace test AdMob IDs with production IDs (TODO in rewarded_ad_service.dart)
