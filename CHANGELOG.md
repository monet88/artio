# Changelog

All notable changes to this project will be documented in this file.

## [admin/1.1.0+2] - 2026-03-31

### Added
- **Revenue Tab**: New Revenue page in the admin dashboard — operators can now see recent
  subscription/purchase transactions, a 7-day daily revenue chart, and tier breakdown pie chart.
  Answers the key daily question: is the business working?
- **Navigation**: Revenue tab (index 5) added to the admin NavigationRail alongside
  Dashboard / Users / Jobs / Templates / Analytics.
- **Supabase**: Admin read policy for `credit_transactions` table + partial index on
  `(type, created_at)` WHERE type IN ('subscription', 'purchase') for fast 7-day window queries.

### Changed
- **File size compliance**: All 6 admin pages that exceeded the 300-line limit have been split
  into dedicated widget files. Template editor: 679→290, User detail: 610→170,
  Analytics: 466→182, Templates list: 418→271, Dashboard: 322→110, Users: 308→143.
- **Shared widgets**: `TierPieChart` extracted to `shared/widgets/` — reused by both
  Analytics and Revenue pages.
- **UTC fix**: `analyticsStatsProvider` now uses `.toUtc()` for all datetime boundaries,
  consistent with Supabase UTC storage (was using local time, causing off-by-one day errors
  for non-UTC timezones).

### Added (tests)
- 61 unit tests across analytics provider logic, revenue entity computed properties,
  and revenue provider aggregation logic. All tests cover UTC boundaries, null guards,
  divide-by-zero cases, and empty-state paths.

## [1.0.0+18] - 2026-03-27

### Added
- **Account Deletion**: Users can now permanently delete their account from Settings.
  Confirmation dialog warns about permanent data loss. Triggers `delete-account` edge
  function which removes all storage files (generated images + input images) and the
  auth user record via cascade. RevenueCat session cleared on success.

### Fixed
- `delete-account` edge function: add `verify_jwt = false` to `config.toml` — without
  this, Supabase gateway blocked all requests with 401 due to GoTrue v2 ES256/HS256
  mismatch (same pattern as `generate-image`)
- `delete-account` edge function: clear local Supabase session after successful deletion
  to prevent "ghost login" state on next app launch
- `delete-account` edge function: storage cleanup now covers `{userId}/inputs/`
  subdirectory in addition to top-level files, ensuring input images are also deleted
- `delete-account` edge function: fix pagination offset bug — always list at offset 0
  so files that shift after removal are not skipped
- Settings screen: change `on Exception` to `on Object` in delete account error handler
  so `AppException` (which extends `Object`, not `Exception`) is properly caught and
  shown as a user-friendly snackbar instead of a red error screen
