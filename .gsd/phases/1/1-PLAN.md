---
phase: 1
plan: 1
wave: 1
discovery: 0
---

# Plan 1.1: Admin Web Fix

## Objective
Fix all `flutter analyze` errors in the admin web project. The root cause is twofold:
1. Dependencies not resolved — `flutter pub get` not run
2. `dart:io` imported in `error_state_widget.dart` — not available on web platform

## Context
- .gsd/ROADMAP.md — Phase 1 description
- admin/pubspec.yaml — Admin dependencies
- admin/lib/shared/widgets/error_state_widget.dart — Uses `dart:io` for `SocketException`
- admin/lib/main.dart — Entry point (verify ProviderScope resolves)

## Tasks

<task type="auto">
  <name>Resolve admin dependencies</name>
  <files>admin/pubspec.yaml, admin/pubspec.lock</files>
  <action>
    Run `flutter pub get` in admin/ directory.
    - This resolves all "uri_does_not_exist" errors which cascade into 1000+ issues
    - Do NOT modify pubspec.yaml unless pub get fails
  </action>
  <verify>flutter pub get exits 0 in admin/</verify>
  <done>All admin package imports resolve without uri_does_not_exist errors</done>
</task>

<task type="auto">
  <name>Fix dart:io usage in error_state_widget.dart</name>
  <files>admin/lib/shared/widgets/error_state_widget.dart</files>
  <action>
    Remove `import 'dart:io';` — dart:io is unavailable on web platform.
    Remove the `if (error is SocketException)` check in `_categorize()`.
    The string-based detection (`msg.contains('socket')`) already covers this case.
    - Do NOT change the widget's public API
    - Do NOT change other error categories
  </action>
  <verify>grep -c "dart:io" admin/lib/shared/widgets/error_state_widget.dart returns 0</verify>
  <done>No dart:io import, _categorize still handles network/server/unknown categories via string matching</done>
</task>

<task type="auto">
  <name>Run flutter analyze on admin</name>
  <files>admin/</files>
  <action>
    Run `flutter analyze` from project root.
    Verify admin/ has 0 errors.
    If codegen files (.g.dart) are stale, run `dart run build_runner build --delete-conflicting-outputs` in admin/.
    - Do NOT fix main app warnings (that's Phase 2)
  </action>
  <verify>flutter analyze shows 0 errors in admin/ files</verify>
  <done>All admin/ analyze errors resolved</done>
</task>

## Success Criteria
- [ ] `flutter pub get` succeeds in admin/
- [ ] No `dart:io` import in admin web code
- [ ] `flutter analyze` shows 0 errors for admin/ files
