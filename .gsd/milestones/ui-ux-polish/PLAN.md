# UI/UX Polish — Phase Plan

> **Milestone**: UI/UX Polish
> **Origin**: Frontend review via ui-ux-pro-max skill (2026-02-21)
> **Discovery Level**: 0 (all code already analyzed, changes are surgical)
> **Total Plans**: 6 | **Waves**: 3

---

## Goal-Backward: What Must Be TRUE When Done?

### Must-Haves (Truths)
1. TemplateDetailScreen reads actual subscription status from `authViewModelProvider` — no hardcoded `false`
2. All continuous/dramatic animations (splash, loading, error) respect `MediaQuery.disableAnimations`
3. HomeScreen has no disabled/fake search bar
4. No emoji characters (✨🌅🎨🌙) used as UI elements in text strings
5. PaywallScreen uses `LoadingStateWidget` and `ErrorStateWidget` (brand consistency)
6. Key interactive elements have `Semantics` labels
7. All spacing values use `AppSpacing` constants (no magic numbers)
8. LoginScreen has no unused `SingleTickerProviderStateMixin`

### Must-Haves (Artifacts)
- `flutter analyze` passes with 0 errors
- All existing tests still pass
- No new warnings introduced

---

## Dependency Graph

```
Wave 1 (parallel):  Plan 1.1 ──┐
                    Plan 1.2 ──┼── independent, no file overlap
                    Plan 1.3 ──┘

Wave 2 (parallel):  Plan 1.4 ──┐
                    Plan 1.5 ──┘── independent, no file overlap

Wave 3 (sequential): Plan 1.6 ── final sweep
```

---

## Wave 1 — Critical Fixes & Quick Wins

### Plan 1.1: Fix _isPremium Bug in TemplateDetailScreen

```yaml
phase: 1
plan: 1
wave: 1
depends_on: []
files_modified:
  - lib/features/template_engine/presentation/screens/template_detail_screen.dart
autonomous: true
must_haves:
  truths:
    - "TemplateDetailScreen reads isPremium from authViewModelProvider.user.isPremium"
    - "Premium users can select premium models in template detail flow"
  artifacts:
    - "Hardcoded `bool get _isPremium => false` is removed"
```

<objective>
Fix the hardcoded `_isPremium => false` bug that prevents premium users from using premium AI models in the template generation flow.

Purpose: Users paying for premium subscriptions currently cannot access premium models via templates — this is a revenue-impacting bug.
Output: TemplateDetailScreen correctly reads subscription status.
</objective>

<context>
Load for context:
- lib/features/template_engine/presentation/screens/template_detail_screen.dart (line 41: hardcoded false)
- lib/features/create/presentation/create_screen.dart (lines 150-152: reference implementation for isPremium)
- lib/core/state/auth_view_model_provider.dart (provides auth state with user.isPremium)
</context>

<tasks>

<task type="auto">
  <name>Wire isPremium to auth state</name>
  <files>lib/features/template_engine/presentation/screens/template_detail_screen.dart</files>
  <action>
    1. Convert `_isPremium` from a hardcoded getter to a reactive value read from `authViewModelProvider`
    2. Follow the exact same pattern as CreateScreen: `ref.watch(authViewModelProvider).maybeMap(authenticated: (state) => state.user.isPremium, orElse: () => false)`
    3. Place the `isPremium` read inside the `build()` method where `options` is already watched
    4. Remove the `// Placeholder for premium status` comment

    AVOID: Using `ref.read` instead of `ref.watch` — must be reactive to auth state changes
    AVOID: Adding `subscription_state_provider` import — isPremium already available on user model
  </action>
  <verify>
    - `flutter analyze` clean for this file
    - Existing tests pass: `flutter test test/features/template_engine/`
  </verify>
  <done>_isPremium reads from authViewModelProvider, hardcoded false removed, analyze clean</done>
</task>

</tasks>

<verification>
- [ ] `_isPremium` no longer returns hardcoded false
- [ ] Premium users see premium model options correctly
- [ ] `flutter analyze` passes
</verification>

---

### Plan 1.2: Upgrade PaywallScreen to Branded Widgets

