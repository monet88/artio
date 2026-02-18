# Common Pitfalls

1. **Not handling bank dash-stripping** - Banks may remove dashes from UUIDs
2. **Rejecting overpayments** - Should accept; customer paid more
3. **Blocking webhook on non-critical failures** - Wrap in try-catch, continue
4. **Not using timing-safe comparison** - Vulnerable to timing attacks
5. **Returning non-200 on error** - Causes SePay retry loops
6. **Using raw exchange rates without fallback** - API can fail
7. **Applying discounts in wrong order** - Always coupon first, then referral
8. **Not logging matchMethod** - Hard to debug failed matches
9. **Not preserving checkout metadata** - Lose discount audit trail
10. **Synchronous Polar discount sync** - Can fail; use retry with backoff
11. **Case-sensitive content matching** - Banks may uppercase/lowercase
12. **Missing amount-only match safety** - Reject ambiguous matches
