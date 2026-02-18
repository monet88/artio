# Signature Verification

### Headers
```
webhook-id: msg_xxx
webhook-signature: v1,signature_xxx
webhook-timestamp: 1642000000
```

### TypeScript Verification
```typescript
import { validateEvent, WebhookVerificationError } from '@polar-sh/sdk/webhooks';

app.post('/webhook/polar', (req, res) => {
  try {
    const event = validateEvent(
      req.body,
      req.headers,
      process.env.POLAR_WEBHOOK_SECRET
    );

    // Event is valid, process it
    await handleEvent(event);

    res.json({ received: true });
  } catch (error) {
    if (error instanceof WebhookVerificationError) {
      console.error('Invalid webhook signature');
      return res.status(400).json({ error: 'Invalid signature' });
    }
    throw error;
  }
});
```

### Python Verification
```python
from polar_sdk.webhooks import validate_event, WebhookVerificationError

@app.route('/webhook/polar', methods=['POST'])
def polar_webhook():
    try:
        event = validate_event(
            request.get_data(),
            dict(request.headers),
            os.environ['POLAR_WEBHOOK_SECRET']
        )

        handle_event(event)
        return {'received': True}

    except WebhookVerificationError:
        return {'error': 'Invalid signature'}, 400
```

### Manual Verification
```typescript
import crypto from 'crypto';

function verifySignature(payload, headers, secret) {
  const timestamp = headers['webhook-timestamp'];
  const signatures = headers['webhook-signature'].split(',');

  const signedPayload = `${timestamp}.${payload}`;
  const expectedSignature = crypto
    .createHmac('sha256', Buffer.from(secret, 'base64'))
    .update(signedPayload)
    .digest('base64');

  return signatures.some(sig => {
    const [version, signature] = sig.split('=');
    return version === 'v1' && signature === expectedSignature;
  });
}
```
