# Production Checklist

- [ ] Environment variables configured
- [ ] Bank account verified and active
- [ ] Webhook endpoint publicly accessible (HTTPS)
- [ ] Webhook API key set and verified
- [ ] Timing-safe auth comparison implemented
- [ ] Idempotency handling tested with duplicate webhooks
- [ ] UUID parsing tested with real Vietnamese bank memos
- [ ] Amount validation (underpayment rejection) tested
- [ ] Overpayment handling verified
- [ ] Currency conversion fallback chain tested
- [ ] Invoice email template tested
- [ ] Error monitoring enabled
- [ ] Structured logging in place
- [ ] Database indexes created
- [ ] Polar discount sync tested (for shared coupons)
- [ ] Team payment ID format tested
- [ ] Non-blocking operations wrapped in try-catch
- [ ] Always-200 webhook response verified
