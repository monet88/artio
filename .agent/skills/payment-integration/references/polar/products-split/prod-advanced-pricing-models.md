# Advanced Pricing Models

### Seat-Based Pricing
- Team access with assignable seats
- Works for recurring or one-time
- Tiered pricing structures
- Customer manages seat assignments

**Configuration:**
```typescript
const product = await polar.products.create({
  name: "Team Plan",
  prices: [{
    type: "recurring",
    recurring_interval: "month",
    price_amount: 5000, // per seat
    pricing_type: "fixed"
  }],
  is_seat_based: true,
  max_seats: 100
});
```

### Usage-Based Billing

**Architecture:** Events → Meters → Metered Prices

**1. Events:** Usage data from your application
```typescript
await polar.events.create({
  external_customer_id: "user_123",
  event_name: "api_call",
  properties: {
    tokens: 1000,
    model: "gpt-4"
  }
});
```

**2. Meters:** Filter & aggregate events
```typescript
const meter = await polar.meters.create({
  name: "API Tokens",
  slug: "api_tokens",
  event_name: "api_call",
  aggregation: {
    type: "sum",
    property: "tokens"
  }
});
```

**3. Metered Prices:** Billing based on usage
```typescript
const price = await polar.products.createPrice(productId, {
  type: "metered",
  meter_id: meter.id,
  price_per_unit: 10, // 10 cents per 1000 tokens
  billing_interval: "month"
});
```

**Credits System:**
- Pre-purchased usage credits
- Credit customer's meter balance
- Use as subscription benefit
- Balance tracking API

**Ingestion Strategies:**
- LLM Strategy: AI/ML tracking
- S3 Strategy: Bulk import
- Stream Strategy: Real-time
- Delta Time Strategy: Time-based
