# Common Pitfalls

1. **Applying discounts in wrong order** - Always coupon first, then referral
2. **Trusting success redirect without verification** - Always verify via API or webhook
3. **Not handling duplicate webhooks** - Use eventId for idempotency
4. **Blocking webhook on non-critical failures** - Wrap in try-catch, log, continue
5. **Hardcoding Polar customer IDs** - Use external_id (your user ID) for lookups
6. **Not setting timeout on discount validation** - API can be slow
7. **Calculating aggregate fees as single transaction** - Each transaction has flat fee
8. **Exposing API keys client-side** - Always server-side
9. **Not preserving original amount in metadata** - Need for audit/debugging
10. **Syncing discount redemptions synchronously** - Can fail; use retry with backoff
