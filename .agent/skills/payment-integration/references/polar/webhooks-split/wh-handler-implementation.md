# Handler Implementation

### Basic Handler
```typescript
async function handleEvent(event) {
  switch (event.type) {
    case 'order.paid':
      await handleOrderPaid(event.data);
      break;

    case 'subscription.active':
      await grantAccess(event.data.customer_id);
      break;

    case 'subscription.revoked':
      await revokeAccess(event.data.customer_id);
      break;

    case 'benefit_grant.created':
      await notifyBenefitGranted(event.data);
      break;

    default:
      console.log(`Unhandled event: ${event.type}`);
  }
}
```

### Order Handler
```typescript
async function handleOrderPaid(order) {
  // Handle different billing reasons
  switch (order.billing_reason) {
    case 'purchase':
      await fulfillOneTimeOrder(order);
      break;

    case 'subscription_create':
      await handleNewSubscription(order);
      break;

    case 'subscription_cycle':
      await handleRenewal(order);
      break;

    case 'subscription_update':
      await handleUpgrade(order);
      break;
  }
}
```

### Customer State Handler
```typescript
async function handleCustomerStateChanged(customer) {
  // Customer state includes:
  // - active_subscriptions
  // - active_benefits

  const hasActiveSubscription = customer.active_subscriptions.length > 0;

  if (hasActiveSubscription) {
    await enableFeatures(customer.external_id);
  } else {
    await disableFeatures(customer.external_id);
  }
}
```
