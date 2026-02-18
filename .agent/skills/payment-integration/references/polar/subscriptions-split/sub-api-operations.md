# API Operations

### List Subscriptions
```typescript
const subscriptions = await polar.subscriptions.list({
  organization_id: "org_xxx",
  product_id: "prod_xxx",
  customer_id: "cust_xxx",
  status: "active"
});
```

### Get Subscription
```typescript
const subscription = await polar.subscriptions.get(subscriptionId);
```

### Update Subscription
```typescript
const updated = await polar.subscriptions.update(subscriptionId, {
  product_price_id: "newPriceId",
  discount_id: "discount_xxx",
  metadata: { plan: "pro" }
});
```
