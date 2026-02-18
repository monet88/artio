# Attaching Benefits to Products

### Via API
```typescript
await polar.products.updateBenefits(productId, {
  benefits: [benefitId1, benefitId2, benefitId3]
});
```

### Via Dashboard
1. Navigate to product
2. Benefits tab
3. Select benefits to attach
4. Save

### Order
- Benefits granted in order attached
- Customers see in that order
- Reorder via dashboard or API
