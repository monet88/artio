# TODO

## Technical Debt
- [ ] Replace test AdMob IDs with production IDs (`rewarded_ad_service.dart:10`) `high` — 2026-02-19
- [ ] KIE vs app model mismatch — Edge Function hardcodes certain model lists `medium` — 2026-02-19
- [ ] No caching layer — Templates and gallery fetched fresh each time `medium` — 2026-02-19
- [ ] Integration tests require real Supabase credentials `low` — 2026-02-19

## Completed
- [x] Extract `app_component_themes.dart` into smaller theme files — Widget Cleanup ✅
- [x] Extract `home_screen.dart` screen sub-widgets — Widget Cleanup ✅
- [x] Extract `create_screen.dart` form sections — Widget Cleanup ✅
- [x] Extract `register_screen.dart` form sections — Widget Cleanup ✅
- [x] Fix deprecated Riverpod Ref types — Code Health ✅
- [x] Fix admin web dart:io usage — Code Health ✅

## Future Milestones
- [ ] Stripe integration for web payments
- [ ] Priority generation queue for subscribers
- [ ] Credit history / transaction log UI
- [ ] Subscription management settings page
- [ ] Referral / affiliate system
