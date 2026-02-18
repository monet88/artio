# Webhook Event Tracking

### Unified Webhook Events Table
```typescript
// db/schema/webhook-events.ts
export const webhookEvents = pgTable('webhook_events', {
  id: uuid('id').primaryKey().defaultRandom(),
  provider: text('provider').notNull(),          // 'polar' or 'sepay'
  eventType: text('event_type').notNull(),       // Event type/name
  eventId: text('event_id').notNull().unique(),  // Idempotency key
  payload: text('payload').notNull(),            // Raw JSON payload
  processed: boolean('processed').default(false),
  processedAt: timestamp('processed_at'),
  error: text('error'),                          // Error message if failed
  createdAt: timestamp('created_at').defaultNow(),
});

// Partial index for unprocessed events
// CREATE INDEX idx_webhook_events_unprocessed ON webhook_events (created_at)
//   WHERE processed = false;
```

### Idempotent Webhook Processing
```typescript
// lib/webhooks.ts
export async function processWebhookIdempotently<T>(
  provider: 'polar' | 'sepay',
  eventId: string,
  eventType: string,
  payload: string,
  handler: () => Promise<T>
): Promise<{ processed: boolean; result?: T; error?: string }> {
  // Check for duplicate
  const existing = await db.select()
    .from(webhookEvents)
    .where(eq(webhookEvents.eventId, eventId))
    .limit(1);

  if (existing.length > 0) {
    return { processed: false }; // Already processed
  }

  // Record event BEFORE processing
  await db.insert(webhookEvents).values({
    id: crypto.randomUUID(),
    provider,
    eventType,
    eventId,
    payload,
    processed: false,
  });

  try {
    const result = await handler();

    await db.update(webhookEvents)
      .set({ processed: true, processedAt: new Date() })
      .where(eq(webhookEvents.eventId, eventId));

    return { processed: true, result };

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';

    await db.update(webhookEvents)
      .set({
        processed: true,
        processedAt: new Date(),
        error: errorMessage,
      })
      .where(eq(webhookEvents.eventId, eventId));

    return { processed: true, error: errorMessage };
  }
}
```
