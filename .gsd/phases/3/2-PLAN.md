---
phase: 3
plan: 2
wave: 2
---

# Plan 3.2: Credit Gate & Premium Gate UI

## Objective
Wire credit checks into the generation flow and create bottom sheets for insufficient credits and premium model gating. After this plan, users see clear, actionable UI when they can't afford generation or try to use a premium model.

## Context
- `.gsd/SPEC.md` — Credit economy, premium model gating, "Watch Ad or Subscribe" prompt
- `lib/features/create/presentation/create_screen.dart` — Current auth gate bottom sheet pattern (`_showAuthGateBottomSheet`)
- `lib/features/create/presentation/view_models/create_view_model.dart` — Current generation flow, premium check at line 87-95
- `lib/features/template_engine/data/repositories/generation_repository.dart` — Edge Function invocation, 402 handling needed at line 47-58
- `lib/core/constants/ai_models.dart` — `AiModelConfig.creditCost`, `AiModelConfig.isPremium`
- `lib/core/exceptions/app_exception.dart` — AppException variants (use `payment` for credit issues)
- `lib/core/design_system/app_spacing.dart` — Spacing constants
- `lib/features/credits/presentation/providers/credit_balance_provider.dart` — CreditBalanceNotifier from Plan 3.1
- `lib/features/credits/domain/providers/credit_repository_provider.dart` — Repository provider from Plan 3.1

## Tasks

<task type="auto">
  <name>Handle 402 insufficient credits + add credit pre-check</name>
  <files>
    lib/features/template_engine/data/repositories/generation_repository.dart (MODIFY)
    lib/features/create/presentation/view_models/create_view_model.dart (MODIFY)
  </files>
  <action>
    1. Modify `generation_repository.dart` — Add 402 handler:
       - After the `response.status == 429` check (line 47), add a `response.status == 402` check:
         ```dart
         if (response.status == 402) {
           final data = response.data is Map<String, dynamic>
               ? response.data as Map<String, dynamic>
               : null;
           final required = data?['required'] as int?;
           throw AppException.payment(
             message: 'Insufficient credits',
             code: 'insufficient_credits',
           );
         }
         ```
       - Also add 402 to the FunctionException catch block (line 70-77)

    2. Modify `create_view_model.dart` — Add client-side credit pre-check:
       - Add `creditBalanceNotifierProvider` import
       - In `generate()`, after the premium model check, add credit balance check:
         ```dart
         final balance = ref.read(creditBalanceNotifierProvider).valueOrNull?.balance ?? 0;
         if (balance < selectedModel.creditCost) {
           state = AsyncError(
             AppException.payment(
               message: 'Insufficient credits',
               code: 'insufficient_credits',
             ),
             StackTrace.current,
           );
           return;
         }
         ```
       - This is an optimistic check — the Edge Function is the authoritative enforcer (Phase 2)
       - The credit cost info is available from `selectedModel.creditCost`

    AVOID:
    - Do NOT deduct credits client-side — the Edge Function handles deduction
    - Do NOT change the existing premium model check behavior yet (keeping the error for now; Task 2 changes the UI)
    - Do NOT add retry logic for 402 — it's not a transient error
  </action>
  <verify>
    dart analyze lib/features/template_engine/data/repositories/generation_repository.dart lib/features/create/presentation/view_models/create_view_model.dart — zero errors
    flutter test — all existing tests pass
  </verify>
  <done>
    - 402 responses from Edge Function are caught and thrown as `AppException.payment` with code `insufficient_credits`
    - CreateViewModel checks credit balance before attempting generation
    - Insufficient credits prevents the Edge Function call entirely (saves a round trip)
    - All existing tests still pass
  </done>
</task>

