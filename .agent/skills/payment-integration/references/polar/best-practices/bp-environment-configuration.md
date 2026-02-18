# Environment Configuration

### Required Environment Variables
```bash
# Core API
POLAR_API_KEY=polar_at_xxx           # Access token from Polar Dashboard
POLAR_ORGANIZATION_ID=org_xxx        # Your organization ID
POLAR_WEBHOOK_SECRET=whsec_xxx       # Webhook signature verification

# Product IDs (one per product)
POLAR_PRODUCT_ENGINEER_ID=prod_xxx
POLAR_PRODUCT_MARKETING_ID=prod_xxx
POLAR_PRODUCT_COMBO_ID=prod_xxx

# Environment (optional, defaults to production)
POLAR_ENV=production                  # 'production' or 'sandbox'
```

### Lazy Initialization Pattern
```typescript
// lib/polar.ts - Defer validation until first access
import { Polar } from '@polar-sh/sdk';
import { z } from 'zod';

const polarEnvSchema = z.object({
  POLAR_API_KEY: z.string().min(1),
  POLAR_ORGANIZATION_ID: z.string().min(1),
  POLAR_WEBHOOK_SECRET: z.string().min(1),
});

let _polar: Polar | null = null;
let _env: z.infer<typeof polarEnvSchema> | null = null;

export function getPolarEnv() {
  if (!_env) {
    _env = polarEnvSchema.parse({
      POLAR_API_KEY: process.env.POLAR_API_KEY,
      POLAR_ORGANIZATION_ID: process.env.POLAR_ORGANIZATION_ID,
      POLAR_WEBHOOK_SECRET: process.env.POLAR_WEBHOOK_SECRET,
    });
  }
  return _env;
}

export function getPolar() {
  if (!_polar) {
    const env = getPolarEnv();
    const polarEnv = process.env.POLAR_ENV || 'production';
    _polar = new Polar({
      accessToken: env.POLAR_API_KEY,
      server: polarEnv as 'production' | 'sandbox',
    });
  }
  return _polar;
}
```

**Key Benefit:** Module imports succeed at build time; validation deferred until runtime when env vars are available.
