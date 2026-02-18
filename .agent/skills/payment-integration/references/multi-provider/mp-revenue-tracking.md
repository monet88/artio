# Revenue Tracking

### Combined Provider Revenue
```typescript
// lib/revenue.ts
export async function getTotalRevenue(options?: {
  startDate?: Date;
  endDate?: Date;
}): Promise<{
  totalUsdCents: number;
  byProvider: { polar: number; sepay: number };
  orderCount: number;
  averageOrderValueCents: number;
}> {
  let query = db.select()
    .from(orders)
    .where(eq(orders.status, 'completed'));

  if (options?.startDate) {
    query = query.where(gte(orders.createdAt, options.startDate));
  }
  if (options?.endDate) {
    query = query.where(lte(orders.createdAt, options.endDate));
  }

  const completedOrders = await query;

  let totalUsdCents = 0;
  let polarUsdCents = 0;
  let sepayUsdCents = 0;

  for (const order of completedOrders) {
    const normalized = await normalizeOrderToUsd(order);

    totalUsdCents += normalized.amountUsdCents;

    if (order.paymentProvider === 'polar') {
      polarUsdCents += normalized.amountUsdCents;
    } else {
      sepayUsdCents += normalized.amountUsdCents;
    }
  }

  return {
    totalUsdCents,
    byProvider: { polar: polarUsdCents, sepay: sepayUsdCents },
    orderCount: completedOrders.length,
    averageOrderValueCents: completedOrders.length > 0
      ? Math.round(totalUsdCents / completedOrders.length)
      : 0,
  };
}
```

### Maintainer Revenue Calculation
```typescript
// lib/maintainer-revenue.ts
// Calculate actual payout after fees and costs

interface MaintainerRevenue {
  grossRevenue: number;      // Total received
  platformFees: number;      // Polar/Stripe fees
  operatingCosts: number;    // Proportional costs
  taxDeduction: number;      // 17% tax
  netPayout: number;         // Final amount
  currency: 'USD';
}

export async function calculateMaintainerRevenue(
  productIds: string[],
  dateRange: { start: Date; end: Date }
): Promise<MaintainerRevenue> {
  // Get orders for these products
  const orders = await db.select()
    .from(orders)
    .where(and(
      eq(orders.status, 'completed'),
      inArray(orders.productType, productIds),
      gte(orders.createdAt, dateRange.start),
      lte(orders.createdAt, dateRange.end)
    ));

  let grossRevenue = 0;
  let platformFees = 0;

  for (const order of orders) {
    const normalized = await normalizeOrderToUsd(order);
    grossRevenue += normalized.amountUsdCents;

    if (order.paymentProvider === 'polar') {
      const fees = calculatePolarFees(normalized.amountUsdCents);
      platformFees += fees.totalFee;
    }
    // SePay has no platform fees (direct bank transfer)
  }

  // Proportional operating costs (hosting, services, etc.)
  const monthlyOperatingCosts = 50000; // $500/month in cents
  const totalMonthlyRevenue = await getTotalRevenue({
    startDate: dateRange.start,
    endDate: dateRange.end,
  });
  const costRatio = grossRevenue / (totalMonthlyRevenue.totalUsdCents || 1);
  const operatingCosts = Math.round(monthlyOperatingCosts * costRatio);

  // Tax deduction (17%)
  const afterCosts = grossRevenue - platformFees - operatingCosts;
  const taxDeduction = Math.round(afterCosts * 0.17);

  const netPayout = afterCosts - taxDeduction;

  return {
    grossRevenue,
    platformFees,
    operatingCosts,
    taxDeduction,
    netPayout,
    currency: 'USD',
  };
}
```
