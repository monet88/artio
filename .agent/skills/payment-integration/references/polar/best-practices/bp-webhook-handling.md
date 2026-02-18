# Webhook Handling

### Signature Verification
```typescript
// app/api/webhooks/polar/route.ts
import { validateEvent } from '@polar-sh/sdk/webhooks';
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
  const payload = await request.text();
  const headers = Object.fromEntries(request.headers);
  const secret = process.env.POLAR_WEBHOOK_SECRET!;

  let webhookEvent;
  try {
    webhookEvent = validateEvent(payload, headers, secret);
  } catch (error) {
    console.error('Invalid webhook signature:', error);
    return NextResponse.json({ error: 'Invalid signature' }, { status: 400 });
  }

  // Extract event ID for idempotency
  const parsedPayload = JSON.parse(payload);
  const eventId = parsedPayload.id || `${parsedPayload.type}-${Date.now()}`;

  // Check for duplicate processing
  const existingEvent = await db.select()
    .from(webhookEvents)
    .where(eq(webhookEvents.eventId, eventId))
    .limit(1);

  if (existingEvent.length > 0) {
    console.log(`Duplicate webhook ignored: ${eventId}`);
    return NextResponse.json({ received: true });
  }

  // Record event BEFORE processing (idempotency)
  await db.insert(webhookEvents).values({
    id: crypto.randomUUID(),
    provider: 'polar',
    eventType: webhookEvent.type,
    eventId,
    payload,
    processed: false,
  });

  try {
    await handleWebhookEvent(webhookEvent);

    // Mark as processed
    await db.update(webhookEvents)
      .set({ processed: true, processedAt: new Date() })
      .where(eq(webhookEvents.eventId, eventId));

  } catch (error) {
    // Log error but don't fail the webhook
    await db.update(webhookEvents)
      .set({
        processed: true,
        processedAt: new Date(),
        error: error instanceof Error ? error.message : 'Unknown error',
      })
      .where(eq(webhookEvents.eventId, eventId));
  }

  return NextResponse.json({ received: true });
}
```

### Event Handlers
```typescript
async function handleWebhookEvent(event: WebhookEvent) {
  switch (event.type) {
    case 'checkout.created':
      // Order already exists from API - just log
      console.log(`Checkout created: ${event.data.id}`);
      break;

    case 'checkout.updated':
      await handleCheckoutUpdated(event.data);
      break;

    case 'order.created':
      await handleOrderCreated(event.data);
      break;

    case 'order.refunded':
      await handleOrderRefunded(event.data);
      break;

    default:
      console.log(`Unhandled event type: ${event.type}`);
  }
}

async function handleOrderCreated(order: PolarOrder) {
  const orderId = order.metadata?.orderId;
  if (!orderId) {
    console.error('Order missing orderId in metadata');
    return;
  }

  const dbOrder = await db.select()
    .from(orders)
    .where(eq(orders.id, orderId))
    .limit(1);

  if (!dbOrder[0]) {
    console.error(`Order not found: ${orderId}`);
    return;
  }

  // 1. Update order status
  await db.update(orders)
    .set({
      status: 'completed',
      paymentId: order.id,
      updatedAt: new Date(),
    })
    .where(eq(orders.id, orderId));

  // 2. Create license (non-blocking)
  try {
    await createLicense(dbOrder[0]);
  } catch (error) {
    console.error('Failed to create license:', error);
  }

  // 3. Send confirmation email (non-blocking)
  try {
    await sendOrderConfirmation(dbOrder[0], order);
  } catch (error) {
    console.error('Failed to send confirmation:', error);
  }

  // 4. Create referral commission (non-blocking)
  if (dbOrder[0].referredBy) {
    try {
      await createCommission(dbOrder[0]);
    } catch (error) {
      console.error('Failed to create commission:', error);
    }
  }

  // 5. Grant GitHub access (non-blocking)
  try {
    const metadata = JSON.parse(dbOrder[0].metadata || '{}');
    await inviteToGitHub(metadata.githubUsername, dbOrder[0].productType);
  } catch (error) {
    console.error('Failed to invite to GitHub:', error);
  }

  // 6. Send Discord notification (non-blocking)
  try {
    await sendSalesNotification(dbOrder[0]);
  } catch (error) {
    console.error('Failed to send Discord notification:', error);
  }
}
```

### Status Mapping
```typescript
function mapPolarStatusToAppStatus(polarStatus: string): string | null {
  switch (polarStatus) {
    case 'succeeded':
      return 'completed';
    case 'failed':
    case 'expired':
      return 'failed';
    case 'open':
    case 'confirmed':
      return null; // Don't update - still pending
    default:
      return null;
  }
}
```
