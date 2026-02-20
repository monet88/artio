# Milestone Audit: Security — Reward Ad SSV

**Audited:** 2026-02-20

## Summary

| Metric | Value |
|--------|-------|
| Phases | 1 |
| Plans | 3 |
| Must-haves | 16/16 verified |
| Gap closures | 0 (no gaps found) |
| Technical debt items | 3 |
| Tests | 640/640 (43 credits-specific) |
| Analyzer errors | 0 |
| Regression since completion | None |

## Must-Haves Status

| # | Requirement | Verified | Evidence |
|---|-------------|----------|----------|
| 1 | `pending_ad_rewards` table | ✅ | Migration file, deployed to prod |
| 2 | `request_ad_nonce` RPC | ✅ | SQL reviewed, deployed |
| 3 | `claim_ad_reward` RPC | ✅ | SQL reviewed, deployed |
| 4 | Existing `reward_ad_credits` untouched | ✅ | git diff empty |
| 5 | `?action=request-nonce` endpoint | ✅ | Edge Function code |
| 6 | `?action=claim` endpoint | ✅ | Edge Function code |
| 7 | Invalid action → 400 | ✅ | Code review |
| 8 | Auth logic DRY | ✅ | `authenticateUser()` helper |
| 9 | No TypeScript errors | ✅ | Deployed successfully (Supabase validates at deploy) |
| 10 | `ICreditRepository.requestAdNonce()` | ✅ | Interface method exists |
| 11 | `CreditRepository` nonce impl | ✅ | Implementation exists |
| 12 | `rewardAdCredits(nonce:)` | ✅ | Required param added |
| 13 | `setServerSideVerification()` | ✅ | Async method, correct API |
| 14 | 2-step flow in AdRewardNotifier | ✅ | 4-step flow verified |
| 15 | `flutter analyze` clean | ✅ | 0 errors (re-verified during audit) |
| 16 | `flutter test` passes | ✅ | 640/640 (re-verified during audit) |

## Strengths

1. **Security design is solid**: Nonce-based with 5-min TTL, atomic PostgreSQL UPDATE, double daily limit check (request + claim), SECURITY DEFINER with REVOKE from authenticated
2. **Clean separation of concerns**: DB layer (RPCs) → Edge Function → Flutter client, each with clear responsibilities
3. **Future-proofed**: `ServerSideVerificationOptions` already set, enabling upgrade to AdMob's official SSV callback without client changes
4. **Backward compatible**: Old `reward_ad_credits` RPC preserved for admin/fallback use
5. **Well-documented**: Research doc covers 3 options with pros/cons, architecture decision recorded in SUMMARY
6. **No gap closures needed**: All 16 must-haves passed on first verification

## Concerns

### Minor (won't block, but should be tracked)

1. **⚠️ No nonce cleanup cron**: `pending_ad_rewards` table will grow unbounded. Expired/unclaimed nonces (older than 5 min) should be periodically deleted. The `idx_pending_ad_rewards_cleanup` index exists but no scheduled job uses it yet.

2. **⚠️ Test AdMob IDs still in production code**: `rewarded_ad_service.dart` uses `ca-app-pub-3940256099942544/*` (Google test IDs). These won't serve real ads. This was a known pre-existing item from the backlog.

3. **⚠️ No Edge Function integration tests**: The Edge Function was type-checked at deploy time, but no automated tests exist for the request-nonce / claim flow. Unit tests exist only on the Flutter side.

4. **⚠️ Deno type-check not in CI**: TypeScript errors could be deployed if someone edits the Edge Function without running `deno check` locally. A CI step would catch this.

### Observations (not concerns)

- The `throwsA` / `expectLater` lesson (#2 in SUMMARY) is a valuable pattern to remember for all async Flutter tests. Consider adding to testing conventions.
- The `google_mobile_ads` API research lesson (#1) reinforces the project rule: always check Context7/docs before implementing external API calls.

## Recommendations

1. **Add nonce cleanup cron** — Create a Supabase pg_cron job or Edge Function that runs daily:
   ```sql
   DELETE FROM pending_ad_rewards WHERE created_at < now() - INTERVAL '1 hour';
   ```
   Priority: Low (table grows slowly — max 10 nonces/user/day)

2. **Replace test AdMob IDs** before production release — This is in the backlog already, but should be a blocker before any app store submission.

3. **Add Edge Function tests** — Even basic Deno tests calling the handler with mock auth would catch regressions. Could be added to Model Sync's Deno test infrastructure.

4. **Add `deno check` to CI** — A simple GitHub Action step: `deno check supabase/functions/*/index.ts`. Already in backlog.

## Technical Debt to Address

- [ ] **Nonce cleanup job** — Scheduled deletion of expired `pending_ad_rewards` rows (NEW from this milestone)
- [ ] **Replace test AdMob IDs** — `rewarded_ad_service.dart` lines 12-13 (PRE-EXISTING, from backlog)
- [ ] **Edge Function integration tests** — request-nonce + claim flow (PRE-EXISTING, from backlog)
- [ ] **Deno type-check CI step** — For all Edge Functions (PRE-EXISTING, from backlog)

## Overall Assessment

**Health: GOOD** ✅

This was a focused, well-executed security milestone. The nonce-based approach is a pragmatic middle ground between "no server validation" (insecure) and "full AdMob SSV callback" (complex). The architecture allows upgrading to Option A (AdMob SSV) later without changing the client. No gap closures were needed, indicating good planning and execution quality. The only new technical debt item (nonce cleanup) is low-priority and straightforward to implement.
