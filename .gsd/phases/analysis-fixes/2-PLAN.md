---
phase: analysis-fixes
plan: 2
wave: 2
depends_on: [1]
---

# Plan 2: Manual Fixes — Catch Clauses & Cascade Invocations

## Objective
Fix issues that `dart fix` cannot auto-resolve: `avoid_catches_without_on_clauses` (22),
`cascade_invocations` (20), and `avoid_print` (6). These require understanding the code
context to apply correctly.

## Context
- .gsd/ARCHITECTURE.md
- Remaining `flutter analyze` output after Plan 1

## Tasks

<task type="auto">
  <name>Fix avoid_catches_without_on_clauses (22 issues)</name>
  <files>
    lib/core/constants/ai_models.dart
    lib/core/utils/date_time_utils.dart
    lib/features/auth/presentation/screens/forgot_password_screen.dart
    lib/features/auth/presentation/view_models/auth_view_model.dart (8)
    lib/features/gallery/data/repositories/gallery_repository.dart
    lib/features/gallery/presentation/pages/image_viewer_page.dart (2)
    lib/features/settings/data/notifications_provider.dart
    lib/features/template_engine/data/repositories/generation_repository.dart
    lib/features/template_engine/data/repositories/template_repository.dart
    lib/features/template_engine/presentation/helpers/generation_job_manager.dart
    test/ files (various)
  </files>
  <action>
    For each bare `catch (e)`, add `on Exception` or a more specific type:
    - Network calls: `on Exception catch (e)`
    - Auth calls: `on Exception catch (e)` (Supabase throws Exception subtypes)
    - Parse errors: `on FormatException catch (e)` where applicable
    - Generic fallbacks: `on Object catch (e)` as last resort
    
    IMPORTANT: Do NOT change catch block bodies. Only add the `on` clause.
  </action>
  <verify>flutter analyze 2>&1 | grep "avoid_catches_without_on_clauses" | wc -l → 0</verify>
  <done>0 remaining avoid_catches_without_on_clauses issues</done>
</task>

<task type="auto">
  <name>Fix cascade_invocations (20 issues)</name>
  <files>
    lib/core/config/sentry_config.dart
    lib/features/template_engine/presentation/screens/template_detail_screen.dart
    test/ files (various)
  </files>
  <action>
    Convert repeated method calls on the same receiver to cascade notation:
    ```dart
    // Before
    options.dsn = dsn;
    options.tracesSampleRate = 1.0;
    
    // After  
    options
      ..dsn = dsn
      ..tracesSampleRate = 1.0;
    ```
    
    Only apply where it improves readability. Skip if cascading would be awkward.
  </action>
  <verify>flutter analyze 2>&1 | grep "cascade_invocations" | wc -l → 0</verify>
  <done>0 remaining cascade_invocations issues</done>
</task>

<task type="auto">
  <name>Fix avoid_print in integration tests (6 issues)</name>
  <files>integration_test/template_e2e_test.dart</files>
  <action>
    Replace `print()` calls with `debugPrint()` from Flutter foundation.
    Add `import 'package:flutter/foundation.dart';` if not present.
  </action>
  <verify>flutter analyze 2>&1 | grep "avoid_print" | wc -l → 0</verify>
  <done>0 remaining avoid_print issues</done>
</task>

## Success Criteria
- [ ] 0 avoid_catches_without_on_clauses issues
- [ ] 0 cascade_invocations issues
- [ ] 0 avoid_print issues
- [ ] All tests still pass
