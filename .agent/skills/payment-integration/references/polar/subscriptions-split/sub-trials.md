# Trials

### Configuration

**Product-level:**
```typescript
const product = await polar.products.create({
  name: "Pro Plan",
  prices: [{
    trial_period_days: 14
  }]
});
```

**Checkout-level:**
```typescript
const session = await polar.checkouts.create({
  product_price_id: "price_xxx",
  trial_period_days: 7 // Overrides product setting
});
```

### Trial Behavior
- Customer not charged during trial
- Benefits granted immediately
- Can cancel anytime during trial
- Charged at trial end if not canceled

### Trial Events
```typescript
// Listen to webhooks
subscription.created // Trial starts
subscription.active // Trial ends, first charge
subscription.canceled // Trial canceled
```