```yaml
phase: 1
plan: 2
wave: 1
depends_on: []
files_modified:
  - lib/features/subscription/presentation/screens/paywall_screen.dart
autonomous: true
must_haves:
  truths:
    - "PaywallScreen loading state uses LoadingStateWidget(compact: true)"
    - "PaywallScreen error state uses ErrorStateWidget with onRetry"
  artifacts:
    - "Imports for LoadingStateWidget and ErrorStateWidget added"
    - "Generic CircularProgressIndicator and plain error UI replaced"
```

<objective>
Replace generic loading/error UI in PaywallScreen with the app's branded `LoadingStateWidget` and `ErrorStateWidget` for visual consistency.

Purpose: PaywallScreen is user's first impression of premium offering — it must feel premium.
Output: Consistent branded UX across all screens.
</objective>

<context>
Load for context:
- lib/features/subscription/presentation/screens/paywall_screen.dart (lines 35-57: generic loading/error)
- lib/shared/widgets/loading_state_widget.dart (branded loader with compact mode)
- lib/shared/widgets/error_state_widget.dart (categorized error with auto-detect + retry)
</context>

<tasks>

<task type="auto">
  <name>Replace loading state</name>
  <files>lib/features/subscription/presentation/screens/paywall_screen.dart</files>
  <action>
    1. Replace `const Center(child: CircularProgressIndicator())` (line 35) with `const LoadingStateWidget(compact: true)`
    2. Add import for `loading_state_widget.dart`

    AVOID: Using full-size LoadingStateWidget — compact mode is better for inline content areas
  </action>
  <verify>`flutter analyze` clean for this file</verify>
  <done>Loading state uses branded widget</done>
</task>

<task type="auto">
  <name>Replace error state</name>
  <files>lib/features/subscription/presentation/screens/paywall_screen.dart</files>
  <action>
    1. Replace the error block (lines 36-57) with:
       `ErrorStateWidget(message: 'Unable to load subscription options', onRetry: () => ref.invalidate(offeringsProvider))`
    2. Add import for `error_state_widget.dart`
    3. Remove the now-unused `Icon`, `Text`, `TextButton` column layout

    AVOID: Wrapping in Center/Padding — ErrorStateWidget handles its own centering and padding
  </action>
  <verify>`flutter analyze` clean, `flutter test test/features/subscription/`</verify>
  <done>Error state uses branded ErrorStateWidget with retry</done>
</task>

</tasks>

<verification>
- [ ] Loading shows branded pulsing logo (compact)
- [ ] Error shows categorized illustration + animated retry
- [ ] `flutter analyze` passes
</verification>

---

### Plan 1.3: Dead Code Cleanup — LoginScreen Mixin

```yaml
phase: 1
plan: 3
wave: 1
depends_on: []
files_modified:
  - lib/features/auth/presentation/screens/login_screen.dart
autonomous: true
must_haves:
  truths:
    - "LoginScreen no longer uses SingleTickerProviderStateMixin"
  artifacts:
    - "Unused mixin removed, file compiles clean"
```

<objective>
Remove dead `SingleTickerProviderStateMixin` from LoginScreen — leftover from a previous refactoring.

Purpose: Dead code creates confusion and false dependency signals.
Output: Clean class declaration.
</objective>

<tasks>

<task type="auto">
  <name>Remove unused mixin</name>
  <files>lib/features/auth/presentation/screens/login_screen.dart</files>
  <action>
    1. Change line 23-24 from:
       `class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin`
       to:
       `class _LoginScreenState extends ConsumerState<LoginScreen>`
    2. Verify no AnimationController or Ticker usage in the file

    AVOID: Removing the mixin if any animation controller is added in the future — verify first
  </action>
  <verify>`flutter analyze` clean for this file</verify>
  <done>Mixin removed, no compile errors</done>
</task>

</tasks>

---

## Wave 2 — Home Screen & Motion Accessibility

### Plan 1.4: Home Screen Polish — Emojis & Search Bar

```yaml
phase: 1
plan: 4
wave: 2
depends_on: []
files_modified:
  - lib/features/template_engine/presentation/screens/home_screen.dart
autonomous: true
must_haves:
  truths:
    - "No emoji characters in HomeScreen UI text"
    - "No disabled/fake search bar displayed"
  artifacts:
    - "Greeting text uses plain text without emojis"
    - "Search bar container + TextField removed"
```

<objective>
Remove UI anti-patterns from HomeScreen: emoji usage in text and misleading disabled search bar.

Purpose: Emojis render inconsistently cross-platform. Disabled search bar violates affordance principles.
Output: Clean, professional home screen header.
</objective>

