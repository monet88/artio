# Fee Calculation

### Platform Fee Structure (Dec 2025)
```typescript
// lib/polar-fees.ts
interface PolarFeeConfig {
  basePercentage: number;     // 4%
  baseFlatCents: number;      // $0.40 per transaction
  internationalSurcharge: number;  // +1.5% for non-US cards
  subscriptionSurcharge: number;   // +0.5% (not for one-time)
}

const POLAR_FEES: PolarFeeConfig = {
  basePercentage: 0.04,
  baseFlatCents: 40,
  internationalSurcharge: 0.015,
  subscriptionSurcharge: 0.005,
};

export function calculatePolarFees(
  amountCents: number,
  isInternational: boolean = true, // Conservative default
  isSubscription: boolean = false
): {
  baseFee: number;
  internationalFee: number;
  subscriptionFee: number;
  totalFee: number;
  netRevenue: number;
} {
  // Handle zero/negative
  if (amountCents <= 0) {
    return { baseFee: 0, internationalFee: 0, subscriptionFee: 0, totalFee: 0, netRevenue: 0 };
  }

  const baseFee = Math.round(amountCents * POLAR_FEES.basePercentage + POLAR_FEES.baseFlatCents);
  const internationalFee = isInternational
    ? Math.round(amountCents * POLAR_FEES.internationalSurcharge)
    : 0;
  const subscriptionFee = isSubscription
    ? Math.round(amountCents * POLAR_FEES.subscriptionSurcharge)
    : 0;

  const totalFee = baseFee + internationalFee + subscriptionFee;
  const netRevenue = amountCents - totalFee;

  return { baseFee, internationalFee, subscriptionFee, totalFee, netRevenue };
}

// Aggregate fees preserve per-transaction flat fees
export function calculateAggregatePolarFees(transactionAmounts: number[]): {
  totalFees: number;
  totalNetRevenue: number;
} {
  let totalFees = 0;
  let totalNetRevenue = 0;

  for (const amount of transactionAmounts) {
    const { totalFee, netRevenue } = calculatePolarFees(amount);
    totalFees += totalFee;
    totalNetRevenue += netRevenue;
  }

  return { totalFees, totalNetRevenue };
}
```
