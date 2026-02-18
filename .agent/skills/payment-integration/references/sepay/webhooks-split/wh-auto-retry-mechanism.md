# Auto-Retry Mechanism

**Policy:**
- Retries up to 7 times over ~5 hours
- Fibonacci sequence intervals (1, 1, 2, 3, 5, 8, 13... minutes)

**Duplicate Prevention:**
```javascript
// Primary: Use transaction ID
const exists = await db.transactions.findOne({ sepay_id: data.id });
if (exists) return { success: true };

// Alternative: Composite key
const key = `${data.referenceCode}-${data.transferType}-${data.transferAmount}`;
```
