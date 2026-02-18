# Webhook Handling

### Webhook Authentication (Timing-Safe)
```typescript
// app/api/webhooks/sepay/route.ts
import { timingSafeEqual } from 'crypto';
import { NextResponse } from 'next/server';

function verifyWebhookAuth(request: Request): boolean {
  const authHeader = request.headers.get('Authorization');
  if (!authHeader) return false;

  const expectedKey = process.env.SEPAY_WEBHOOK_API_KEY!;

  // Support both "Bearer" and "Apikey" formats
  let providedKey: string;
  if (authHeader.startsWith('Bearer ')) {
    providedKey = authHeader.slice(7);
  } else if (authHeader.startsWith('Apikey ')) {
    providedKey = authHeader.slice(7);
  } else {
    return false;
  }

  // Timing-safe comparison to prevent timing attacks
  try {
    const expected = Buffer.from(expectedKey);
    const provided = Buffer.from(providedKey);
    if (expected.length !== provided.length) return false;
    return timingSafeEqual(expected, provided);
  } catch {
    return false;
  }
}

export async function POST(request: Request) {
  // 1. Verify authentication
  if (!verifyWebhookAuth(request)) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 });
  }

  const payload = await request.json();

  // 2. Extract event ID for idempotency
  const eventId = String(payload.id || payload.transaction_id || Date.now());

  // 3. Check for duplicate
  const existingEvent = await db.select()
    .from(webhookEvents)
    .where(eq(webhookEvents.eventId, eventId))
    .limit(1);

  if (existingEvent.length > 0) {
    console.log(`Duplicate SePay webhook ignored: ${eventId}`);
    return NextResponse.json({ success: true });
  }

  // 4. Record event BEFORE processing (idempotency)
  await db.insert(webhookEvents).values({
    id: crypto.randomUUID(),
    provider: 'sepay',
    eventType: 'transaction',
    eventId,
    payload: JSON.stringify(payload),
    processed: false,
  });

  try {
    await processTransaction(payload);

    await db.update(webhookEvents)
      .set({ processed: true, processedAt: new Date() })
      .where(eq(webhookEvents.eventId, eventId));

  } catch (error) {
    // Log error but return 200 to prevent retry loop
    await db.update(webhookEvents)
      .set({
        processed: true,
        processedAt: new Date(),
        error: error instanceof Error ? error.message : 'Unknown error',
      })
      .where(eq(webhookEvents.eventId, eventId));
  }

  // Always return 200 to prevent SePay retries
  return NextResponse.json({ success: true });
}
```

### Webhook Payload Structure
```typescript
interface SepayWebhookPayload {
  id: number;                    // Transaction ID (unique key)
  gateway: string;               // Bank name (e.g., "Vietcombank")
  transactionDate: string;       // "2025-01-07 10:30:00"
  accountNumber: string;         // Account number
  code?: string;                 // Optional payment code
  content: string;               // Transaction memo - CRITICAL for matching
  transferType: 'in' | 'out';    // Only process 'in'
  transferAmount: number;        // Amount in VND
  accumulated: number;           // Balance after transaction
  subAccount?: string;
  referenceCode?: string;
  description?: string;
}
```
