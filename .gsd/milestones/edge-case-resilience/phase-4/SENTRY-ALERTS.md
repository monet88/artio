# Sentry / Monitoring Alert Setup

## Critical Refund Failure Alert

### Context
The Edge Function `generate-image/index.ts` (via `_shared/credit_logic.ts`) logs a `[CRITICAL]` message when credit refund retries are exhausted:

```
[CRITICAL] Credit refund failed after 3 attempts. userId=..., amount=..., jobId=...
```

This means a user was charged credits but generation failed, and the automatic refund also failed. **Manual intervention is required.**

### ⚠️ Important Distinction
This log comes from **Supabase Edge Functions** (Deno runtime), NOT from the Flutter app.
- **Flutter Sentry SDK** only captures client-side exceptions
- Edge Function logs are available in **Supabase Dashboard → Edge Functions → Logs**

### Setup Options

#### Option A: Supabase Log Drain (Recommended)
1. Go to **Supabase Dashboard → Settings → Log Drains**
2. Add a log drain to your monitoring service (Datadog, Logflare, etc.)
3. Set up an alert rule for messages containing `[CRITICAL] Credit refund failed`

#### Option B: Manual Monitoring
1. Go to **Supabase Dashboard → Edge Functions → generate-image → Logs**
2. Filter for `[CRITICAL]`
3. Check periodically (at minimum daily)

#### Option C: Custom Webhook (Future)
Add a webhook call in `refundCreditsOnFailure` when all retries exhaust:
```typescript
// After the [CRITICAL] log
await fetch('https://your-alerting-webhook', {
  method: 'POST',
  body: JSON.stringify({ type: 'CRITICAL_REFUND_FAILURE', userId, amount, jobId }),
});
```

### Response Procedure
When alert fires:
1. Check `credit_transactions` table for the `jobId`
2. Verify if credits were actually deducted
3. If yes, manually issue refund via SQL: `SELECT refund_credits(userId, amount, 'Manual refund — automated retry failed', jobId)`
4. Investigate root cause (DB connection issue, RPC error, etc.)
