# Environment Configuration

### Required Environment Variables
```bash
# Core API
SEPAY_API_TOKEN=xxx              # Bearer token for SePay API
SEPAY_WEBHOOK_API_KEY=xxx        # API key for webhook authentication
SEPAY_API_URL=https://my.sepay.vn/userapi  # Base URL (optional)

# Bank Account Details
SEPAY_ACCOUNT_NUMBER=0123456789  # Bank account for transfers
SEPAY_ACCOUNT_NAME=COMPANY_NAME  # Account holder name
SEPAY_BANK_NAME=Vietcombank      # Bank name (VietQR recognized)
```

### Product Pricing in VND
```typescript
// lib/sepay.ts
const VND_PRICES = {
  engineer_kit: 2450000,   // ~$100 USD
  marketing_kit: 2450000,  // ~$100 USD
  combo: 3650000,          // ~$149 USD
} as const;

const USD_TO_VND_RATE = 24500; // 1 USD ≈ 24,500 VND
```
