# Edge Case Fixes Implementation Plan

**Created:** 2026-02-20
**Updated:** 2026-02-20 (post-discussion, verified against codebase)
**Status:** Approved
**Priority:** Critical + High
**Decisions:** `.gsd/DECISIONS.md` (2026-02-20)

---

## Overview

Implementation plan for fixing 7 edge cases identified during parallel code review.
Issue 1.4 (Session Expiry Handling) deferred — Supabase SDK auto-refresh is sufficient.

**Execution strategy:** 3 PRs grouped by file area:
1. **PR #1: Auth fixes** — input validation + OAuth timeout (issues 2.2, 2.3)
2. **PR #2: Credit fixes** — policy, provider disposal, stream recovery (issues 1.1, 1.3, 2.4)
3. **PR #3: Edge Function fixes** — refund retry, premium enforcement (issues 1.2, 2.1)

See reports in `plans/reports/` for detailed analysis.

---

## PR #1: Auth Fixes (issues 2.2, 2.3)

### 2.2 Empty Input Validation

**Files to modify:**
- `lib/features/auth/presentation/view_models/auth_view_model.dart`

**Implementation:**

Update `signInWithEmail` (lines 83-94):
```dart
Future<void> signInWithEmail(String email, String password) async {
  // Input validation before state change
  if (email.trim().isEmpty) {
    state = const AuthState.error('Email is required');
    return;
  }
  if (password.isEmpty) {
    state = const AuthState.error('Password is required');
    return;
  }

  if (state is AuthStateAuthenticating) return;
  state = const AuthState.authenticating();
  try {
    final authRepo = ref.read(authRepositoryProvider);
    final user = await authRepo.signInWithEmail(email, password);
    state = AuthState.authenticated(user);
    _notifyRouter();
  } on Exception catch (e) {
    state = AuthState.error(_parseErrorMessage(e));
  }
}
```

Update `signUpWithEmail` (lines 96-107):
```dart
Future<void> signUpWithEmail(String email, String password) async {
  // Input validation before state change
  if (email.trim().isEmpty) {
    state = const AuthState.error('Email is required');
    return;
  }
  if (password.isEmpty) {
    state = const AuthState.error('Password is required');
    return;
  }
  if (password.length < 6) {
    state = const AuthState.error('Password must be at least 6 characters');
    return;
  }

  if (state is AuthStateAuthenticating) return;
  state = const AuthState.authenticating();
  try {
    final authRepo = ref.read(authRepositoryProvider);
    final user = await authRepo.signUpWithEmail(email, password);
    state = AuthState.authenticated(user);
    _notifyRouter();
  } on Exception catch (e) {
    state = AuthState.error(_parseErrorMessage(e));
  }
}
```

**Verification:**
- Widget test: Empty email shows error
- Widget test: Empty password shows error
- Widget test: Short password shows error on sign up

---

### 2.3 OAuth Timeout Mechanism

**Files to modify:**
- `lib/features/auth/presentation/view_models/auth_view_model.dart`

**Implementation:**

Add fields to `AuthViewModel`:
```dart
Timer? _oauthTimeoutTimer;
static const _oauthTimeoutDuration = Duration(minutes: 3);
```

Update `signInWithGoogle()` (lines 109-118):
```dart
Future<void> signInWithGoogle() async {
  if (state is AuthStateAuthenticating) return;
  state = const AuthState.authenticating();

  // Start timeout timer
  _oauthTimeoutTimer?.cancel();
  _oauthTimeoutTimer = Timer(
    _oauthTimeoutDuration,
    () {
      if (state is AuthStateAuthenticating) {
        state = const AuthState.error(
          'Sign in timed out. Please try again.',
        );
      }
    },
  );

  try {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.signInWithGoogle();
    // Timer will be cancelled when auth state changes via stream
  } on Exception catch (e) {
    _oauthTimeoutTimer?.cancel();
    state = AuthState.error(_parseErrorMessage(e));
  }
}
```

