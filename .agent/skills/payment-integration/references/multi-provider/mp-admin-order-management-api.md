# Admin Order Management API

### Order Listing with Provider Info
```typescript
// app/api/admin/orders/route.ts
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const page = parseInt(searchParams.get('page') || '1');
  const limit = parseInt(searchParams.get('limit') || '50');
  const provider = searchParams.get('provider'); // 'polar' | 'sepay' | null
  const status = searchParams.get('status');

  let query = db.select()
    .from(orders)
    .orderBy(desc(orders.createdAt));

  if (provider) {
    query = query.where(eq(orders.paymentProvider, provider));
  }
  if (status) {
    query = query.where(eq(orders.status, status));
  }

  const results = await query
    .limit(limit)
    .offset((page - 1) * limit);

  // Normalize amounts to USD for display
  const ordersWithNormalized = await Promise.all(
    results.map(async (order) => {
      const normalized = await normalizeOrderToUsd(order);
      return {
        ...order,
        amountUsdCents: normalized.amountUsdCents,
        displayAmount: order.currency === 'VND'
          ? formatVND(order.amount)
          : formatUSD(order.amount),
      };
    })
  );

  return NextResponse.json({
    orders: ordersWithNormalized,
    pagination: {
      page,
      limit,
      hasMore: results.length === limit,
    },
  });
}
```
