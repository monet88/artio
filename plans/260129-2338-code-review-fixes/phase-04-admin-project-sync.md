# Phase 04: Admin Project Sync

## Parallelization Info

| Property | Value |
|----------|-------|
| Group | B (Cleanup) |
| Can Run With | Phase 03 |
| Blocked By | Group A (Phases 01, 02) |
| Blocks | Group C (Phases 05-08) |

## File Ownership (Exclusive)

- `admin/analysis_options.yaml`

## Priority: HIGH

**Issue**: Admin project has different lint rules than root project, causing inconsistent code quality.

## Current State

**Root `analysis_options.yaml`**:
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
    avoid_redundant_argument_values: true
    use_super_parameters: true
```

**Admin `analysis_options.yaml`** (missing rules):
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Only comments, no active rules
```

## Implementation Steps

### Step 1: Update `admin/analysis_options.yaml`

```yaml
# This file configures the analyzer, which statically analyzes Dart code to
# check for errors, warnings, and lints.
#
# The issues identified by the analyzer are surfaced in the UI of Dart-enabled
# IDEs (https://dart.dev/tools#ides-and-editors). The analyzer can also be
# invoked from the command line by running `flutter analyze`.

# The following line activates a set of recommended lints for Flutter apps,
# packages, and plugins designed to encourage good coding practices.
include: package:flutter_lints/flutter.yaml

linter:
  # The lint rules applied to this project can be customized in the
  # section below to disable rules from the `package:flutter_lints/flutter.yaml`
  # included above or to enable additional rules. A list of all available lints
  # and their documentation is published at https://dart.dev/lints.
  #
  # Instead of disabling a lint rule for the entire project in the
  # section below, it can also be suppressed for a single line of code
  # or a specific dart file by using the `// ignore: name_of_lint` and
  # `// ignore_for_file: name_of_lint` syntax on the line or in the file
  # producing the lint.
  rules:
    # Code quality and const optimization (synced with root project)
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_const_literals_to_create_immutables: true
    # Optional but recommended
    avoid_redundant_argument_values: true
    use_super_parameters: true

# Additional information about this file can be found at
# https://dart.dev/guides/language/analysis-options
```

### Step 2: Run analyzer to check for new warnings

```bash
cd admin
flutter analyze
```

### Step 3: Fix any new lint warnings (if manageable)

If analyzer reports many warnings from new rules:
- Fix obvious ones (add `const` where needed)
- For files with many issues, add `// ignore_for_file:` temporarily with TODO comment

## Success Criteria

- [ ] `admin/analysis_options.yaml` matches root project rules
- [ ] `flutter analyze` in admin directory passes (or only expected warnings)
- [ ] No regression in admin project functionality

## Conflict Prevention

- Only this phase modifies `admin/analysis_options.yaml`
- Phase 08 modifies admin Dart files, but runs after this phase

## Notes

- Future consideration: Use shared analysis_options via package or symlink
- For now, manual sync is acceptable given small project scope
