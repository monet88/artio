# Invoice Email Template

### HTML Invoice Generation
```typescript
// lib/emails/sepay-invoice.ts
export function generateSepayInvoice(order: Order, transaction: TransactionInfo): string {
  const metadata = JSON.parse(order.metadata || '{}');
  const invoiceNumber = `INV-${format(new Date(), 'yyyyMMdd')}-${order.id.slice(-8).toUpperCase()}`;

  // Format VND with Vietnamese locale
  const formatVND = (amount: number) =>
    new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(amount);

  // Escape HTML to prevent XSS
  const escapeHtml = (text: string) =>
    text.replace(/[&<>"']/g, char => ({
      '&': '&amp;',
      '<': '&lt;',
      '>': '&gt;',
      '"': '&quot;',
      "'": '&#39;',
    })[char] || char);

  return `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        .invoice { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; }
        .header { background: linear-gradient(135deg, #ff6b6b, #feca57); padding: 20px; }
        .status { background: #10b981; color: white; padding: 4px 12px; border-radius: 4px; }
        .amount { font-size: 24px; font-weight: bold; }
        .savings { color: #10b981; }
      </style>
    </head>
    <body>
      <div class="invoice">
        <div class="header">
          <h1>Invoice</h1>
          <span class="status">PAID</span>
        </div>

        <table>
          <tr><td>Invoice #:</td><td>${invoiceNumber}</td></tr>
          <tr><td>Customer:</td><td>${escapeHtml(metadata.name || order.email)}</td></tr>
          <tr><td>Email:</td><td>${escapeHtml(order.email)}</td></tr>
          <tr><td>Payment Date:</td><td>${format(new Date(transaction.transactionDate), 'dd/MM/yyyy HH:mm')}</td></tr>
          <tr><td>Transaction Ref:</td><td>${transaction.transactionId || 'N/A'}</td></tr>
        </table>

        <h3>Order Details</h3>
        <table>
          <tr><td>Product:</td><td>${getProductName(order.productType)}</td></tr>
          <tr><td>Original Price:</td><td>${formatVND(metadata.originalAmount || order.amount)}</td></tr>
          ${metadata.couponDiscountAmount ? `
            <tr><td>Coupon (${metadata.couponCode}):</td><td>-${formatVND(metadata.couponDiscountAmount)}</td></tr>
          ` : ''}
          ${metadata.referralDiscountAmount ? `
            <tr><td>Referral Discount (20%):</td><td>-${formatVND(metadata.referralDiscountAmount)}</td></tr>
          ` : ''}
          ${order.discountAmount > 0 ? `
            <tr class="savings"><td>Total Savings:</td><td>-${formatVND(order.discountAmount)}</td></tr>
          ` : ''}
          <tr class="amount"><td>Total Paid:</td><td>${formatVND(order.amount)}</td></tr>
        </table>

        <p>Thank you for your purchase!</p>
        <p>Support: support@claudekit.com</p>
      </div>
    </body>
    </html>
  `;
}
```
