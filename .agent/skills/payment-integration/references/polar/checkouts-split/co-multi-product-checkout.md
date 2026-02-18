# Multi-Product Checkout

```typescript
const session = await polar.checkouts.create({
  products: [
    { product_price_id: "price_1", quantity: 1 },
    { product_price_id: "price_2", quantity: 2 }
  ],
  success_url: "https://example.com/success"
});
```
