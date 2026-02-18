# Customer Experience

### Viewing Benefits
- Customer portal shows all active benefits
- Clear instructions for each type
- Download links for files
- License keys displayed

### Accessing Benefits
```typescript
// Generate customer portal link
const session = await polar.customerSessions.create({
  external_customer_id: userId
});

// Customer sees:
// - Active subscriptions
// - Granted benefits
// - Download links
// - License keys
// - Instructions
```
