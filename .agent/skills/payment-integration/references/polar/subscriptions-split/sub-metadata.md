# Metadata

### Update Subscription Metadata
```typescript
await polar.subscriptions.update(subscriptionId, {
  metadata: {
    internal_id: "sub_123",
    tier: "pro",
    source: "web"
  }
});
```

### Query by Metadata
```typescript
const subscriptions = await polar.subscriptions.list({
  organization_id: "org_xxx",
  metadata: { tier: "pro" }
});
```
