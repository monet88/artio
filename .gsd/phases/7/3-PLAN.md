---
phase: 7
plan: 3
wave: 1
---

# Plan 7.3: Paywall Error Handling Cleanup

## Objective
Fix the 2 remaining P3 issues in the paywall screen — overly broad catch clause and redundant error handling logic.

## Context
- `.gsd/ROADMAP.md` — Phase 7 task list
- `lib/features/subscription/presentation/screens/paywall_screen.dart`

## Tasks

<task type="auto">
  <name>Narrow _handlePurchase catch and simplify _handleRestore</name>
  <files>lib/features/subscription/presentation/screens/paywall_screen.dart</files>
  <action>
    Two changes in the same file:

    1. **`_handlePurchase`** (line 178): Replace `on Object catch (_)` with `on Exception catch (_)`.
       This prevents swallowing programming errors (e.g., null reference, assertion failures)
       while still catching all expected exceptions from the repository layer.

    2. **`_handleRestore`** (lines 189-221): Simplify the error handling.
       The `AsyncValue.guard()` in the notifier catches errors into state, so `restore()` itself
       never throws. The outer try/catch is unnecessary. Refactor to:

       ```dart
       Future<void> _handleRestore() async {
         setState(() => _isPurchasing = true);
         await ref.read(subscriptionNotifierProvider.notifier).restore();
         if (!mounted) return;
         final subscriptionState = ref.read(subscriptionNotifierProvider);
         if (subscriptionState.hasError) {
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text('Restore failed. Please try again.')),
           );
         } else {
           final status = subscriptionState.valueOrNull;
           if (status != null && status.isActive) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('Purchases restored!')),
             );
             context.pop();
           } else {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text('No previous purchases found.')),
             );
           }
         }
         if (mounted) setState(() => _isPurchasing = false);
       }
       ```

    - Do NOT change the snackbar text or behavior
    - Do NOT change the purchase flow logic
    - The restore method in the notifier uses `AsyncValue.guard()` which never throws,
      so removing the try/catch is safe
  </action>
  <verify>grep -n "on Object\|on Exception" lib/features/subscription/presentation/screens/paywall_screen.dart</verify>
  <done>`_handlePurchase` catches `Exception` only; `_handleRestore` has no redundant try/catch</done>
</task>

## Success Criteria
- [ ] `_handlePurchase` catches `on Exception` (not `on Object`)
- [ ] `_handleRestore` has no try/catch wrapper (errors handled via state)
- [ ] `dart analyze` clean
- [ ] Paywall tests still pass
