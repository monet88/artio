# Metadata Best Practices

### Comprehensive Audit Trail
```typescript
// Store everything needed for debugging and reconciliation
metadata: JSON.stringify({
  // Pricing history
  originalAmount: 9900,

  // Coupon tracking
  couponCode: 'LAUNCH20',
  couponDiscountAmount: 1980,

  // Referral tracking
  referralCode: 'ABC12345',
  referralDiscountAmount: 1584,
  referrerId: 'user-uuid',

  // Customer context
  githubUsername: 'customer',

  // Polar integration
  polarDiscountId: 'disc_xxx',
  polarDiscountSynced: true,
  polarDiscountSyncAction: 'decremented',
  polarDiscountSyncedAt: '2025-01-15T10:30:00Z',

  // Team context (if applicable)
  isTeamPurchase: false,
  teamId: null,
  quantity: 1,
})
```
