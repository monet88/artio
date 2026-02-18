# TypeScript/JavaScript

**Installation:**
```bash
npm install @polar-sh/sdk
```

**Configuration:**
```typescript
import { Polar } from '@polar-sh/sdk';

const polar = new Polar({
  accessToken: process.env.POLAR_ACCESS_TOKEN,
  server: "production" // or "sandbox"
});
```

**Usage:**
```typescript
// Products
const products = await polar.products.list({ organization_id: "org_xxx" });
const product = await polar.products.create({ name: "Pro Plan", ... });

// Checkouts
const checkout = await polar.checkouts.create({
  product_price_id: "price_xxx",
  success_url: "https://example.com/success"
});

// Subscriptions
const subs = await polar.subscriptions.list({ customer_id: "cust_xxx" });
await polar.subscriptions.update(subId, { metadata: { plan: "pro" } });

// Orders
const orders = await polar.orders.list({ organization_id: "org_xxx" });
const order = await polar.orders.get(orderId);

// Customers
const customer = await polar.customers.get({ external_id: "user_123" });

// Events (usage-based)
await polar.events.create({
  external_customer_id: "user_123",
  event_name: "api_call",
  properties: { tokens: 1000 }
});
```

**Pagination:**
```typescript
// Automatic pagination
for await (const product of polar.products.listAutoPaging()) {
  console.log(product.name);
}

// Manual pagination
let page = 1;
while (true) {
  const response = await polar.products.list({ page, limit: 100 });
  if (response.items.length === 0) break;
  // Process items
  page++;
}
```
