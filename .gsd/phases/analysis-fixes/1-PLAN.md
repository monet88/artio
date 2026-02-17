---
phase: analysis-fixes
plan: 1
wave: 1
---

# Plan 1: Auto-fixable Lint Issues (dart fix)

## Objective
Apply `dart fix --apply` to resolve all 544 auto-fixable issues across 132 files.
This covers the bulk of issues: `directives_ordering`, `always_use_package_imports`,
`prefer_const_constructors`, `always_put_required_named_parameters_first`,
`avoid_redundant_argument_values`, `prefer_int_literals`, `unnecessary_lambdas`,
`sort_constructors_first`, `omit_local_variable_types`, `combinators_ordering`,
`use_colored_box`, `use_if_null_to_convert_nulls_to_bools`, and more.

## Context
- .gsd/ARCHITECTURE.md
- `flutter analyze` output (712 total issues, 544 auto-fixable)

## Tasks

<task type="auto">
  <name>Run dart fix --apply</name>
  <files>All 132 affected files across lib/, test/, integration_test/, admin/</files>
  <action>
    Run `dart fix --apply` from the project root.
    This will auto-fix 544 issues across 132 files.
    
    DO NOT manually edit any files — let dart fix handle everything.
  </action>
  <verify>flutter analyze 2>&1 | grep -c "info\|warning\|error" | should be significantly lower than 712</verify>
  <done>dart fix reports 0 remaining auto-fixable issues</done>
</task>

<task type="auto">
  <name>Run flutter analyze and count remaining</name>
  <files>N/A</files>
  <action>
    Run `flutter analyze` and count remaining issues.
    Categorize remaining issues by type for Wave 2 planning.
  </action>
  <verify>flutter analyze 2>&1 | grep -E "info|warning|error" | grep -v "Analyzing|No issues" | wc -l</verify>
  <done>Remaining issue count documented</done>
</task>

<task type="auto">
  <name>Commit auto-fixes</name>
  <files>All modified files</files>
  <action>
    Stage and commit all changes:
    `git add -A && git commit -m "fix: apply dart fix for 544 auto-fixable lint issues"`
  </action>
  <verify>git log --oneline -1</verify>
  <done>Clean commit with descriptive message</done>
</task>

## Success Criteria
- [ ] `dart fix --apply` runs successfully
- [ ] Remaining issue count < 200 (from 712)
- [ ] Clean git commit