<context>
Load for context:
- lib/features/template_engine/presentation/screens/home_screen.dart
</context>

<tasks>

<task type="auto">
  <name>Remove emojis from UI text</name>
  <files>lib/features/template_engine/presentation/screens/home_screen.dart</files>
  <action>
    1. Line 55: Change `'Discover Templates ✨'` → `'Discover Templates'`
    2. Line 156: Change `'Good morning, Artist 🌅'` → `'Good morning'`
    3. Line 157: Change `'Good afternoon, Artist 🎨'` → `'Good afternoon'`
    4. Line 158: Change `'Good evening, Artist 🌙'` → `'Good evening'`

    AVOID: Adding Icon widgets as replacement — keep text simple and clean
    AVOID: Changing text structure/layout — only remove emoji characters
  </action>
  <verify>No emoji characters remain: `grep -c '[\x{1F300}-\x{1F9FF}]' home_screen.dart` returns 0</verify>
  <done>All 4 emoji occurrences removed</done>
</task>

<task type="auto">
  <name>Remove disabled search bar</name>
  <files>lib/features/template_engine/presentation/screens/home_screen.dart</files>
  <action>
    1. Remove the entire search bar Container block (lines 73-103) including the `SizedBox(height: AppSpacing.md)` above it (line 70)
    2. This removes the misleading disabled TextField

    AVOID: Implementing a working search — that's a separate feature request
    AVOID: Breaking the layout — verify spacing between greeting and category chips remains clean
  </action>
  <verify>`flutter analyze` clean, visual layout intact</verify>
  <done>Search bar removed, spacing clean between greeting and category chips</done>
</task>

</tasks>

<verification>
- [ ] No emojis in any text strings
- [ ] No disabled search bar visible
- [ ] Layout flows naturally: greeting → category chips → featured → grid
- [ ] `flutter analyze` passes
</verification>

---

### Plan 1.5: Reduced-Motion & Spacing Cleanup

```yaml
phase: 1
plan: 5
wave: 2
depends_on: []
files_modified:
  - lib/features/auth/presentation/screens/splash_screen.dart
  - lib/shared/widgets/loading_state_widget.dart
  - lib/shared/widgets/error_state_widget.dart
autonomous: true
must_haves:
  truths:
    - "Splash, loading, and error animations check MediaQuery.disableAnimations"
    - "When disableAnimations is true, animations complete instantly or are skipped"
    - "Magic number spacing replaced with AppSpacing constants"
  artifacts:
    - "MediaQuery.disableAnimations checked in 3 files"
```

<objective>
Add `prefers-reduced-motion` / `disableAnimations` support to all widget files with continuous or dramatic animations. Also clean up hardcoded spacing values.

Purpose: Accessibility requirement — users with vestibular disorders need reduced motion. Spacing constants = consistency.
Output: Motion-accessible animations, consistent spacing.
</objective>

<context>
Load for context:
- lib/features/auth/presentation/screens/splash_screen.dart (3 AnimationControllers)
- lib/shared/widgets/loading_state_widget.dart (pulsing animation, shimmer)
- lib/shared/widgets/error_state_widget.dart (fade+scale entry)
- lib/core/design_system/app_spacing.dart (spacing constants)
</context>

<tasks>

<task type="auto">
  <name>Add reduced-motion check to splash screen</name>
  <files>lib/features/auth/presentation/screens/splash_screen.dart</files>
  <action>
    1. In `_startAnimations()`, check `MediaQuery.of(context).disableAnimations` (use `didChangeDependencies` to access context)
    2. If disableAnimations is true:
       - Set all animation controllers to their end values instantly (`.value = 1.0`)
       - Don't start the pulse repeating animation
    3. Fix spacing: `SizedBox(height: 12)` → `SizedBox(height: AppSpacing.sm)` (line 139)
    4. Fix spacing: `SizedBox(height: 64)` → `SizedBox(height: AppSpacing.xxl)` (line 158)
    5. Add Semantics label on the logo: `Semantics(label: 'Artio logo', child: ...)`

    AVOID: Removing animations entirely — just skip/complete instantly for reduced-motion users
    AVOID: Using `WidgetsBinding.instance.window` — use `MediaQuery.of(context)`
  </action>
  <verify>`flutter analyze` clean</verify>
  <done>Reduced motion support added, spacing uses constants, semantics added</done>
</task>

