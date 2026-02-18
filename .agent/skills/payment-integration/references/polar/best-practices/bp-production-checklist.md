# Production Checklist

- [ ] Environment variables configured in all environments
- [ ] Sandbox testing completed for all checkout flows
- [ ] Production API key obtained and secured
- [ ] Webhook endpoint deployed and reachable
- [ ] Webhook signature verification implemented
- [ ] Idempotency handling tested with duplicate webhooks
- [ ] Fee calculations verified against Polar dashboard
- [ ] Discount validation timeout configured
- [ ] Error monitoring enabled (Sentry, etc.)
- [ ] Structured logging in place
- [ ] Database indexes on orders.status, orders.paymentProvider
- [ ] Revenue caching configured
- [ ] Rate limit handling implemented
- [ ] Fail-open patterns for non-critical operations
- [ ] Customer email notifications working
- [ ] Refund flow tested end-to-end
- [ ] GitHub access grant/revoke tested
- [ ] Discord sales notifications configured
