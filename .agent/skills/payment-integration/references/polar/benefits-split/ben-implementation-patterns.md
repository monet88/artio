# Implementation Patterns

### License Key Validation
```typescript
// In your application
async function validateLicense(key) {
  try {
    const result = await polar.licenses.validate({
      key: key,
      organization_id: process.env.POLAR_ORG_ID
    });

    if (!result.valid) {
      return { valid: false, reason: 'Invalid license' };
    }

    if (result.limit_usage && result.usage >= result.limit_usage) {
      return { valid: false, reason: 'Usage limit exceeded' };
    }

    return { valid: true, customer: result.customer };
  } catch (error) {
    console.error('License validation failed:', error);
    return { valid: false, reason: 'Validation error' };
  }
}
```

### GitHub Access Check
```typescript
// Listen to benefit grant webhook
app.post('/webhook/polar', async (req, res) => {
  const event = validateEvent(req.body, req.headers, secret);

  if (event.type === 'benefit_grant.created') {
    const grant = event.data;

    if (grant.benefit.type === 'github_repository') {
      // Update user's GitHub access in your system
      await updateGitHubAccess(grant.customer.external_id, true);
    }
  }

  res.json({ received: true });
});
```

### Discord Role Sync
```typescript
// Monitor benefit grants
if (event.type === 'benefit_grant.created') {
  const grant = event.data;

  if (grant.benefit.type === 'discord') {
    // Notify user to connect Discord
    await sendDiscordInvite(grant.customer.email);
  }
}

if (event.type === 'benefit_grant.revoked') {
  const grant = event.data;

  if (grant.benefit.type === 'discord') {
    // Roles removed automatically by Polar
    await notifyRoleRemoval(grant.customer.external_id);
  }
}
```
