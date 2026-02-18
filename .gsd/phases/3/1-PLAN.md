---
phase: 3
plan: 1
wave: 1
---

# Plan 3.1: Credit Feature Foundation (Data + Balance Provider)

## Objective
Create the `credits/` feature module with Clean Architecture layers and a realtime credit balance provider. This is the foundation that Plan 3.2 (gate UI) and Plan 3.3 (tests) depend on.

## Context
- `.gsd/SPEC.md` — Credit economy rules, welcome bonus, ad rewards
- `.gsd/ARCHITECTURE.md` — Clean Architecture per feature pattern
- `lib/core/providers/supabase_provider.dart` — Supabase client provider pattern
- `lib/features/gallery/data/repositories/gallery_repository.dart` — Repository + `@riverpod` provider pattern
- `lib/features/gallery/domain/repositories/i_gallery_repository.dart` — Interface pattern
- `lib/features/gallery/domain/providers/gallery_repository_provider.dart` — Barrel export pattern
- `lib/features/auth/domain/entities/user_model.dart` — Freezed entity pattern
- `lib/core/exceptions/app_exception.dart` — AppException variants
- `.gsd/phases/2/1-SUMMARY.md` — DB schema: `user_credits` (user_id PK, balance, updated_at), `credit_transactions`, `ad_views`

## Tasks

<task type="auto">
  <name>Create credit feature skeleton (entity + repository)</name>
  <files>
    lib/features/credits/domain/entities/credit_balance.dart (CREATE)
    lib/features/credits/domain/entities/credit_transaction.dart (CREATE)
    lib/features/credits/domain/repositories/i_credit_repository.dart (CREATE)
    lib/features/credits/data/repositories/credit_repository.dart (CREATE)
    lib/features/credits/domain/providers/credit_repository_provider.dart (CREATE)
  </files>
  <action>
    1. Create `credit_balance.dart` — Freezed entity:
       - Fields: `String userId`, `int balance`, `DateTime updatedAt`
       - Factory: `CreditBalance.fromJson`
       - Run build_runner after creating

    2. Create `credit_transaction.dart` — Freezed entity:
       - Fields: `String id`, `String userId`, `int amount`, `String type`, `String? referenceId`, `DateTime createdAt`
       - Factory: `CreditTransaction.fromJson`
       - `type` values: 'generation', 'welcome_bonus', 'ad_reward', 'subscription', 'refund', 'manual'

    3. Create `i_credit_repository.dart` — Abstract interface:
       - `Future<CreditBalance> fetchBalance()` — Fetch current user's credit balance
       - `Stream<CreditBalance> watchBalance()` — Realtime stream of user_credits changes
       - `Future<List<CreditTransaction>> fetchTransactions({int limit, int offset})` — Transaction history with pagination

    4. Create `credit_repository.dart` — Supabase implementation:
       - Constructor takes `SupabaseClient`
       - `@riverpod` provider function: `CreditRepository creditRepository(Ref ref) => CreditRepository(ref.watch(supabaseClientProvider))`
       - `fetchBalance()`:
         - Query `user_credits` table, `.select().single()`
         - RLS ensures only own data returned (no userId filter needed)
         - Wrap in try/catch, throw `AppException.network` on `PostgrestException`
       - `watchBalance()`:
         - Use `.stream(primaryKey: ['user_id'])` on `user_credits` table
         - Map each event to `CreditBalance.fromJson`
         - Note: RLS filters to own user's row automatically
       - `fetchTransactions()`:
         - Query `credit_transactions` table, ordered by `created_at` desc
         - Apply `.range(offset, offset + limit - 1)`

    5. Create `credit_repository_provider.dart` — Barrel export:
       - `export 'package:artio/features/credits/data/repositories/credit_repository.dart' show creditRepositoryProvider;`

    Run `dart run build_runner build --delete-conflicting-outputs` after creating all files.

    AVOID:
    - Do NOT add ad-watching or deduction methods — the Edge Function handles deduction (Phase 2), and ads are Phase 4
    - Do NOT add a CreditService/Policy class — keep it simple, the repository is enough for now
  </action>
  <verify>
    dart analyze lib/features/credits/ — zero errors
    Confirm generated files exist: credit_balance.freezed.dart, credit_balance.g.dart, credit_transaction.freezed.dart, credit_transaction.g.dart, credit_repository.g.dart
  </verify>
  <done>
    - CreditBalance and CreditTransaction freezed entities compile
    - ICreditRepository interface defines 3 methods (fetchBalance, watchBalance, fetchTransactions)
    - CreditRepository implements all 3 methods with Supabase queries
    - creditRepositoryProvider is exported and available via barrel
    - `dart analyze lib/features/credits/` has zero errors
  </done>
</task>

<task type="auto">
  <name>Create CreditBalanceNotifier + display balance in CreateScreen</name>
  <files>
    lib/features/credits/presentation/providers/credit_balance_provider.dart (CREATE)
    lib/features/create/presentation/create_screen.dart (MODIFY)
  </files>
  <action>
    1. Create `credit_balance_provider.dart` — Riverpod StreamNotifier:
       - Use `@riverpod` annotation
       - Class `CreditBalanceNotifier extends _$CreditBalanceNotifier`
       - `build()` method:
         - Read `creditRepositoryProvider` to get repo
         - Return `repo.watchBalance()` stream
         - This gives `AsyncValue<CreditBalance>` to consumers
       - Add a convenience getter: `int? get currentBalance => state.valueOrNull?.balance`

    2. Modify `create_screen.dart` — Show credit balance:
       - Import the credit balance provider
       - In `build()`, watch `creditBalanceNotifierProvider` to get `AsyncValue<CreditBalance>`
       - Only show balance if user is authenticated (check authState first)
       - Add a small balance chip/indicator between the title section and the generate button area
       - Display format: "💎 {balance} credits" — use a `Chip` or small `Container` with the credit icon
       - For loading state: show a small shimmer or "..." placeholder
       - For error state: show nothing (fail silently — balance display is non-critical)
       - Do NOT block generation based on balance here (that's Plan 3.2)

    Run `dart run build_runner build --delete-conflicting-outputs` after.

    AVOID:
    - Do NOT add balance to the AppBar — keep it contextual to the Create screen for now
    - Do NOT add credit check logic to _handleGenerate yet (Plan 3.2)
    - Do NOT create a separate widget file for the balance display — it's a simple Chip, inline is fine
  </action>
  <verify>
    dart analyze lib/features/credits/ lib/features/create/ — zero errors
    flutter test — all existing tests pass (no regressions)
  </verify>
  <done>
    - CreditBalanceNotifier provider compiles and watches user_credits realtime
    - CreateScreen shows credit balance for authenticated users
    - Credit balance auto-updates when user_credits table changes
    - All existing tests still pass
  </done>
</task>

## Success Criteria
- [ ] `lib/features/credits/` directory exists with data/domain/presentation layers
- [ ] CreditBalance and CreditTransaction entities are freezed and compile
- [ ] CreditRepository queries Supabase user_credits and credit_transactions tables
- [ ] CreditBalanceNotifier streams realtime balance changes
- [ ] CreateScreen displays current credit balance for authenticated users
- [ ] `dart analyze` passes with zero errors on credits and create features
- [ ] All existing flutter tests pass (no regressions)