Update `build()` dispose (line 44):
```dart
ref.onDispose(() {
  _authSubscription?.cancel();
  _oauthTimeoutTimer?.cancel();
});
```

Update auth state change listener (lines 29-41) to cancel timer:
```dart
_authSubscription = authRepo.onAuthStateChange.listen(
  (data) {
    _oauthTimeoutTimer?.cancel(); // Cancel on auth state change
    if (data.session != null) {
      _handleSignedIn();
    } else {
      state = const AuthState.unauthenticated();
      _notifyRouter();
    }
  },
  onError: (Object e, StackTrace st) async {
    await SentryConfig.captureException(e, stackTrace: st);
  },
);
```

**Verification:**
- Unit test: State resets to error after 3 minutes of authenticating
- Unit test: Timer cancelled on successful auth

---

## PR #2: Credit Fixes (issues 1.1, 1.3, 2.4)

### 1.1 GenerationViewModel Credit Pre-Check

**Issue:** `GenerationViewModel` lacks credit balance check before generation.
`FreeBetaPolicy` always returns `allowed(remainingCredits: 999)` — a stub.

**Files to modify:**
- `lib/features/template_engine/data/policies/credit_check_policy.dart` — NEW file
- `lib/features/template_engine/presentation/providers/generation_policy_provider.dart` — switch to new policy

**Files to delete:**
- `lib/features/template_engine/data/policies/free_beta_policy.dart` — dead code after replacement

**Implementation:**

Create `CreditCheckPolicy` replacing `FreeBetaPolicy`:
```dart
// lib/features/template_engine/data/policies/credit_check_policy.dart (NEW)
import 'package:artio/features/credits/presentation/providers/credit_balance_provider.dart';
import 'package:artio/features/template_engine/domain/policies/generation_policy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreditCheckPolicy implements IGenerationPolicy {
  const CreditCheckPolicy(this._ref);
  final Ref _ref;

  @override
  Future<GenerationEligibility> canGenerate({
    required String userId,
    required String templateId,
  }) async {
    final creditState = _ref.read(creditBalanceNotifierProvider);
    final balance = creditState.valueOrNull?.balance;

    // If credits haven't loaded yet, allow (server will enforce)
    if (balance == null) {
      return const GenerationEligibility.allowed();
    }

    // Minimum cost is 4 credits (imagen4-fast). Exact cost is enforced
    // server-side in the Edge Function via MODEL_CREDIT_COSTS map.
    const minimumCost = 4;
    if (balance < minimumCost) {
      return const GenerationEligibility.denied(
        reason: 'Insufficient credits',
      );
    }

    return GenerationEligibility.allowed(remainingCredits: balance);
  }
}
```

Update the policy provider:
```dart
// lib/features/template_engine/presentation/providers/generation_policy_provider.dart
import 'package:artio/features/template_engine/data/policies/credit_check_policy.dart';
import 'package:artio/features/template_engine/domain/policies/generation_policy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generation_policy_provider.g.dart';

@riverpod
IGenerationPolicy generationPolicy(Ref ref) {
  return CreditCheckPolicy(ref);
}
```

Delete `free_beta_policy.dart` and remove any imports referencing it.

**Note:** No changes to `GenerationViewModel` — it already calls
`policy.canGenerate()` and checks `eligibility.isDenied`.

**Verification:**
- Unit test: `CreditCheckPolicy` returns `denied` when balance < 4
- Unit test: `CreditCheckPolicy` returns `allowed` when balance >= 4
- Unit test: `CreditCheckPolicy` returns `allowed` when balance is null

---

### 1.3 Provider Disposal on Logout

**Issue:** `creditBalanceNotifierProvider` not invalidated on logout.

**Files to modify:**
- `lib/core/state/user_scoped_providers.dart`

**Implementation:**

