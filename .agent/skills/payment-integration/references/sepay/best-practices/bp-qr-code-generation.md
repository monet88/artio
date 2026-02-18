# QR Code Generation

### VietQR URL Pattern
```typescript
// lib/sepay.ts
export function generateVietQRUrl(
  accountNumber: string,
  bankName: string,
  amount: number,
  content: string
): string {
  const params = new URLSearchParams({
    acc: accountNumber,
    bank: bankName,
    amount: String(Math.floor(amount)), // Integer only
    des: content,
  });

  return `https://qr.sepay.vn/img?${params.toString()}`;
}
```

### Usage Example
```typescript
const qrUrl = generateVietQRUrl(
  process.env.SEPAY_ACCOUNT_NUMBER!,
  process.env.SEPAY_BANK_NAME!,
  2450000,
  `CLAUDEKIT ${orderId}`
);
// Returns: https://qr.sepay.vn/img?acc=0123456789&bank=Vietcombank&amount=2450000&des=CLAUDEKIT+uuid
```
