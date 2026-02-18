# Currency Conversion

### VND to USD with Multi-Layer Fallback
```typescript
// lib/currency.ts
const EXCHANGE_RATE_CACHE_TTL = 60 * 60 * 1000; // 1 hour
const FALLBACK_VND_TO_USD = 24500; // Conservative fallback

let exchangeRateCache: {
  rate: number;
  timestamp: number;
  source: 'api' | 'cached' | 'expired' | 'fallback';
} | null = null;

export async function convertVndToUsd(vndAmount: number): Promise<{
  usdCents: number;
  rate: number;
  source: string;
}> {
  const now = Date.now();

  // Layer 1: Fresh cache
  if (exchangeRateCache && now - exchangeRateCache.timestamp < EXCHANGE_RATE_CACHE_TTL) {
    const usdCents = Math.round((vndAmount / exchangeRateCache.rate) * 100);
    return { usdCents, rate: exchangeRateCache.rate, source: 'cached' };
  }

  // Layer 2: Try live API
  try {
    const response = await fetch(
      'https://api.exchangerate-api.com/v4/latest/USD',
      { signal: AbortSignal.timeout(5000) }
    );
    const data = await response.json();
    const rate = data.rates.VND;

    exchangeRateCache = { rate, timestamp: now, source: 'api' };
    const usdCents = Math.round((vndAmount / rate) * 100);
    return { usdCents, rate, source: 'api' };

  } catch (error) {
    console.warn('Exchange rate API failed:', error);

    // Layer 3: Expired cache (better than nothing)
    if (exchangeRateCache) {
      const usdCents = Math.round((vndAmount / exchangeRateCache.rate) * 100);
      return { usdCents, rate: exchangeRateCache.rate, source: 'expired_cache' };
    }

    // Layer 4: Hardcoded fallback
    const usdCents = Math.round((vndAmount / FALLBACK_VND_TO_USD) * 100);
    return { usdCents, rate: FALLBACK_VND_TO_USD, source: 'fallback' };
  }
}
```

### USD Discount to VND
```typescript
// When Polar discount is in USD, convert to VND for SePay checkout
export function convertUsdDiscountToVnd(
  discount: { type: 'fixed' | 'percentage'; amount?: number; basisPoints?: number },
  amountVND: number
): number {
  if (discount.type === 'percentage') {
    // Basis points: 1000 = 10%, 10000 = 100%
    const percentage = (discount.basisPoints || 0) / 10000;
    return Math.round(amountVND * percentage);
  } else {
    // Fixed amount in USD cents → VND
    const usdDollars = (discount.amount || 0) / 100;
    return Math.round(usdDollars * 24500); // Use conservative rate
  }
}
```
