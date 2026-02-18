# Bank Codes

**Get Bank List:**
```
GET https://qr.sepay.vn/banks.json
```

**Common Banks:**
- Vietcombank (VCB)
- VPBank
- BIDV
- Techcombank (TCB)
- ACB
- MB Bank
- Sacombank
- VietinBank
- And 40+ others

**Cache Bank List:**
```javascript
// Fetch once and cache
const banks = await fetch('https://qr.sepay.vn/banks.json')
  .then(res => res.json());

// Store in memory or Redis
cache.set('sepay_banks', banks, 86400); // 24 hours
```
