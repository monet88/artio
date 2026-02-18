# Currency Conversion

### Multi-Layer Fallback Architecture
```typescript
// lib/currency.ts
const EXCHANGE_RATE_CACHE_TTL = 60 * 60 * 1000; // 1 hour
const FALLBACK_RATES = {
  VND_TO_USD: 24500,  // Conservative estimate
  USD_TO_VND: 24500,
};

interface ExchangeRateCache {
  rates: { VND: number; USD: number };
  timestamp: number;
  source: 'api' | 'cached' | 'expired' | 'fallback';
}

let rateCache: ExchangeRateCache | null = null;

export async function getExchangeRates(): Promise<ExchangeRateCache> {
  const now = Date.now();

  // Layer 1: Fresh cache (< 1 hour)
  if (rateCache && now - rateCache.timestamp < EXCHANGE_RATE_CACHE_TTL) {
    return { ...rateCache, source: 'cached' };
  }

  // Layer 2: Live API
  try {
    const response = await fetch(
      'https://api.exchangerate-api.com/v4/latest/USD',
      { signal: AbortSignal.timeout(5000) }
    );
    const data = await response.json();

    rateCache = {
      rates: { VND: data.rates.VND, USD: 1 },
      timestamp: now,
      source: 'api',
    };
    return rateCache;

  } catch (error) {
    console.warn('Exchange rate API failed:', error);

    // Layer 3: Expired cache (better than nothing)
    if (rateCache) {
      return { ...rateCache, source: 'expired' };
    }

    // Layer 4: Hardcoded fallback
    return {
      rates: { VND: FALLBACK_RATES.VND_TO_USD, USD: 1 },
      timestamp: now,
      source: 'fallback',
    };
  }
}

export async function convertVndToUsd(vndAmount: number): Promise<{
  usdCents: number;
  rate: number;
  source: string;
}> {
  const { rates, source } = await getExchangeRates();
  const usdCents = Math.round((vndAmount / rates.VND) * 100);
  return { usdCents, rate: rates.VND, source };
}

export async function convertUsdToVnd(usdCents: number): Promise<{
  vndAmount: number;
  rate: number;
  source: string;
}> {
  const { rates, source } = await getExchangeRates();
  const vndAmount = Math.round((usdCents / 100) * rates.VND);
  return { vndAmount, rate: rates.VND, source };
}
```

### Normalizing Revenue to USD
```typescript
// For reporting/dashboard - normalize all revenue to USD cents
export async function normalizeOrderToUsd(order: Order): Promise<{
  amountUsdCents: number;
  originalAmountUsdCents: number;
  conversionSource: string;
}> {
  if (order.currency === 'USD') {
    return {
      amountUsdCents: order.amount,
      originalAmountUsdCents: order.originalAmount || order.amount,
      conversionSource: 'native',
    };
  }

  // VND order
  const conversion = await convertVndToUsd(order.amount);
  const originalConversion = order.originalAmount
    ? await convertVndToUsd(order.originalAmount)
    : conversion;

  return {
    amountUsdCents: conversion.usdCents,
    originalAmountUsdCents: originalConversion.usdCents,
    conversionSource: conversion.source,
  };
}
```
