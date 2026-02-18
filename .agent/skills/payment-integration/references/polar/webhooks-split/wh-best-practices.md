# Best Practices

### 1. Respond Immediately
```typescript
app.post('/webhook/polar', async (req, res) => {
  // Respond quickly
  res.json({ received: true });

  // Queue for background processing
  await webhookQueue.add('polar-webhook', req.body);
});
```

### 2. Idempotency
```typescript
async function handleEvent(event) {
  // Check if already processed
  const exists = await db.processedEvents.findOne({
    webhook_id: event.id
  });

  if (exists) {
    console.log('Event already processed');
    return;
  }

  // Process event
  await processEvent(event);

  // Mark as processed
  await db.processedEvents.insert({
    webhook_id: event.id,
    processed_at: new Date()
  });
}
```

### 3. Retry Logic
```typescript
async function processWithRetry(event, maxRetries = 3) {
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      await handleEvent(event);
      return;
    } catch (error) {
      attempt++;
      if (attempt >= maxRetries) throw error;
      await sleep(1000 * attempt);
    }
  }
}
```

### 4. Error Handling
```typescript
app.post('/webhook/polar', async (req, res) => {
  try {
    const event = validateEvent(req.body, req.headers, secret);
    res.json({ received: true });

    await processWithRetry(event);
  } catch (error) {
    console.error('Webhook processing failed:', error);
    // Log to error tracking service
    await logError(error, req.body);

    if (error instanceof WebhookVerificationError) {
      return res.status(400).json({ error: 'Invalid signature' });
    }

    // Return 2xx even on processing errors
    // Polar will retry if non-2xx
    res.json({ received: true });
  }
});
```

### 5. Logging
```typescript
logger.info('Webhook received', {
  event_type: event.type,
  event_id: event.id,
  customer_id: event.data.customer?.id,
  amount: event.data.amount
});
```
