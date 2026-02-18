# Checkout API Implementation

### Standard SePay Checkout
```typescript
// app/api/checkout/sepay/route.ts
import { NextResponse } from 'next/server';
import { z } from 'zod';

const checkoutSchema = z.object({
  email: z.string().email(),
  name: z.string().optional(),
  productType: z.enum(['engineer_kit', 'marketing_kit', 'combo']),
  githubUsername: z.string().min(1),
  couponCode: z.string().optional(),
  vatInvoiceRequested: z.boolean().optional(),
  taxId: z.string().regex(/^\d{10}$|^\d{13}$/).optional(), // 10 or 13 digits
});

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const data = checkoutSchema.parse(body);

    // 1. Normalize email
    const normalizedEmail = data.email.toLowerCase().trim();

    // 2. Get base price
    const originalAmount = VND_PRICES[data.productType];
    let finalAmount = originalAmount;
    let discountMetadata: Record<string, any> = { originalAmount };

    // 3. CRITICAL: Apply discounts in correct order
    // Step A: Apply coupon FIRST
    if (data.couponCode) {
      const couponResult = await validateCouponForVND(data.couponCode, originalAmount);
      if (couponResult.valid) {
        finalAmount = originalAmount - couponResult.discountAmountVND;
        discountMetadata.couponCode = data.couponCode;
        discountMetadata.couponDiscountAmount = couponResult.discountAmountVND;
        discountMetadata.couponId = couponResult.couponId;
      }
    }

    // Step B: Apply referral SECOND (on post-coupon amount)
    const referralCode = getReferralCodeFromCookie(request);
    if (referralCode) {
      const referralResult = await calculateReferralDiscountVND(
        referralCode,
        finalAmount, // Post-coupon amount
        normalizedEmail
      );
      if (referralResult.valid && referralResult.discountAmount > 0) {
        // Validate calculation
        if (referralResult.discountAmount <= 0) {
          return NextResponse.json(
            { error: 'Invalid discount calculation' },
            { status: 400 }
          );
        }
        finalAmount -= referralResult.discountAmount;
        discountMetadata.referralCode = referralCode;
        discountMetadata.referralDiscountAmount = referralResult.discountAmount;
        discountMetadata.referrerId = referralResult.referrerId;
      }
    }

    // 4. Validate final amount
    if (finalAmount <= 0) {
      return NextResponse.json(
        { error: 'Invalid final amount' },
        { status: 400 }
      );
    }

    // 5. Encrypt sensitive data if VAT invoice requested
    let encryptedTaxId: string | null = null;
    if (data.vatInvoiceRequested && data.taxId) {
      encryptedTaxId = await encrypt(data.taxId);
    }

    // 6. Create order record
    const orderId = crypto.randomUUID();
    const transactionContent = `CLAUDEKIT ${orderId}`;

    const order = await db.insert(orders).values({
      id: orderId,
      email: normalizedEmail,
      productType: data.productType,
      amount: finalAmount,
      currency: 'VND',
      status: 'pending',
      paymentProvider: 'sepay',
      paymentId: transactionContent, // Used for matching
      referredBy: discountMetadata.referrerId,
      discountAmount: originalAmount - finalAmount,
      metadata: JSON.stringify({
        ...discountMetadata,
        githubUsername: data.githubUsername,
        vatInvoiceRequested: data.vatInvoiceRequested,
        encryptedTaxId,
      }),
    }).returning();

    // 7. Generate payment instructions
    const qrCode = generateVietQRUrl(
      process.env.SEPAY_ACCOUNT_NUMBER!,
      process.env.SEPAY_BANK_NAME!,
      finalAmount,
      transactionContent
    );

    return NextResponse.json({
      orderId: order[0].id,
      paymentMethod: 'bank_transfer',
      payment: {
        bankName: process.env.SEPAY_BANK_NAME,
        accountNumber: process.env.SEPAY_ACCOUNT_NUMBER,
        accountName: process.env.SEPAY_ACCOUNT_NAME,
        amount: finalAmount,
        currency: 'VND',
        content: transactionContent,
        qrCode,
        instructions: [
          'Open your banking app',
          'Scan the QR code or transfer manually',
          'Use the exact transfer content shown',
          'Payment will be confirmed automatically',
        ],
      },
      statusCheckUrl: `/api/orders/${order[0].id}/status`,
    });

  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json({ error: error.errors }, { status: 400 });
    }
    console.error('SePay checkout error:', error);
    return NextResponse.json(
      { error: 'Failed to create checkout' },
      { status: 500 }
    );
  }
}
```
