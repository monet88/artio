# Payload Structure

```json
{
  "id": 92704,
  "gateway": "Vietcombank",
  "transactionDate": "2023-03-25 14:02:37",
  "accountNumber": "0123499999",
  "code": null,
  "content": "payment content",
  "transferType": "in",
  "transferAmount": 2277000,
  "accumulated": 19077000,
  "subAccount": null,
  "referenceCode": "MBVCB.3278907687"
}
```

**Fields:**
- `id` - Unique transaction ID (use for deduplication)
- `gateway` - Bank name
- `transactionDate` - Transaction timestamp
- `accountNumber` - Bank account number
- `code` - Payment code (if available)
- `content` - Transfer description/content
- `transferType` - "in" (incoming) or "out" (outgoing)
- `transferAmount` - Transaction amount
- `accumulated` - Account balance after transaction
- `subAccount` - Sub-account identifier
- `referenceCode` - Bank transaction reference
