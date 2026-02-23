# TODO

## Technical Debt (Resolved)
- [x] Edge Function unit tests — model config pure functions ✅
- [x] PREMIUM_MODELS sync — fixed 3 drift mismatches ✅
- [x] Verify `_shared/` module works with `supabase functions deploy` ✅
- [x] Cross-language model count assertion (Dart test: AiModels.all.length == 16) ✅
- [x] Widget tests for reduced-motion behavior ✅
- [x] Add Sentry breadcrumb/tag for `isPremium` in TemplateDetailScreen ✅
- [x] `credit_logic.ts` — `any` → `SupabaseClient` type ✅
- [x] Storage TTL cleanup — `input_image_paths` column + deleteJob cleanup ✅
- [x] MIME type detection in `ImageUploadService` ✅

## Notes (handle manually at production)
- AdMob placeholder IDs → production IDs
- Sentry alert rule setup
- Deno type-check CI step
- RevenueCat Dashboard setup checklist (`docs/revenuecat-checklist.md`)

## Backlog — Features
- [ ] Stripe integration for web payments
- [ ] Priority generation queue for subscribers
- [ ] Credit history / transaction log UI
- [ ] Subscription management settings page
- [ ] Referral / affiliate system
