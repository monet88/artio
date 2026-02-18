# Node.js SDK (sepay-pg-node)

**Installation:**
```bash
npm install github:sepay/sepay-pg-node
```

**Requirements:** Node.js 16+

**Configuration:**
```javascript
import { SePayPgClient } from 'sepay-pg-node';

const client = new SePayPgClient({
  env: 'sandbox',  // or 'production'
  merchant_id: 'SP-TEST-XXXXXXX',
  secret_key: 'spsk_test_xxxxxxxxxxxxx',
});
```

**Create Payment:**
```javascript
const fields = client.checkout.initOneTimePaymentFields({
  operation: 'PURCHASE',
  order_invoice_number: 'DH0001',
  order_amount: 10000,
  currency: 'VND',
  success_url: 'https://example.com/success',
  error_url: 'https://example.com/error',
  cancel_url: 'https://example.com/cancel',
  order_description: 'Payment for order DH0001',
});
```

**Render Payment Form:**
```jsx
<form action={client.checkout.initCheckoutUrl()} method="POST">
  {Object.keys(fields).map(field =>
    <input type="hidden" name={field} value={fields[field]} key={field} />
  )}
  <button type="submit">Pay Now</button>
</form>
```

**API Methods:**
```javascript
// List all orders
await client.order.all({
  per_page: 50,
  q: 'search_term',
  order_status: 'completed',
  from_created_at: '2025-01-01',
  to_created_at: '2025-01-31'
});

// Get order details
await client.order.retrieve('DH0001');

// Void transaction (cards only)
await client.order.voidTransaction('DH0001');

// Cancel order (QR payments)
await client.order.cancel('DH0001');
```

**Endpoints:**
- Sandbox: `https://sandbox.pay.sepay.vn/v1/init`
- Production: `https://pay.sepay.vn/v1/init`
