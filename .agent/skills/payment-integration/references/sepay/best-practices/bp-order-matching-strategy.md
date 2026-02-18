# Order Matching Strategy

### Multi-Strategy Fallback Chain
```typescript
// lib/sepay.ts
export async function findOrderByTransaction(
  payload: SepayWebhookPayload
): Promise<{ order: Order | null; matchMethod: string }> {
  const { content, transferAmount, transactionDate } = payload;

  // Strategy 1: Parse Order ID from content (preferred)
  const parsedOrderId = parseOrderIdFromContent(content);
  if (parsedOrderId) {
    const order = await db.select()
      .from(orders)
      .where(eq(orders.id, parsedOrderId))
      .limit(1);

    if (order[0]) {
      return { order: order[0], matchMethod: 'content-parse' };
    }
  }

  // Strategy 2: Team payment ID match
  const teamMatch = content.match(/TEAM([A-F0-9]{8})/i);
  if (teamMatch) {
    const teamPaymentId = `TEAM${teamMatch[1].toUpperCase()}`;
    const order = await db.select()
      .from(orders)
      .where(eq(orders.paymentId, teamPaymentId))
      .limit(1);

    if (order[0]) {
      return { order: order[0], matchMethod: 'team-payment-id' };
    }
  }

  // Strategy 3: Amount + timestamp window (±30 minutes)
  const transactionTime = new Date(transactionDate);
  const windowStart = new Date(transactionTime.getTime() - 30 * 60 * 1000);
  const windowEnd = new Date(transactionTime.getTime() + 30 * 60 * 1000);

  const windowMatches = await db.select()
    .from(orders)
    .where(and(
      eq(orders.status, 'pending'),
      eq(orders.paymentProvider, 'sepay'),
      eq(orders.amount, transferAmount),
      gte(orders.createdAt, windowStart),
      lte(orders.createdAt, windowEnd)
    ))
    .limit(10);

  if (windowMatches.length === 1) {
    return { order: windowMatches[0], matchMethod: 'timestamp-window' };
  }

  if (windowMatches.length > 1) {
    // Multiple matches - select closest by creation time
    const closest = windowMatches.reduce((prev, curr) => {
      const prevDiff = Math.abs(prev.createdAt.getTime() - transactionTime.getTime());
      const currDiff = Math.abs(curr.createdAt.getTime() - transactionTime.getTime());
      return currDiff < prevDiff ? curr : prev;
    });
    return { order: closest, matchMethod: 'timestamp-window-closest' };
  }

  // Strategy 4: Amount only (last resort - single match only)
  const amountMatches = await db.select()
    .from(orders)
    .where(and(
      eq(orders.status, 'pending'),
      eq(orders.paymentProvider, 'sepay'),
      eq(orders.amount, transferAmount)
    ))
    .limit(2);

  if (amountMatches.length === 1) {
    console.warn(`⚠️ Amount-only match for ${transferAmount} VND - verify manually`);
    return { order: amountMatches[0], matchMethod: 'amount-only' };
  }

  // No match found
  console.error(`❌ Could not match order:
    Content: "${content}"
    Amount: ${transferAmount} VND
    Transaction Date: ${transactionDate}`);

  return { order: null, matchMethod: 'none' };
}
```

### UUID Parsing with Bank Transformations
```typescript
// lib/sepay.ts
export function parseOrderIdFromContent(content: string): string | null {
  if (!content) return null;

  // Pattern 1: Standard "CLAUDEKIT {uuid}"
  const claudekitMatch = content.match(/CLAUDEKIT\s+([\w-]+)/i);
  if (claudekitMatch) {
    return normalizeUUID(claudekitMatch[1]);
  }

  // Pattern 2: UUID anywhere in content (banks may strip/transform content)
  // Match 8-4-4-4-12 hex with optional dashes
  const uuidMatch = content.match(
    /([0-9A-F]{8}-?[0-9A-F]{4}-?[0-9A-F]{4}-?[0-9A-F]{4}-?[0-9A-F]{12})/i
  );
  if (uuidMatch) {
    return normalizeUUID(uuidMatch[1]);
  }

  return null;
}

function normalizeUUID(input: string): string | null {
  // Remove dashes and validate
  const cleaned = input.replace(/-/g, '');

  if (cleaned.length !== 32) return null;
  if (!/^[0-9a-f]+$/i.test(cleaned)) return null;

  // Re-format to standard UUID format
  return [
    cleaned.slice(0, 8),
    cleaned.slice(8, 12),
    cleaned.slice(12, 16),
    cleaned.slice(16, 20),
    cleaned.slice(20),
  ].join('-').toLowerCase();
}
```

### Handled Content Formats
```
CLAUDEKIT 4e4635f4-0478-4080-a5c5-48da91f97f1e     ✅ Standard
CLAUDEKIT 4e4635f404784080a5c548da91f97f1e         ✅ Bank stripped dashes
CLAUDEKIT4e4635f404784080a5c548da91f97f1e          ✅ No space
4e4635f404784080a5c548da91f97f1e-CLAUDEKIT         ✅ Reversed
claudekit 4e4635f4-0478-4080-a5c5-48da91f97f1e    ✅ Lowercase
BankAPINotify 4e4635f404784080a5c548da91f97f1e... ✅ Extra prefix
4e4635f404784080a5c548da91f97f1e                   ✅ UUID only
```
