# Benefit Types

### 1. License Keys

**Auto-generate unique keys with customizable branding.**

**Create:**
```typescript
const benefit = await polar.benefits.create({
  type: "license_keys",
  organization_id: "org_xxx",
  description: "Software License",
  properties: {
    prefix: "MYAPP",
    expires: false,
    activations: 1,
    limit_usage: false
  }
});
```

**Validation API (unauthenticated):**
```typescript
const validation = await polar.licenses.validate({
  key: "MYAPP-XXXX-XXXX-XXXX",
  organization_id: "org_xxx"
});

if (validation.valid) {
  // Grant access
}
```

**Activation/Deactivation:**
```typescript
await polar.licenses.activate(licenseKey, {
  label: "User's MacBook Pro"
});

await polar.licenses.deactivate(activationId);
```

**Auto-revoke:** On subscription cancellation or refund

### 2. GitHub Repository Access

**Auto-invite to private repos with permission management.**

**Create:**
```typescript
const benefit = await polar.benefits.create({
  type: "github_repository",
  organization_id: "org_xxx",
  description: "Access to private repo",
  properties: {
    repository_owner: "myorg",
    repository_name: "private-repo",
    permission: "pull" // or "push", "admin"
  }
});
```

**Multiple Repos:**
```typescript
{
  properties: {
    repositories: [
      { owner: "myorg", name: "repo1", permission: "pull" },
      { owner: "myorg", name: "repo2", permission: "push" }
    ]
  }
}
```

**Behavior:**
- Auto-invite on subscription activation
- Permission managed by Polar
- Auto-revoke on cancellation

### 3. Discord Access

**Server invites and role assignment.**

**Create:**
```typescript
const benefit = await polar.benefits.create({
  type: "discord",
  organization_id: "org_xxx",
  description: "Premium Discord role",
  properties: {
    guild_id: "123456789",
    role_id: "987654321"
  }
});
```

**Multiple Roles:**
```typescript
{
  properties: {
    guild_id: "123456789",
    roles: [
      { role_id: "role1", name: "Premium" },
      { role_id: "role2", name: "Supporter" }
    ]
  }
}
```

**Requirements:**
- Polar Discord app must be added to server
- Configure in Polar dashboard

**Behavior:**
- Auto-invite to server
- Assign roles automatically
- Remove roles on cancellation

### 4. Downloadable Files

**Secure file delivery up to 10GB each.**

**Create:**
```typescript
const benefit = await polar.benefits.create({
  type: "downloadable",
  organization_id: "org_xxx",
  description: "Premium templates",
  properties: {
    files: [
      { name: "template1.zip", size: 5000000 },
      { name: "template2.psd", size: 10000000 }
    ]
  }
});
```

**Upload Files:**
- Via Polar dashboard
- Secure storage
- Access control

**Customer Access:**
- Download links in customer portal
- Secure, time-limited URLs
- Multiple files supported

### 5. Meter Credits

**Pre-purchased usage for usage-based billing.**

**Create:**
```typescript
const benefit = await polar.benefits.create({
  type: "custom",
  organization_id: "org_xxx",
  description: "10,000 API credits",
  properties: {
    meter_id: "meter_xxx",
    credits: 10000
  }
});
```

**Automatic Application:**
- Credits added on subscription start
- Balance tracked via API
- Depletes with usage

**Balance Check:**
```typescript
const balance = await polar.meters.getBalance({
  customer_id: "cust_xxx",
  meter_id: "meter_xxx"
});
```

### 6. Custom Benefits

**Flexible placeholder for manual fulfillment.**

**Create:**
```typescript
const benefit = await polar.benefits.create({
  type: "custom",
  organization_id: "org_xxx",
  description: "Priority support via email",
  properties: {
    note: "Email support@example.com with your order ID for priority support"
  }
});
```

**Use Cases:**
- Cal.com booking links
- Email support access
- Community forum access
- Manual onboarding
