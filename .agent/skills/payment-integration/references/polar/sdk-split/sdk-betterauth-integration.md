# BetterAuth Integration

**Installation:**
```bash
npm install @polar-sh/better-auth
```

**Configuration:**
```typescript
import { betterAuth } from 'better-auth';
import { polarPlugin } from '@polar-sh/better-auth';

export const auth = betterAuth({
  database: db,
  plugins: [
    polarPlugin({
      organizationId: process.env.POLAR_ORG_ID!,
      accessToken: process.env.POLAR_ACCESS_TOKEN!
    })
  ]
});
```

**Features:**
- Auto-create Polar customers on signup
- Automatic external_id mapping
- User-customer sync
- Access customer data in auth session
