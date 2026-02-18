# Event Types

### Checkout
- `checkout.created` - Checkout session created
- `checkout.updated` - Session updated

### Order
- `order.created` - Order created (check `billing_reason`)
  - `purchase` - One-time product
  - `subscription_create` - New subscription
  - `subscription_cycle` - Renewal
  - `subscription_update` - Plan change
- `order.paid` - Payment confirmed
- `order.updated` - Order updated
- `order.refunded` - Refund processed

### Subscription
- `subscription.created` - Subscription created
- `subscription.active` - Subscription activated
- `subscription.updated` - Subscription modified
- `subscription.canceled` - Cancellation scheduled
- `subscription.revoked` - Subscription terminated

**Note:** Multiple events may fire for single action

### Customer
- `customer.created` - Customer created
- `customer.updated` - Customer modified
- `customer.deleted` - Customer deleted
- `customer.state_changed` - Benefits/subscriptions changed

### Benefit Grant
- `benefit_grant.created` - Benefit granted
- `benefit_grant.updated` - Grant modified
- `benefit_grant.revoked` - Benefit revoked

### Refund
- `refund.created` - Refund initiated
- `refund.updated` - Refund status changed

### Product
- `product.created` - Product created
- `product.updated` - Product modified
