# Revenue Tracking with Caching

```typescript
// lib/polar.ts
const REVENUE_CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes

let revenueCache: {
  data: { totalRevenueCents: number; orderCount: number } | null;
  timestamp: number;
} = { data: null, timestamp: 0 };

export async function getPolarApiRevenue(): Promise<{
  totalRevenueCents: number;
  orderCount: number;
  fromCache: boolean;
}> {
  const now = Date.now();

  // Return cache if valid
  if (revenueCache.data && now - revenueCache.timestamp < REVENUE_CACHE_TTL_MS) {
    return { ...revenueCache.data, fromCache: true };
  }

  const polar = getPolar();
  const env = getPolarEnv();

  try {
    let totalRevenueCents = 0;
    let orderCount = 0;
    let page = 1;
    const maxPages = 100; // Safety limit

    while (page <= maxPages) {
      const response = await polar.orders.list({
        organizationId: env.POLAR_ORGANIZATION_ID,
        page,
        limit: 100,
      });

      for (const order of response.items) {
        if (order.status === 'succeeded') {
          totalRevenueCents += order.netAmount; // After discounts, before tax
          orderCount++;
        }
      }

      if (!response.pagination.hasMore) break;
      page++;
    }

    revenueCache = { data: { totalRevenueCents, orderCount }, timestamp: now };
    return { totalRevenueCents, orderCount, fromCache: false };

  } catch (error) {
    // Return stale cache on error
    if (revenueCache.data) {
      console.warn('Using stale revenue cache due to API error');
      return { ...revenueCache.data, fromCache: true };
    }
    throw error;
  }
}
```
