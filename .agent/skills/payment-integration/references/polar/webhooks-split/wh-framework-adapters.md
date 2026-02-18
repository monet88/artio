# Framework Adapters

### Next.js
```typescript
import { validateEvent } from '@polar-sh/nextjs/webhooks';

export async function POST(req: Request) {
  const event = await validateEvent(req);

  await handleEvent(event);

  return Response.json({ received: true });
}
```

### Laravel
```php
use Polar\Webhooks\WebhookHandler;

Route::post('/webhook/polar', function (Request $request) {
    $event = WebhookHandler::validate(
        $request->getContent(),
        $request->headers->all(),
        config('polar.webhook_secret')
    );

    dispatch(new ProcessPolarWebhook($event));

    return response()->json(['received' => true]);
});
```
