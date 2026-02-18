# Checkout Approaches

### 1. Checkout Links
- Pre-configured shareable links
- Created via dashboard or API
- For marketing campaigns
- Can pre-apply discounts

**Create via API:**
```typescript
const link = await polar.checkoutLinks.create({
  product_price_id: "price_xxx",
  success_url: "https://example.com/success"
});
// Returns: link.url
```

### 2. Checkout Sessions (API)
- Programmatically created
- Server-side API call
- Dynamic workflows
- Custom logic

**Create Session:**
```typescript
const session = await polar.checkouts.create({
  product_price_id: "price_xxx",
  success_url: "https://example.com/success?checkout_id={CHECKOUT_ID}",
  customer_email: "user@example.com",
  external_customer_id: "user_123",
  metadata: {
    user_id: "123",
    source: "web"
  }
});

// Redirect to: session.url
```

**Response:**
```json
{
  "id": "checkout_xxx",
  "url": "https://polar.sh/checkout/...",
  "client_secret": "cs_xxx",
  "status": "open",
  "expires_at": "2025-01-15T10:00:00Z"
}
```

### 3. Embedded Checkout
- Inline checkout within your site
- Seamless purchase experience
- Theme customization

**Implementation:**
```html
<script src="https://polar.sh/embed.js"></script>

<div id="polar-checkout"></div>

<script>
  const checkout = await fetch('/api/create-checkout', {
    method: 'POST',
    body: JSON.stringify({ productPriceId: 'price_xxx' })
  }).then(r => r.json());

  Polar('checkout', {
    checkoutId: checkout.id,
    clientSecret: checkout.client_secret,
    onSuccess: () => {
      window.location.href = '/success';
    },
    theme: 'dark' // or 'light'
  });
</script>
```

**Server-side (create session):**
```typescript
app.post('/api/create-checkout', async (req, res) => {
  const session = await polar.checkouts.create({
    product_price_id: req.body.productPriceId,
    embed_origin: "https://example.com",
    external_customer_id: req.user.id
  });

  res.json({
    id: session.id,
    client_secret: session.client_secret
  });
});
```
