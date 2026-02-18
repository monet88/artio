# Product Features

### Metadata
```typescript
const product = await polar.products.create({
  name: "Pro Plan",
  metadata: {
    feature_x: "enabled",
    tier: "pro",
    custom_field: "value"
  }
});
```

### Custom Fields
```typescript
const product = await polar.products.create({
  name: "Enterprise Plan",
  custom_fields: [
    {
      slug: "company_name",
      label: "Company Name",
      type: "text",
      required: true
    },
    {
      slug: "employees",
      label: "Number of Employees",
      type: "number"
    }
  ]
});
```

Data collected at checkout, accessible via Orders/Subscriptions API in `custom_field_data`.

### Trials
- Set on recurring products
- Customer not charged during trial
- Benefits granted immediately
- Configure at product or checkout level

```typescript
const product = await polar.products.create({
  name: "Pro Plan",
  prices: [{
    type: "recurring",
    recurring_interval: "month",
    price_amount: 2000,
    trial_period_days: 14
  }]
});
```
