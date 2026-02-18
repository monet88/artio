# Discounts

### Apply Discount
```typescript
await polar.subscriptions.update(subscriptionId, {
  discount_id: "discount_xxx"
});
```

### Remove Discount
```typescript
await polar.subscriptions.update(subscriptionId, {
  discount_id: null
});
```

### Discount Types
- Percentage off: 20% off
- Fixed amount: $5 off
- Duration: once, forever, repeating
