# Event Structure

```typescript
{
  "type": "order.paid",
  "data": {
    "id": "order_xxx",
    "amount": 2000,
    "currency": "USD",
    "billing_reason": "purchase",
    "customer": { ... },
    "product": { ... },
    "subscription": null,
    "metadata": { ... }
  }
}
```
