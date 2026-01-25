# Phase 5: Constants Extraction

## Context Links

- [Tech Debt Audit](../reports/flutter-expert-260125-1548-tech-debt-audit.md) - M2, M3, M8
- Parent: [plan.md](./plan.md)

## Overview

**Priority**: P2 (Medium)
**Status**: pending
**Effort**: 1 hour
**Depends on**: Phase 4 complete

Extract hardcoded values to centralized constants files.

## Issues Addressed

| Issue | Description | File |
|-------|-------------|------|
| M2 | Hardcoded OAuth redirect URLs | `auth_repository.dart:62,73,87` |
| M3 | Hardcoded defaults in profile creation | `auth_repository.dart:126-132` |
| M8 | Aspect ratio options hardcoded in UI | `template_detail_screen.dart:91` |

## Implementation Steps

### Step 1: Create Constants Structure (10 min)

```bash
mkdir -p lib/core/constants
```

Create `lib/core/constants/app_constants.dart`:

```dart
/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Deep linking
  static const String appScheme = 'com.artio.app';
  static const String loginCallback = '$appScheme://login-callback';
  static const String resetPasswordCallback = '$appScheme://reset-password';

  // User defaults
  static const int defaultCredits = 5;
  static const int dailyFreeLimit = 5;

  // Generation
  static const List<String> aspectRatios = ['1:1', '4:3', '3:4', '16:9', '9:16'];
  static const String defaultAspectRatio = '1:1';
  static const int maxPromptLength = 1000;
}
```

### Step 2: Update AuthRepository (15 min)

Replace hardcoded values in `auth_repository.dart`:

```dart
import '../../../core/constants/app_constants.dart';

// Line 62, 73
redirectTo: AppConstants.loginCallback,

// Line 87
redirectTo: AppConstants.resetPasswordCallback,

// Line 128
'credits': AppConstants.defaultCredits,
```

### Step 3: Update TemplateDetailScreen (10 min)

Replace hardcoded aspect ratios:

```dart
import '../../../core/constants/app_constants.dart';

// Line 91
children: AppConstants.aspectRatios.map((ratio) {...})
```

### Step 4: Verify (10 min)

```bash
flutter analyze
flutter test
```

## Todo List

- [ ] Create `lib/core/constants/app_constants.dart`
- [ ] Update AuthRepository OAuth URLs (M2)
- [ ] Update AuthRepository profile defaults (M3)
- [ ] Update TemplateDetailScreen aspect ratios (M8)
- [ ] Run `flutter analyze`
- [ ] Run `flutter test`

## Success Criteria

- [ ] No hardcoded URLs in auth code
- [ ] No magic numbers in profile creation
- [ ] Aspect ratios from constants
- [ ] All tests pass

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Constant not imported | Run analyze after each change |
| Wrong URL breaks OAuth | Test auth flow manually |

## Security Considerations

- OAuth URLs are not secrets, safe to hardcode in constants
- Do not put actual secrets in constants files

## Next Steps

After completing Phase 5:
1. Proceed to Phase 6: Dead Code & Cleanup