<task type="auto">
  <name>Add reduced-motion check to loading widget</name>
  <files>lib/shared/widgets/loading_state_widget.dart</files>
  <action>
    1. In `LoadingStateWidget.build()`, check `MediaQuery.of(context).disableAnimations`
    2. If true: skip the pulse animation — show static branded logo without Transform.scale, static glow
    3. SkeletonLoader: if `disableAnimations`, show static shimmer base color instead of animated gradient

    AVOID: Breaking the compact variant — disableAnimations check only applies to the non-compact version's pulse
  </action>
  <verify>`flutter analyze` clean</verify>
  <done>Pulse and shimmer respect reduced-motion preference</done>
</task>

<task type="auto">
  <name>Add reduced-motion check to error widget</name>
  <files>lib/shared/widgets/error_state_widget.dart</files>
  <action>
    1. In `initState()`, check `MediaQuery.of(context).disableAnimations` via `didChangeDependencies`
    2. If true: set `_controller.value = 1.0` immediately (skip fade+scale entrance)
    3. Otherwise: play animation normally with `.forward()`

    AVOID: Adding a new parameter — use MediaQuery automatically
  </action>
  <verify>`flutter analyze` clean</verify>
  <done>Error widget respects reduced-motion</done>
</task>

</tasks>

<verification>
- [ ] `MediaQuery.disableAnimations` checked in all 3 files
- [ ] Animations complete instantly when reduced-motion is true
- [ ] No magic number spacing remains in splash_screen.dart
- [ ] `flutter analyze` passes
</verification>

---

## Wave 3 — Accessibility Polish

### Plan 1.6: Semantics & Accessibility Labels

```yaml
phase: 1
plan: 6
wave: 3
depends_on: [1.4, 1.5]
files_modified:
  - lib/shared/widgets/main_shell.dart
  - lib/shared/widgets/gradient_button.dart
autonomous: true
must_haves:
  truths:
    - "NavigationBar destinations have tooltip descriptors"
    - "GradientButton has proper Semantics for screen readers"
  artifacts:
    - "Semantics widgets added to key interactive elements"
```

<objective>
Add Semantics labels and accessibility attributes to navigation and CTA elements.

Purpose: Screen reader support and accessibility compliance.
Output: Key interactive widgets are semantically labeled.
</objective>

<context>
Load for context:
- lib/shared/widgets/main_shell.dart (NavigationBar destinations)
- lib/shared/widgets/gradient_button.dart (custom InkWell button)
</context>

<tasks>

<task type="auto">
  <name>Add Semantics to GradientButton</name>
  <files>lib/shared/widgets/gradient_button.dart</files>
  <action>
    1. Wrap the outer Container in `Semantics(button: true, enabled: onPressed != null, label: label, child: ...)`
    2. Add `excludeSemantics: true` on the inner Text to avoid double-reading
    3. This ensures screen readers announce the button with its label and state

    AVOID: Replacing InkWell with ElevatedButton — would break gradient styling
    AVOID: Adding focusNode — Semantics handles focus accessibility
  </action>
  <verify>`flutter analyze` clean</verify>
  <done>GradientButton accessible to screen readers</done>
</task>

<task type="auto">
  <name>Add tooltips to NavigationBar destinations</name>
  <files>lib/shared/widgets/main_shell.dart</files>
  <action>
    1. Add `tooltip` property to each NavigationDestination:
       - Home: `tooltip: 'Home — Browse templates'`
       - Create: `tooltip: 'Create — Generate AI art'`
       - Gallery: `tooltip: 'Gallery — View your creations'`
       - Settings: `tooltip: 'Settings — App preferences'`

    AVOID: Long tooltip text — keep concise and descriptive
  </action>
  <verify>`flutter analyze` clean</verify>
  <done>All 4 navigation destinations have tooltips</done>
</task>

</tasks>

<verification>
- [ ] GradientButton read by screen readers with label and state
- [ ] Navigation destinations have descriptive tooltips
- [ ] `flutter analyze` passes
</verification>

---

## Final Verification

After all 6 plans complete:

```bash
# Must all pass
flutter analyze
flutter test
```

- [ ] All 8 original items resolved (P0 × 1, P1 × 2, P2 × 3, P3 × 2)
- [ ] No new warnings or errors
- [ ] All existing tests still green
- [ ] No emoji characters in any screen text
- [ ] No hardcoded spacing values in modified files
