# TODO

## Technical Debt
- [ ] Replace test AdMob IDs with production IDs (`rewarded_ad_service.dart:10`) `high` — 2026-02-19 *(production only)*
- [x] Edge Function unit tests — model config pure functions `medium` — 2026-02-20 ✅
- [x] PREMIUM_MODELS sync — fixed 3 drift mismatches, cross-ref comments added `medium` — 2026-02-20 ✅
- [ ] Deno type-check CI step for Edge Functions `low` — 2026-02-20 *(production only)*
- [ ] Sentry alert rule for `[CRITICAL] Credit refund failed` log pattern `low` — 2026-02-20 *(production only)*
- [x] Verify `_shared/` module works with `supabase functions deploy` `medium` — 2026-02-20 ✅
- [x] Cross-language model count assertion (Dart test: AiModels.all.length == 16) `low` — 2026-02-20 ✅
- [ ] Complete RevenueCat Dashboard setup checklist (see `docs/revenuecat-checklist.md`) `high` — 2026-02-20
- [x] Widget tests for reduced-motion behavior (`loading_state_widget`, `error_state_widget`, `splash_screen`) `low` — 2026-02-21 ✅
- [x] Add Sentry breadcrumb/tag for `isPremium` in TemplateDetailScreen to monitor post-deploy `low` — 2026-02-21 ✅
- [ ] Refactor `InputFieldModel.type` from String to enum + add conditional validation for options/min/max `low` — 2026-02-21 *(long-term refactor)*
- [ ] Document: `image_viewer_page_test` uses `pump(4s)` intentionally — timer-based, `pumpAndSettle` would timeout `low` — 2026-02-21 *(confirmed intentional)*

## Completed
- [x] Extract `app_component_themes.dart` into smaller theme files — Widget Cleanup ✅
- [x] Extract `home_screen.dart` screen sub-widgets — Widget Cleanup ✅
- [x] Extract `create_screen.dart` form sections — Widget Cleanup ✅
- [x] Extract `register_screen.dart` form sections — Widget Cleanup ✅
- [x] Fix deprecated Riverpod Ref types — Code Health ✅
- [x] Fix admin web dart:io usage — Code Health ✅
- [x] KIE vs app model mismatch — Phase 1: Model Registry Sync ✅
- [x] No caching layer — Phase 2 (Templates) + Phase 3 (Gallery) ✅

## Backlog — Features
- [ ] Stripe integration for web payments `high` — 2026-02-20
- [ ] Priority generation queue for subscribers `medium` — 2026-02-20
- [ ] Credit history / transaction log UI `medium` — 2026-02-20
- [ ] Subscription management settings page `medium` — 2026-02-20
- [ ] Referral / affiliate system `low` — 2026-02-20
- [ ] Storage lifecycle policy — auto-delete generated images after X days to save storage costs `low` — 2026-02-21