<task type="auto">
  <name>Create InsufficientCredits and PremiumModelGate bottom sheets</name>
  <files>
    lib/features/credits/presentation/widgets/insufficient_credits_bottom_sheet.dart (CREATE)
    lib/features/credits/presentation/widgets/premium_model_gate_bottom_sheet.dart (CREATE)
    lib/features/create/presentation/create_screen.dart (MODIFY)
    lib/features/create/presentation/widgets/model_selector.dart (MODIFY)
  </files>
  <action>
    1. Create `insufficient_credits_bottom_sheet.dart`:
       - A stateless widget that shows a modal bottom sheet
       - Props: `int currentBalance`, `int requiredCredits`, `String modelName`
       - Layout:
         - Warning icon (amber)
         - "Not enough credits" title
         - "You need {required} credits but have {balance}" subtitle
         - "Watch Ad (+5 credits)" button — disabled with "Coming soon" text (Phase 4)
         - "Subscribe" button — disabled with "Coming soon" text (Phase 5)
         - "Cancel" text button
       - Static helper method: `static Future<void> show(BuildContext context, {...})` that calls `showModalBottomSheet`
       - Follow the pattern of `_showAuthGateBottomSheet` in create_screen.dart

    2. Create `premium_model_gate_bottom_sheet.dart`:
       - A stateless widget for the premium model subscription prompt
       - Props: `String modelName`
       - Layout:
         - Star/premium icon (primary color)
         - "Premium Model" title
         - "{modelName} requires a subscription" subtitle
         - "View Plans" button — disabled with "Coming soon" text (Phase 5)
         - "Use Free Model" button — pops and optionally switches to default free model
         - "Cancel" text button
       - Static helper method: `static Future<bool?> show(...)` returns true if user chose "Use Free Model"

    3. Modify `create_screen.dart`:
       - Import both bottom sheets
       - In `_handleGenerate`:
         - Add credit balance check BEFORE calling generate:
           Read `creditBalanceNotifierProvider`, get balance
           Get selected model's credit cost from `AiModels.getById(formState.modelId)`
           If `balance < creditCost` → show `InsufficientCreditsBottomSheet.show(...)` and return
         - Replace the premium model check error handling:
           Instead of letting CreateViewModel throw the error,
           check `selectedModel.isPremium && !isPremiumUser` in _handleGenerate
           and show `PremiumModelGateBottomSheet.show(...)` instead
           If user chose "Use Free Model", call `formNotifier.setModel(AiModels.defaultModelId)` and return
       - Remove the inline premium check from CreateViewModel since it's now handled in UI
       - Also handle the `AppException.payment` with code `insufficient_credits` in the error listener
         to show the bottom sheet if the server-side check catches what the client missed

    4. Modify `model_selector.dart`:
       - Show credit cost next to each model name in the dropdown/selector
       - Display format: "{modelName} • {creditCost} credits"
       - For premium models, add a small "PRO" badge or icon

    AVOID:
    - Do NOT implement actual ad watching — just show the button as disabled/coming soon
    - Do NOT implement actual subscription purchasing — just show the button as disabled/coming soon
    - Do NOT make the bottom sheets overly complex — they're placeholders that will be enhanced in Phase 4/5
    - Do NOT remove the server-side 402 handling — it's a safety net
  </action>
  <verify>
    dart analyze lib/features/credits/ lib/features/create/ — zero errors
    flutter test — all existing tests pass
  </verify>
  <done>
    - InsufficientCreditsBottomSheet shows when user lacks credits (with balance and required amount)
    - PremiumModelGateBottomSheet shows when selecting a premium model without subscription
    - "Watch Ad" and "Subscribe" buttons are visible but disabled (Phase 4/5 will enable)
    - Model selector shows credit cost per model
    - Premium models show a "PRO" indicator
    - Both bottom sheets follow the existing auth gate bottom sheet pattern
    - All existing tests still pass
  </done>
</task>

## Success Criteria
- [ ] 402 from Edge Function is caught and mapped to `AppException.payment(code: 'insufficient_credits')`
- [ ] CreateViewModel pre-checks credit balance before calling Edge Function
- [ ] InsufficientCreditsBottomSheet displays when credits are insufficient
- [ ] PremiumModelGateBottomSheet displays when selecting premium model without subscription
- [ ] Model selector shows credit cost alongside model name
- [ ] "Watch Ad" and "Subscribe" buttons exist but are disabled (coming soon)
- [ ] `dart analyze` passes with zero errors
- [ ] All existing flutter tests pass
