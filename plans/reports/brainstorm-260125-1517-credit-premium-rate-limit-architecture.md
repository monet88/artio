# Brainstorm Report: Credit, Premium & Rate Limit Architecture

## Problem Statement

Three critical risks in initial architecture:

1. **Credit Desync**: Static `credits` integer requires cron reset logic, causes optimistic UI failures
2. **Premium Latency**: Async webhooks create 2-30s delay, paid users see locked features
3. **Race Conditions**: Double-tap bypasses rate limits, wastes credits/resources

---

## Agreed Solution

### A. Credits: Calculated Availability (No-Reset Model)

**Concept**: `Available = DailyLimit - COUNT(jobs WHERE created_at > today_midnight)`

| Aspect | Decision |
|--------|----------|
| Database | Ignore `credits` column. Index on `generation_jobs(user_id, created_at)` |
| Backend | Edge Function: `COUNT(*)` before execute, reject if >= limit |
| Client | Fetch `daily_count` on load, increment local counter optimistically |

**Why**: No cron jobs, no reset scripts, no sync errors. Truth derived from usage ledger.

### B. Premium: Hybrid Sync

| Layer | Mechanism |
|-------|-----------|
| Source of Truth | RevenueCat/Stripe webhook → Supabase |
| Immediate UX | Client sets `isPremiumOverride = true` on purchase callback |
| Consistency | Supabase Realtime subscription on `profiles` table |
| Security | Edge Function enforces `isPremium` check |

### C. Rate Limiting: Defense in Depth

| Layer | Implementation |
|-------|----------------|
| L1 (UX) | Button disabled on press, 10s cooldown Timer |
| L2 (API) | Edge Function leaky bucket → 429 response |

### D. Input Hygiene

| Layer | Action |
|-------|--------|
| Client | `trim()` + max 1000 chars validation |
| Backend | Sanitize to prevent injection |

---

## Implementation Changes

| Component | Change |
|-----------|--------|
| **Database** | Add index: `CREATE INDEX idx_gen_jobs_user_day ON generation_jobs(user_id, created_at)` |
| **Edge Function** | Add: `if (!user.isPremium && daily_count >= 5) throw 403` |
| **GenerationRepository** | Add `getDailyGenerationCount()` with `count()` query |
| **GenerationViewModel** | Replace `user.credits` → `dailyCount < limit`. Add cooldown Timer |
| **AuthRepository** | Add Realtime subscription for `profiles` changes |
| **UserModel** | Add computed `canGenerate` getter (optional) |

---

## Trade-offs Accepted

| Decision | Trade-off |
|----------|-----------|
| Calculated credits | +1 COUNT query per generation (negligible) |
| Realtime sub | Minor battery/network overhead on mobile |
| 10s cooldown | Slightly slower UX for power users |

---

## Success Metrics

- Zero credit desync errors
- Premium unlock < 1s perceived latency
- No duplicate generation requests
- Rate limit bypass attempts logged and blocked

---

## Next Steps

1. Create database index
2. Update Edge Function with availability check
3. Add `getDailyGenerationCount()` to repository
4. Implement cooldown in ViewModel
5. Add Realtime subscription in auth flow
6. Add RevenueCat SDK integration
