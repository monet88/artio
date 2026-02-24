# Artio Admin Dashboard

Flutter Web admin app for managing templates used by the main Artio app.

> Last updated: 2026-02-23 (synced to current `/admin` codebase)

## Purpose

- Admin-only login
- Dashboard stats overview
- Template management (create, edit, delete, reorder)
- Fast content updates without redeploying the main app

## Current Features

- Auth guard with role validation:
  - Login uses Supabase Auth (email/password)
  - After login, user must have `profiles.role = 'admin'`
  - Non-admin users are signed out immediately
- Dashboard (`/dashboard`):
  - Total templates, active templates, premium templates, category count
  - Recently updated templates list
- Templates page (`/templates`):
  - Search by name/description
  - Category, premium, and inactive filters
  - Reorder via drag-and-drop (persists `order` in DB)
  - Delete template
- Template editor (`/templates/new`, `/templates/:id`):
  - Create/edit template metadata
  - JSON input field configuration
  - Premium and active toggles
  - Default aspect ratio selection

## Project Structure

```text
admin/
  lib/
    core/
      router/
      shell/
      theme/
    features/
      auth/
      dashboard/
      templates/
    shared/
  web/
  pubspec.yaml
```

## Environment Setup

Create `admin/.env`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Run

```bash
cd admin
flutter pub get
flutter run -d chrome
```

## Build

```bash
cd admin
flutter build web
```

## Code Generation

This admin app uses Riverpod codegen and Freezed.

```bash
cd admin
dart run build_runner build --delete-conflicting-outputs
```

## Tech Stack

- Flutter + Dart
- Riverpod (`riverpod_annotation`, `riverpod_generator`)
- GoRouter
- Supabase Flutter
- Freezed + json_serializable

## Notes

- Admin app and main app share the same Supabase backend.
- Template changes are reflected in the main app as soon as data is updated.
