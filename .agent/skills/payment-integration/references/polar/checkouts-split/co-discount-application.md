# Discount Application

### Pre-apply Discount
```typescript
const session = await polar.checkouts.create({
  product_price_id: "price_xxx",
  discount_id: "discount_xxx",
  success_url: "https://example.com/success"
});
```

### Allow Customer Codes
```typescript
{
  allow_discount_codes: true // default
  // Set to false to disable code entry
}
```
