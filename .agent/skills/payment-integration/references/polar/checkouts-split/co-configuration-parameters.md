# Configuration Parameters

### Required
- `product_price_id` - Product to checkout (or `products` array for multiple)
- `success_url` - Post-payment redirect (absolute URL)

### Optional
- `external_customer_id` - Your user ID mapping
- `embed_origin` - For embedded checkouts
- `customer_email` - Pre-fill email
- `customer_name` - Pre-fill name
- `discount_id` - Pre-apply discount code
- `allow_discount_codes` - Allow customer to enter codes (default: true)
- `metadata` - Custom data (key-value)
- `custom_field_data` - Pre-fill custom fields
- `customer_billing_address` - Pre-fill billing address

### Success URL Placeholder
```typescript
{
  success_url: "https://example.com/success?checkout_id={CHECKOUT_ID}"
}
// Polar replaces {CHECKOUT_ID} with actual checkout ID
```
