---
phase: 3
plan: 3
wave: 2
---

# Plan 3.3: Credit Feature Tests

## Objective
Write unit tests for the credit feature data layer, balance provider, and updated CreateViewModel credit logic. Ensures correctness before Phase 4 (ads) and Phase 5 (subscriptions) build on top.

## Context
- `lib/features/credits/data/repositories/credit_repository.dart` — Supabase credit repository from Plan 3.1
- `lib/features/credits/presentation/providers/credit_balance_provider.dart` — Balance notifier from Plan 3.1
- `lib/features/create/presentation/view_models/create_view_model.dart` — Credit pre-check from Plan 3.2
- `lib/features/template_engine/data/repositories/generation_repository.dart` — 402 handling from Plan 3.2
- `test/core/fixtures/` — Existing test fixtures
- `test/features/gallery/data/repositories/gallery_repository_test.dart` — Repository test pattern reference
- `test/features/create/presentation/view_models/create_view_model_test.dart` — Existing CreateViewModel tests

## Tasks

<task type="auto">
  <name>Unit tests for credit repository and 402 handling</name>
  <files>
    test/features/credits/data/repositories/credit_repository_test.dart (CREATE)
    test/features/template_engine/data/repositories/generation_repository_test.dart (MODIFY or CREATE)
  </files>
  <action>
    1. Create `credit_repository_test.dart`:
       - Mock `SupabaseClient` using mocktail
       - Test `fetchBalance()`:
         - Returns CreditBalance when Supabase query succeeds
         - Throws AppException.network on PostgrestException
       - Test `fetchTransactions()`:
         - Returns list of CreditTransaction with correct pagination
         - Returns empty list when no transactions
         - Throws AppException.network on PostgrestException
       - Test `watchBalance()`:
         - Emits CreditBalance on Supabase realtime update
         - At minimum test that the stream mapping works with mock data
       - Follow the existing test patterns in `test/features/gallery/data/repositories/gallery_repository_test.dart`

    2. Add tests for 402 handling in `generation_repository_test.dart`:
       - If the test file exists, add new test cases. If not, create it.
       - Test: when Edge Function returns status 402, `startGeneration()` throws `AppException.payment` with code `insufficient_credits`
       - Test: when `FunctionException` with status 402, same behavior
       - Mock the Supabase functions.invoke to return different status codes
       - Keep mock setup minimal — only cover the 402 path

    AVOID:
    - Do NOT test Supabase realtime internals — just verify the stream mapping
    - Do NOT write integration tests — unit tests only
    - Do NOT mock excessively — use simple stubs and verify behavior
  </action>
  <verify>
    flutter test test/features/credits/ — all new tests pass
    flutter test test/features/template_engine/data/repositories/ — 402 tests pass
  </verify>
  <done>
    - CreditRepository has tests for fetchBalance, watchBalance, fetchTransactions
    - GenerationRepository has tests for 402 insufficient credits handling
    - All new tests are green
    - Tests follow existing mocktail patterns
  </done>
</task>

<task type="auto">
  <name>Tests for credit balance provider and CreateViewModel credit flow</name>
  <files>
    test/features/credits/presentation/providers/credit_balance_provider_test.dart (CREATE)
    test/features/create/presentation/view_models/create_view_model_test.dart (MODIFY)
  </files>
  <action>
    1. Create `credit_balance_provider_test.dart`:
       - Use Riverpod testing patterns (ProviderContainer + overrides)
       - Mock CreditRepository
       - Test: provider emits balance from repository stream
       - Test: provider handles repository errors gracefully (AsyncError state)
       - Keep tests focused — verify the provider wiring, not the repository

    2. Modify `create_view_model_test.dart`:
       - Add test group: "credit checks"
       - Test: generate() returns error when balance < creditCost
         - Override creditBalanceNotifierProvider to return known balance
         - Select a model with creditCost higher than balance
         - Verify state is AsyncError with AppException.payment + 'insufficient_credits'
       - Test: generate() proceeds normally when balance >= creditCost
         - Override with sufficient balance
         - Verify generate flow starts (state becomes AsyncLoading)
       - If premium model tests exist, update them to verify the flow still works correctly
       - Follow existing test structure in the file

    AVOID:
    - Do NOT test UI widgets (bottom sheets) — those are visual and would need widget tests, which are lower priority
    - Do NOT duplicate repository-level tests — test provider wiring and ViewModel logic only
    - Do NOT break existing tests — run full suite after changes
  </action>
  <verify>
    flutter test test/features/credits/ — all tests pass
    flutter test test/features/create/ — all tests pass (including existing)
    flutter test — full suite passes, no regressions
  </verify>
  <done>
    - CreditBalanceNotifier has tests for normal and error states
    - CreateViewModel has tests for insufficient credit rejection
    - CreateViewModel has tests for successful credit check
    - Full flutter test suite passes with zero regressions
    - Test count increased by at least 8 new test cases
  </done>
</task>

## Success Criteria
- [ ] CreditRepository has unit tests for all 3 methods (fetchBalance, watchBalance, fetchTransactions)
- [ ] GenerationRepository has 402 handling tests
- [ ] CreditBalanceNotifier has provider wiring tests
- [ ] CreateViewModel has credit check tests (insufficient + sufficient balance)
- [ ] All new tests pass
- [ ] Full `flutter test` suite passes with zero regressions
