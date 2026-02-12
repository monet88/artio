# Supabase Edge Functions

Serverless functions on Deno runtime. CPU limit: 2s, request timeout: 150s, bundle: 20MB.

## CLI Commands

| Task | Command |
|------|---------|
| Create | `supabase functions new <name>` |
| Serve locally | `supabase functions serve --env-file .env` |
| Deploy | `supabase functions deploy <name>` |
| Deploy (no JWT) | `supabase functions deploy <name> --no-verify-jwt` |
| Set secrets | `supabase secrets set KEY=value` |

## Basic Structure

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const { name } = await req.json()
    return new Response(
      JSON.stringify({ message: `Hello ${name}!` }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})
```

## Using Supabase Client

```typescript
import { createClient } from 'jsr:@supabase/supabase-js@2'

// Admin client (bypasses RLS)
const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!)

// User client (respects RLS)
const userClient = createClient(
  Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!,
  { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
)
```

## Get User from JWT

```typescript
const { data: { user }, error } = await userClient.auth.getUser()
if (error || !user) return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 })
```

## Built-in Env Vars

`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_DB_URL`

## Invoke from Client

```javascript
const { data, error } = await supabase.functions.invoke('function-name', {
  body: { key: 'value' },
  headers: { 'x-custom': 'value' }
})
```

## Webhook (Stripe Example)

```typescript
import Stripe from 'npm:stripe@14'
const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!)
const cryptoProvider = Stripe.createSubtleCryptoProvider()

Deno.serve(async (req) => {
  const body = await req.text()
  const event = await stripe.webhooks.constructEventAsync(
    body, req.headers.get('Stripe-Signature')!,
    Deno.env.get('STRIPE_WEBHOOK_SECRET')!, undefined, cryptoProvider
  )
  switch (event.type) {
    case 'checkout.session.completed': /* handle */ break
  }
  return new Response(JSON.stringify({ received: true }))
})
```

## Scheduled (Cron)

```sql
SELECT cron.schedule('daily-cleanup', '0 0 * * *', $$
  SELECT net.http_post(
    url := 'https://<project>.supabase.co/functions/v1/cleanup',
    headers := '{"Authorization": "Bearer <SERVICE_KEY>"}'::jsonb
  )
$$);
```

## Shared Code

```
supabase/functions/
├── _shared/
│   ├── cors.ts        # Export corsHeaders
│   └── supabase.ts    # Export supabaseAdmin client
├── function-a/index.ts
└── function-b/index.ts
```

Import shared: `import { corsHeaders } from '../_shared/cors.ts'`
