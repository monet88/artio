# Changelog

All notable changes to this project will be documented in this file.

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
