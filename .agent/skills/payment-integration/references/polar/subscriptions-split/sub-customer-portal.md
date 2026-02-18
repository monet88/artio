# Customer Portal

### Generate Portal Access
```typescript
const session = await polar.customerSessions.create({
  customer_id: "cust_xxx"
});

// Redirect to: session.url
```

### Portal Features
- View subscriptions
- Upgrade/downgrade plans
- Cancel subscriptions
- Update billing info
- View invoices
- Access benefits

### Pre-authenticated Links
```typescript
// From your app, create session and redirect
app.get('/portal', async (req, res) => {
  const session = await polar.customerSessions.create({
    external_customer_id: req.user.id
  });

  res.redirect(session.url);
});
```
