# Benefit Grants

**Link between customer and benefit.**

### States
- `created` - Grant created
- `active` - Benefit delivered
- `revoked` - Access removed

### Webhooks
- `benefit_grant.created` - Grant created
- `benefit_grant.updated` - Status changed
- `benefit_grant.revoked` - Access revoked

### Auto-revoke Triggers
- Subscription canceled
- Subscription revoked
- Refund processed
- Product changed (if benefit not on new product)

### Querying Grants
```typescript
const grants = await polar.benefitGrants.list({
  customer_id: "cust_xxx",
  benefit_id: "benefit_xxx",
  is_granted: true
});
```
