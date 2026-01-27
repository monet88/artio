# Phase 6: Dead Code & Cleanup

## Context Links

- [Tech Debt Audit](../reports/flutter-expert-260125-1548-tech-debt-audit.md) - L3, L4, M1, M7
- Parent: [plan.md](./plan.md)

## Overview

**Priority**: P2 (Medium)
**Status**: completed
**Effort**: 1 hour
**Depends on**: Phase 5 complete

Remove dead code, fix placeholder screens, and address theme race condition.

## Issues Addressed

| Issue | Severity | Description | Action |
|-------|----------|-------------|--------|
| L3 | Low | Subscription feature empty | Remove or stub properly |
| L4 | Low | Unused Dio client | Remove if not needed |
| M1 | Medium | Empty placeholder screens | Add "Coming Soon" UX |
| M7 | Medium | Theme provider async race | Fix with FutureProvider |

## Implementation Steps

### Step 1: Check Dio Usage (10 min)

```bash
grep -rn "dio" lib/ --include="*.dart"
grep -rn "DioClient" lib/ --include="*.dart"
```

If no references found beyond `dio_client.dart`:
- Remove `lib/utils/dio_client.dart`
- Remove `dio` from `pubspec.yaml` if no other usage

### Step 2: Check Subscription Feature (10 min)

```bash
ls -la lib/features/subscription/
grep -rn "subscription" lib/ --include="*.dart"
```

If empty/unused:
- Remove `lib/features/subscription/` directory
- Or add TODO comment if planned

### Step 3: Fix Empty Screens (15 min)

Update placeholder screens with proper "Coming Soon" UX:

```dart
// create_screen.dart, gallery_screen.dart, settings_screen.dart
import 'package:flutter/material.dart';

class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Coming Soon',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'This feature is under development',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 4: Fix Theme Race Condition (15 min)

Option A: Convert to FutureProvider

```dart
// theme_provider.dart
@riverpod
Future<ThemeMode> themeMode(Ref ref) async {
  final prefs = await SharedPreferences.getInstance();
  final value = prefs.getString('theme_mode');
  return switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}
```

Option B: Use synchronous default + async update (current pattern is OK if splash screen is long enough)

**Recommended**: Keep current pattern, ensure splash screen shows during initial load.

### Step 5: Verify (10 min)

```bash
flutter analyze
flutter test
flutter run # Manual check theme/screens
```

## Todo List

- [x] Check and remove unused Dio client (L4)
- [x] Check and remove/stub subscription feature (L3)
- [x] Update create_screen.dart with Coming Soon
- [x] Update gallery_screen.dart with Coming Soon
- [x] Update settings_screen.dart with Coming Soon
- [x] Evaluate theme race condition (M7)
- [x] Run `flutter analyze`
- [x] Run `flutter test`

## Success Criteria

- [x] No dead code in codebase
- [x] Placeholder screens have proper UX
- [x] Theme loads without flicker (or acceptable delay)
- [x] All tests pass

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Remove needed code | Grep before delete, check git history |
| Theme flicker still visible | Accept if < 100ms, users won't notice |

## Security Considerations

None - cleanup phase.

## Next Steps

After completing Phase 6:
1. Run full code review
2. Commit: `refactor: architecture hardening complete (3-layer, DI, constants, cleanup)`
3. Start Plan 2: Credit/Premium/Rate Limit
