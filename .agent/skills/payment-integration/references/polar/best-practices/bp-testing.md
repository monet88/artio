# Testing

### Unit Tests for Fee Calculation
```typescript
// __tests__/lib/polar-fees.test.ts
describe('calculatePolarFees', () => {
  it('handles zero amount', () => {
    const result = calculatePolarFees(0);
    expect(result.totalFee).toBe(0);
    expect(result.netRevenue).toBe(0);
  });

  it('calculates international one-time correctly', () => {
    // $100 transaction
    const result = calculatePolarFees(10000, true, false);
    expect(result.baseFee).toBe(440);        // 4% + $0.40
    expect(result.internationalFee).toBe(150); // 1.5%
    expect(result.totalFee).toBe(590);
    expect(result.netRevenue).toBe(9410);    // $94.10
  });

  it('preserves per-transaction flat fees in aggregate', () => {
    // Two $100 transactions should each have $0.40 flat fee
    const aggregate = calculateAggregatePolarFees([10000, 10000]);
    const single = calculatePolarFees(20000);

    expect(aggregate.totalFees).toBeGreaterThan(single.totalFee);
    // Difference should be one extra flat fee ($0.40)
    expect(aggregate.totalFees - single.totalFee).toBe(40);
  });
});
```
