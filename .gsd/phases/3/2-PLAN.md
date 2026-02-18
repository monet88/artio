---
phase: 3
plan: 2
wave: 2
---

# Plan 3.2: Reduce Cross-Feature Coupling

## Objective
Several features directly import from other features' presentation layers (21 cross-feature imports
found). Some are legitimate (e.g., `create` using `template_engine` domain entities). Others
represent coupling that should be routed through `core/state/` shared providers.

**Main coupling patterns to fix:**
1. **AuthViewModel** imported by 5 features — extract auth state to `core/state/`
2. **CreditBalanceProvider** imported by create — already in `core/state/user_scoped_providers.dart`? Verify
3. **SubscriptionProvider** imported by gallery, credits — extract to `core/state/`

## Context
- lib/core/state/user_scoped_providers.dart
- Cross-feature import list (from /map analysis)
- .gsd/ARCHITECTURE.md

## Tasks

<task type="auto">
  <name>Audit and categorize cross-feature imports</name>
  <files>
    lib/core/state/user_scoped_providers.dart
  </files>
  <action>
    1. Read `user_scoped_providers.dart` to see what's already shared via core
    2. For each cross-feature import found in `/map`:
       - Mark as LEGITIMATE if it accesses a domain entity or domain interface
         (e.g., `GenerationJobModel` from template_engine is a domain entity — OK)
       - Mark as FIX if it accesses a presentation-layer provider/viewmodel from another feature
    3. For FIX items: determine if a `core/state/` provider already exists or needs creation
    4. Write a summary of what needs to move

    - What to avoid: Do NOT fix legitimate domain entity imports. They are correct.
  </action>
  <verify>cat the summary output</verify>
  <done>Categorization complete; fix list documented in commit message</done>
</task>

<task type="auto">
  <name>Extract shared state providers to core</name>
  <files>
    lib/core/state/user_scoped_providers.dart (or new files in lib/core/state/)
    Affected feature files importing cross-feature presentation providers
  </files>
  <action>
    For each FIX item from the audit:
    1. Create or update a provider in `core/state/` that exposes the needed state
    2. Update the importing feature files to use the `core/state/` provider instead
    3. Keep the original feature's provider as the source of truth (the core provider
       can simply re-export or delegate)

    Common pattern:
    ```dart
    // lib/core/state/auth_state_provider.dart
    @riverpod
    bool isAuthenticated(Ref ref) {
      return ref.watch(authViewModelProvider).isAuthenticated;
    }
    ```

    - What to avoid: Do NOT create deep abstractions. A thin re-export or derived provider is
      sufficient. Do NOT break existing consumer behavior.
  </action>
  <verify>python3 -c "
import os, re
violations = 0
for root, dirs, files in os.walk('lib/features'):
    for f in files:
        if f.endswith('.dart') and not f.endswith('.g.dart') and not f.endswith('.freezed.dart'):
            fp = os.path.join(root, f)
            parts = fp.split('/')
            if len(parts) >= 3:
                feature = parts[2]
                with open(fp) as fh:
                    for i, line in enumerate(fh, 1):
                        m = re.search(r\"import 'package:artio/features/(\w+)/presentation/\", line)
                        if m and m.group(1) != feature:
                            violations += 1
                            print(f'{fp}:{i} -> {m.group(1)}')
print(f'Total violations: {violations}')
"</verify>
  <done>Cross-feature presentation imports reduced; only legitimate domain imports remain; tests pass</done>
</task>

## Success Criteria
- [ ] Zero unnecessary cross-feature presentation-layer imports
- [ ] Core state providers exist for auth and subscription status
- [ ] `flutter analyze` clean
- [ ] All tests pass (`flutter test`)
