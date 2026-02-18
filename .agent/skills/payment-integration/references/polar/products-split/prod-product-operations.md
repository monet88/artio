# Product Operations

### Create Product
```typescript
const product = await polar.products.create({
  organization_id: "org_xxx",
  name: "Pro Plan",
  description: "Professional features",
  prices: [{
    type: "recurring",
    recurring_interval: "month",
    price_amount: 2000,
    pricing_type: "fixed"
  }]
});
```

### List Products
```typescript
const products = await polar.products.list({
  organization_id: "org_xxx",
  is_archived: false
});
```

### Update Product
```typescript
const product = await polar.products.update(productId, {
  name: "Pro Plan Updated",
  description: "New description"
});
```

### Archive Product
```typescript
await polar.products.archive(productId);
// Products can be unarchived later
// Cannot be deleted (maintains order history)
```

### Update Benefits
```typescript
await polar.products.updateBenefits(productId, {
  benefits: [benefitId1, benefitId2]
});
```
