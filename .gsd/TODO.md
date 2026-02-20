# TODO

## Technical Debt
- [ ] Replace test AdMob IDs with production IDs (`rewarded_ad_service.dart:10`) `high` — 2026-02-19
- [ ] Edge Function integration tests — refund retry + premium enforcement `medium` — 2026-02-20
- [ ] PREMIUM_MODELS sync — shared source of truth between `ai_models.dart` and `index.ts` `medium` — 2026-02-20
- [ ] Deno type-check CI step for Edge Functions `low` — 2026-02-20
- [ ] Sentry alert rule for `[CRITICAL] Credit refund failed` log pattern `low` — 2026-02-20

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
