# Phase 4: Code Quality & Linting

## Context Links

- [Flutter Expert Review](../reports/flutter-expert-260125-1503-phase45-review.md) - M3 finding
- [Dart Best Practices Skill](../../.claude/skills/dart/best-practices/skill.md)
- [analysis_options.yaml](../../analysis_options.yaml)

## Overview

**Priority**: P2 (Medium)
**Status**: pending
**Effort**: 1.5 hours
**Depends on**: Phases 1-3 complete (changes may introduce new files)

Enable `prefer_const_constructors` lint rule and apply const optimizations across codebase. Minor performance improvement via reduced widget rebuilds.

## Key Insights

1. Dart best practices: `const` > `final` > `var`
2. `const` widgets are canonical - not rebuilt when parent rebuilds
3. Flutter analyzer can auto-fix many const violations
4. Lint rule ensures future code follows pattern

## Requirements

### Functional
- Enable `prefer_const_constructors` in analysis_options.yaml
- Fix all lint violations

### Non-Functional
- 0 lint violations
- Minor performance improvement

## Architecture

No architectural changes. This is code polish.

### Lint Rule Addition

```yaml
# analysis_options.yaml
linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
```

## Related Code Files

### Files to Modify

- `analysis_options.yaml` (add rules)
- Multiple `.dart` files (add const keywords)

### Common Patterns to Fix

```dart
// BEFORE
SizedBox(height: 16)
EdgeInsets.all(16)
Icon(Icons.error)
Text('Hello')
Center(child: CircularProgressIndicator())

// AFTER
const SizedBox(height: 16)
const EdgeInsets.all(16)
const Icon(Icons.error)
const Text('Hello')
const Center(child: CircularProgressIndicator())
```

## Implementation Steps

### Step 1: Enable Lint Rules (5 min)

Update `analysis_options.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
    # Optional but recommended:
    avoid_redundant_argument_values: true
    use_super_parameters: true
```

### Step 2: Run Analyzer to Find Violations (5 min)

```bash
flutter analyze --no-fatal-infos
```

Count violations. Expected: ~15-30 based on review.

### Step 3: Auto-Fix Where Possible (15 min)

```bash
dart fix --apply
```

This applies automatic fixes for many lint rules.

### Step 4: Manual Fixes (45 min)

For violations not auto-fixed:

1. Open each file with violations
2. Add `const` to widget constructors
3. Add `const` to literal lists/maps
4. Mark `final` variables as `const` where possible

Focus files (from review):
- `template_detail_screen.dart`
- `login_screen.dart`
- `template_card.dart`
- Widget files in general

### Step 5: Verify No Regressions (15 min)

```bash
flutter analyze
flutter test
```

### Step 6: Spot Check Performance (5 min)

Run app in profile mode, verify no new jank introduced:

```bash
flutter run --profile
```

## Todo List

- [ ] Update analysis_options.yaml with const rules
- [ ] Run flutter analyze to baseline violation count
- [ ] Run dart fix --apply for auto-fixes
- [ ] Fix remaining violations in template_detail_screen.dart
- [ ] Fix remaining violations in login_screen.dart
- [ ] Fix remaining violations in other UI files
- [ ] Run flutter analyze (expect 0 violations)
- [ ] Run flutter test
- [ ] Smoke test app in profile mode

## Success Criteria

- [ ] `prefer_const_constructors` enabled in analysis_options
- [ ] `flutter analyze` reports 0 issues (excluding pre-existing infos)
- [ ] All tests pass
- [ ] App runs without regressions

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| const breaks dynamic values | Low | Low | Compiler catches immediately |
| Too many violations to fix | Low | Low | Focus on widget constructors first |
| Performance regression | Very Low | Low | Profile mode sanity check |

## Security Considerations

No security impact.

## Next Steps

After completing Phase 4:
1. Phase 4.6 complete
2. Run full code review
3. Commit all changes with message: "feat: architecture hardening (3-layer, DI, error UX, const lint)"

---

## Deferred: TypedGoRoute Migration

**Status**: Deferred to tech debt backlog

**Reason**: go_router_builder (v2.9.0) compatibility concerns with current go_router (v14.8.1). Migration requires:
1. Adding `@TypedGoRoute` annotations to route classes
2. Creating `GoRouteData` subclasses for each route
3. Running build_runner to generate route code
4. Updating all `context.go()` calls to use typed routes

**Effort**: 3-4 hours

**Risk**: go_router_builder may not support all go_router v14 features (ShellRoute, etc.)

**Recommendation**: Defer until:
1. go_router_builder releases compatible version, OR
2. Routes need significant changes anyway

Document in tech debt backlog with link to this phase file.
