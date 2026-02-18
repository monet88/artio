# Framework Adapters

### Next.js (@polar-sh/nextjs)

**Quick Start:**
```bash
npx polar-init
```

**Configuration:**
```typescript
// lib/polar.ts
import { PolarClient } from '@polar-sh/nextjs';

export const polar = new PolarClient({
  accessToken: process.env.POLAR_ACCESS_TOKEN!,
  webhookSecret: process.env.POLAR_WEBHOOK_SECRET!
});
```

**Checkout Handler:**
```typescript
// app/actions/checkout.ts
'use server'

import { polar } from '@/lib/polar';

export async function createCheckout(priceId: string) {
  const session = await polar.checkouts.create({
    product_price_id: priceId,
    success_url: `${process.env.NEXT_PUBLIC_URL}/success?checkout_id={CHECKOUT_ID}`
  });

  return session.url;
}
```

**Webhook Handler:**
```typescript
// app/api/webhook/polar/route.ts
import { polar } from '@/lib/polar';

export async function POST(req: Request) {
  const event = await polar.webhooks.validate(req);

  switch (event.type) {
    case 'order.paid':
      await handleOrderPaid(event.data);
      break;
    // ... other events
  }

  return Response.json({ received: true });
}
```

### Laravel (polar-sh/laravel)

**Installation:**
```bash
composer require polar-sh/laravel
php artisan vendor:publish --tag=polar-config
php artisan vendor:publish --tag=polar-migrations
php artisan migrate
```

**Configuration:**
```php
// config/polar.php
return [
    'access_token' => env('POLAR_ACCESS_TOKEN'),
    'webhook_secret' => env('POLAR_WEBHOOK_SECRET'),
];
```

**Checkout:**
```php
use Polar\Facades\Polar;

Route::post('/checkout', function (Request $request) {
    $checkout = Polar::checkouts()->create([
        'product_price_id' => $request->input('price_id'),
        'success_url' => route('checkout.success'),
        'external_customer_id' => auth()->id(),
    ]);

    return redirect($checkout['url']);
});
```

**Webhook:**
```php
use Polar\Events\WebhookReceived;

// app/Listeners/PolarWebhookHandler.php
class PolarWebhookHandler
{
    public function handle(WebhookReceived $event)
    {
        match ($event->payload['type']) {
            'order.paid' => $this->handleOrderPaid($event->payload['data']),
            'subscription.revoked' => $this->handleRevoked($event->payload['data']),
            default => null,
        };
    }
}
```

### Express

```javascript
const express = require('express');
const { Polar } = require('@polar-sh/sdk');
const { validateEvent } = require('@polar-sh/sdk/webhooks');

const app = express();
const polar = new Polar({ accessToken: process.env.POLAR_ACCESS_TOKEN });

app.use(express.json());

app.post('/checkout', async (req, res) => {
  const session = await polar.checkouts.create({
    product_price_id: req.body.priceId,
    success_url: 'https://example.com/success',
    external_customer_id: req.user.id
  });

  res.json({ url: session.url });
});

app.post('/webhook/polar', (req, res) => {
  const event = validateEvent(
    req.body,
    req.headers,
    process.env.POLAR_WEBHOOK_SECRET
  );

  handleEvent(event);
  res.json({ received: true });
});
```

### Remix

```typescript
import { Polar } from '@polar-sh/sdk';

const polar = new Polar({ accessToken: process.env.POLAR_ACCESS_TOKEN });

export async function action({ request }: ActionFunctionArgs) {
  const formData = await request.formData();
  const priceId = formData.get('priceId');

  const session = await polar.checkouts.create({
    product_price_id: priceId,
    success_url: `${request.url}/success`
  });

  return redirect(session.url);
}
```
