# Cancellations

### Cancel at Period End
```typescript
await polar.subscriptions.update(subscriptionId, {
  cancel_at_period_end: true
});
// Subscription remains active
// Benefits continue until period end
// Webhooks: subscription.updated, subscription.canceled
```

### Immediate Revocation
```typescript
// Happens automatically at period end
// Or manually via API (future feature)
// Status changes to "revoked"
// Billing stops, benefits revoked
// Webhooks: subscription.updated, subscription.revoked
```

### Reactivate Canceled
```typescript
await polar.subscriptions.update(subscriptionId, {
  cancel_at_period_end: false
});
// Removes cancellation
// Subscription continues normally
```