Add credit provider invalidation to the existing cascade:
```dart
import 'package:artio/core/state/credit_balance_state_provider.dart';
import 'package:artio/features/create/presentation/providers/create_form_provider.dart';
import 'package:artio/features/create/presentation/view_models/create_view_model.dart';
import 'package:artio/features/gallery/presentation/providers/gallery_provider.dart';
import 'package:artio/features/template_engine/presentation/providers/template_provider.dart';
import 'package:artio/features/template_engine/presentation/view_models/generation_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Invalidates all providers scoped to the current user session.
/// Call on sign-out to prevent stale data on re-login.
void invalidateUserScopedProviders(Ref ref) {
  ref
    ..invalidate(galleryStreamProvider)
    ..invalidate(galleryActionsNotifierProvider)
    ..invalidate(templatesProvider)
    ..invalidate(generationViewModelProvider)
    ..invalidate(createViewModelProvider)
    ..invalidate(createFormNotifierProvider)
    ..invalidate(creditBalanceNotifierProvider); // ADD: prevent stale credits
}
```

**Verification:**
- Integration test: Login as User A, logout, login as User B
- Verify User B sees User B's credits, not User A's

---

### 2.4 Credit Stream Error Recovery

**Issue:** `watchBalance()` throws when `user_credits` row doesn't exist; no error recovery.

**Files to modify:**
- `lib/features/credits/data/repositories/credit_repository.dart`

**Implementation:**

Update `watchBalance()` (lines 39-49):
```dart
@override
Stream<CreditBalance> watchBalance() {
  return _supabase
      .from('user_credits')
      .stream(primaryKey: ['user_id'])
      .map((rows) {
    if (rows.isEmpty) {
      // Return default balance instead of throwing.
      // The user_credits row may not exist yet (race condition
      // between signup trigger and first stream event).
      return const CreditBalance(balance: 0);
    }
    return CreditBalance.fromJson(rows.first);
  }).handleError(
    (Object error, StackTrace stackTrace) {
      // Log but don't kill the stream — Supabase realtime
      // will reconnect automatically on transient failures.
      SentryConfig.captureException(error, stackTrace: stackTrace);
    },
  );
}
```

**Dependencies:**
- Import `sentry_config.dart`

**Verification:**
- Test stream behavior when `user_credits` row doesn't exist → returns balance 0
- Test that stream continues after a transient error

---

## PR #3: Edge Function Fixes (issues 1.2, 2.1)

### 1.2 Credit Refund Retry Logic

**Issue:** Refund is best-effort with no retry mechanism.

**Files to modify:**
- `supabase/functions/generate-image/index.ts`

**Implementation:**

Replace `refundCreditsOnFailure` (lines 126-148) with retry logic:
```typescript
async function refundCreditsOnFailure(
  supabase: ReturnType<typeof getSupabaseClient>,
  userId: string,
  amount: number,
  jobId: string,
  maxRetries: number = 3
): Promise<{ success: boolean; attempts: number }> {
  let lastError: Error | null = null;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const { error } = await supabase.rpc("refund_credits", {
        p_user_id: userId,
        p_amount: amount,
        p_description: "Generation failed — refund",
        p_reference_id: jobId,
      });

      if (error) {
        lastError = new Error(error.message);
        console.error(`[${jobId}] Refund attempt ${attempt}/${maxRetries} failed:`, error);

        if (attempt < maxRetries) {
          await new Promise(r => setTimeout(r, Math.pow(2, attempt) * 1000));
        }
        continue;
      }

      console.log(`[${jobId}] Refunded ${amount} credits on attempt ${attempt}`);
      return { success: true, attempts: attempt };
    } catch (err) {
      lastError = err instanceof Error ? err : new Error(String(err));
      console.error(`[${jobId}] Refund attempt ${attempt}/${maxRetries} exception:`, err);

      if (attempt < maxRetries) {
        await new Promise(r => setTimeout(r, Math.pow(2, attempt) * 1000));
      }
    }
  }

  // All retries exhausted - log for manual reconciliation
  console.error(`[${jobId}] CRITICAL: Refund failed after ${maxRetries} attempts`, {
    userId,
    amount,
    jobId,
    lastError: lastError?.message
  });

  return { success: false, attempts: maxRetries };
}
```

**Note:** All 4 call sites `await` the function without consuming the return
value, so the return type change is safe.

