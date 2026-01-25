# Phase 1: Database & Edge Function

## Context

- Parent: [plan.md](./plan.md)
- Brainstorm: `../reports/brainstorm-260125-1517-credit-premium-rate-limit-architecture.md`

## Overview

| Field | Value |
|-------|-------|
| Priority | P1 - Critical |
| Status | Pending |
| Effort | 1.5h |

Setup database index and update Edge Function with availability check.

## Key Insights

- `generation_jobs` table already tracks all generations with `user_id`, `created_at`
- Edge Function `generate-image` exists, handles 429 responses
- No SQL migrations in repo - likely managed via Supabase Dashboard

## Requirements

### Functional
- Index on `generation_jobs(user_id, created_at)` for fast COUNT queries
- Edge Function checks daily generation count before processing
- Return 403 if non-premium user exceeds daily limit (5)

### Non-Functional
- COUNT query < 50ms
- No breaking changes to existing API contract

## Architecture

```
Client → Edge Function → [CHECK: isPremium OR dailyCount < 5] → Generate
                      ↘ [FAIL: 403 Forbidden] → Return error
```

## Related Code Files

### Modify
- `supabase/functions/generate-image/index.ts` (external - Supabase Dashboard)

### Create
- `supabase/migrations/add_generation_jobs_index.sql` (documentation only)

## Implementation Steps

1. **Database Index** (Supabase Dashboard)
   ```sql
   CREATE INDEX IF NOT EXISTS idx_generation_jobs_user_day
   ON generation_jobs(user_id, created_at DESC);
   ```

2. **Edge Function Update** (Supabase Dashboard)
   ```typescript
   // Add at start of handler, after auth check
   const { data: profile } = await supabaseClient
     .from('profiles')
     .select('is_premium')
     .eq('id', user.id)
     .single();

   if (!profile?.is_premium) {
     const today = new Date();
     today.setHours(0, 0, 0, 0);

     const { count } = await supabaseClient
       .from('generation_jobs')
       .select('*', { count: 'exact', head: true })
       .eq('user_id', user.id)
       .gte('created_at', today.toISOString());

     const DAILY_LIMIT = 5;
     if ((count ?? 0) >= DAILY_LIMIT) {
       return new Response(
         JSON.stringify({ error: 'Daily limit reached. Upgrade to Premium for unlimited.' }),
         { status: 403 }
       );
     }
   }
   ```

3. **Handle 403 in Client** - Already handled by `AppException.generation`

## Todo List

- [ ] Create index via Supabase Dashboard SQL Editor
- [ ] Update Edge Function with availability check
- [ ] Test: Free user at limit gets 403
- [ ] Test: Premium user bypasses limit
- [ ] Test: Free user under limit can generate

## Success Criteria

- [ ] Index exists and speeds up COUNT query
- [ ] Non-premium users blocked at 5 generations/day
- [ ] Premium users unlimited
- [ ] Existing generation flow unaffected

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Edge Function deploy fails | Test in staging first |
| Timezone issues | Use UTC in both client and server |
| Index bloat | Use partial index if needed later |

## Security Considerations

- Server-side enforcement only (client checks are UX, not security)
- Never trust client-reported `isPremium` status
- Rate limit applies per user, not per session

## Next Steps

→ Phase 2: Credit Availability System (client-side)
