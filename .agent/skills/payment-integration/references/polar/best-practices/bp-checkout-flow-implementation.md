# Checkout Flow Implementation

### Standard Checkout API
```typescript
// app/api/checkout/polar/route.ts
import { NextResponse } from 'next/server';
import { z } from 'zod';
import { getPolar, getPolarEnv } from '@/lib/polar';

const checkoutSchema = z.object({
  email: z.string().email(),
  name: z.string().optional(),
  productType: z.enum(['engineer_kit', 'marketing_kit', 'combo']),
  githubUsername: z.string().min(1),
  referralCode: z.string().regex(/^[A-Z0-9]{8}$/).optional(),
  couponCode: z.string().optional(),
});

// Pricing in cents
const PRODUCT_PRICES = {
  engineer_kit: 9900,   // $99
  marketing_kit: 9900,  // $99
  combo: 14900,         // $149
} as const;

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const data = checkoutSchema.parse(body);
    const polar = getPolar();
    const env = getPolarEnv();

    // 1. Normalize email
    const normalizedEmail = data.email.toLowerCase().trim();

    // 2. Validate GitHub username against GitHub API
    const githubValid = await validateGitHubUsername(data.githubUsername);
    if (!githubValid) {
      return NextResponse.json(
        { error: 'Invalid GitHub username' },
        { status: 400 }
      );
    }

    // 3. Get product ID and base price
    const productId = getProductId(data.productType);
    const originalAmount = PRODUCT_PRICES[data.productType];

    // 4. Apply discount hierarchy (order matters!)
    let finalAmount = originalAmount;
    let polarDiscountId: string | undefined;
    let discountMetadata: Record<string, any> = {};

    // Step A: Apply coupon FIRST (if provided)
    if (data.couponCode) {
      const couponResult = await validateAndApplyCoupon(
        data.couponCode,
        productId,
        originalAmount
      );
      if (couponResult.valid) {
        finalAmount = originalAmount - couponResult.discountAmount;
        discountMetadata.couponCode = data.couponCode;
        discountMetadata.couponDiscountAmount = couponResult.discountAmount;
      }
    }

    // Step B: Apply referral discount SECOND (on post-coupon price)
    if (data.referralCode) {
      const referralResult = await calculateReferralDiscount(
        data.referralCode,
        finalAmount, // Applied to post-coupon amount
        normalizedEmail
      );

      if (referralResult.valid && referralResult.discountAmount > 0) {
        // Validate discount calculation
        if (referralResult.discountAmount <= 0) {
          return NextResponse.json(
            { error: 'Invalid discount calculation - contact support' },
            { status: 400 }
          );
        }

        finalAmount -= referralResult.discountAmount;
        discountMetadata.referralCode = data.referralCode;
        discountMetadata.referralDiscountAmount = referralResult.discountAmount;
        discountMetadata.referrerId = referralResult.referrerId;
      }
    }

    // 5. Create order record BEFORE Polar checkout
    const order = await db.insert(orders).values({
      id: crypto.randomUUID(),
      email: normalizedEmail,
      productType: data.productType,
      amount: finalAmount,
      originalAmount,
      currency: 'USD',
      status: 'pending',
      paymentProvider: 'polar',
      referredBy: discountMetadata.referrerId,
      discountAmount: originalAmount - finalAmount,
      metadata: JSON.stringify({
        ...discountMetadata,
        githubUsername: data.githubUsername,
      }),
    }).returning();

    // 6. Create dynamic Polar discount (if referral applied)
    if (discountMetadata.referrerId && discountMetadata.referralDiscountAmount > 0) {
      try {
        const discount = await polar.discounts.create({
          type: 'fixed',
          name: `referral-${order[0].id.slice(0, 8)}`,
          amount: discountMetadata.referralDiscountAmount,
          currency: 'usd',
          duration: 'once',
          maxRedemptions: 1,
          products: [productId],
          metadata: {
            orderId: order[0].id,
            type: 'referral',
            referrerId: discountMetadata.referrerId,
          },
        });
        polarDiscountId = discount.id;
      } catch (error) {
        // FAIL-OPEN: Proceed with full price, flag for manual refund
        console.error('⚠️ Failed to create Polar discount:', error);
      }
    }

    // 7. Create Polar checkout session
    const checkout = await polar.checkouts.create({
      productPriceId: productId,
      customerEmail: normalizedEmail,
      successUrl: `${process.env.NEXT_PUBLIC_URL}/checkout/success?orderId=${order[0].id}`,
      discountId: polarDiscountId,
      allowDiscountCodes: !polarDiscountId, // Prevent stacking
      metadata: {
        orderId: order[0].id,
        githubUsername: data.githubUsername,
        referredBy: discountMetadata.referrerId,
      },
    });

    return NextResponse.json({
      checkoutUrl: checkout.url,
      orderId: order[0].id,
    });

  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json({ error: error.errors }, { status: 400 });
    }
    console.error('Checkout error:', error);
    return NextResponse.json(
      { error: 'Failed to create checkout' },
      { status: 500 }
    );
  }
}
```

### Discount Application Order (Critical)
```
1. Original price (e.g., $99)
2. Apply coupon discount FIRST → post-coupon price (e.g., $79)
3. Apply referral discount SECOND → final price (e.g., $63.20)

Never apply referral to original price if coupon was used!
```