**Verification:**
- Test refund with simulated RPC failure
- Verify exponential backoff timing
- Verify logging on final failure

---

### 2.1 Server-Side Premium Enforcement

**Files to modify:**
- `supabase/functions/generate-image/index.ts`

**Implementation:**

Add premium check BEFORE credit deduction (after line 443 — unknown model check):
```typescript
// Check premium requirement for premium models
const PREMIUM_MODELS = [
  'google/imagen4-ultra',
  'google/pro-image-to-image',
  'flux-2/pro-text-to-image',
  'flux-2/pro-image-to-image',
  'gpt-image/1.5-text-to-image',
  'gpt-image/1.5-image-to-image',
];

if (PREMIUM_MODELS.includes(model)) {
  const { data: profile } = await supabase
    .from('profiles')
    .select('is_premium')
    .eq('id', userId)
    .single();

  if (!profile?.is_premium) {
    return new Response(
      JSON.stringify({
        error: 'This model requires a premium subscription',
        model,
        premiumRequired: true
      }),
      { status: 403, headers: { ...headers, "Content-Type": "application/json" } }
    );
  }
}
```

**Note:** Premium check goes BEFORE credit deduction — no credits are touched
if the user isn't premium. This avoids unnecessary deduct+refund transactions.

**Verification:**
- Test non-premium user calling premium model directly
- Verify 403 response with clear error
- Verify NO credit deduction occurs

---

## Deferred Issues

### ~~1.4 Session Expiry Handling~~ — DEFERRED

**Reason:** Supabase SDK handles auto-refresh natively. Adding manual
`ensureValidSession()` is redundant. If session truly expires, API calls
return 401 which is already handled at the repository layer.

**Revisit if:** Users report session-related errors in Sentry.

---

## Testing Strategy

### Unit Tests (per PR)
1. **PR #1:** `AuthViewModel` input validation, OAuth timeout timer
2. **PR #2:** `CreditCheckPolicy` denied/allowed, stream error recovery
3. **PR #3:** Refund retry (simulated RPC failure)

### Integration Tests
1. Logout/login credit isolation (PR #2)
2. Premium model enforcement — 403 response (PR #3)

### Manual Tests
1. OAuth timeout scenario (PR #1)
2. Credit refund with network failure (PR #3)

---

## Risk Assessment

| Fix | Risk | Mitigation |
|-----|------|------------|
| Input validation (2.2) | Low — pure client-side | Widget tests |
| OAuth timeout (2.3) | Low — additive timer | Unit test timer |
| Credit pre-check (1.1) | Low — uses existing pattern | Unit tests for policy |
| Provider disposal (1.3) | Medium — may cause brief re-fetch | Test rapid login/logout |
| Credit stream (2.4) | Low — replaces throw with default | Test empty rows |
| Refund retry (1.2) | Low — additive change | Return type safe |
| Premium enforce (2.1) | Low — server-side, before deduction | Direct API test |

---

## Estimated Effort

| PR | Issues | Complexity |
|----|--------|------------|
| PR #1: Auth | 2.2, 2.3 | 1-2 hours |
| PR #2: Credits | 1.1, 1.3, 2.4 | 2-3 hours |
| PR #3: Edge Func | 1.2, 2.1 | 2-3 hours |
| **Total** | 7 issues | 5-8 hours |

---

## Execution Order

```
PR #1 (Auth) ──→ PR #2 (Credits) ──→ PR #3 (Edge Func)
  No deps          No deps on #1       No deps on #1/#2
```

All 3 PRs are independent — can be executed in parallel if desired.

---

## Success Criteria

1. All 7 edge case issues resolved
2. Unit tests pass for all changes
3. No regressions in existing flows
4. `flutter analyze` — 0 issues
5. `FreeBetaPolicy` deleted, no orphan imports

---

## References

- Reports: `plans/reports/code-reviewer-260220-0849-*.md`
- Decisions: `.gsd/DECISIONS.md`
- Codebase summary: `docs/codebase-summary.md`
