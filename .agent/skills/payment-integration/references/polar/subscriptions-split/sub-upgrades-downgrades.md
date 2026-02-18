# Upgrades & Downgrades

### Proration Options

**Next Invoice (default):**
- Credit/charge applied to upcoming invoice
- Subscription updates immediately
- Customer billed at next cycle

**Invoice Immediately:**
- Credit/charge processed right away
- Subscription updates immediately
- New invoice generated

```typescript
await polar.subscriptions.update(subscriptionId, {
  product_price_id: "higher_tier_price",
  proration: "invoice_immediately" // or "next_invoice"
});
```

### Customer-Initiated Changes

**Enable in Product Settings:**
- Toggle "Allow price change"
- Customer can upgrade/downgrade via portal
- Admin-only changes if disabled

**Implementation:**
```typescript
// Check if changes allowed
const product = await polar.products.get(productId);
if (product.allow_price_change) {
  // Customer can change via portal
}
```
