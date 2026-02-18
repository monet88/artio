# Integration Patterns

### Checkout Page
```html
<div class="payment-methods">
  <h3>Pay via Bank Transfer</h3>
  <img src="[QR_URL]" alt="Payment QR Code" class="qr-code" />
  <p>Scan this QR code with your banking app</p>
  <div class="payment-details">
    <p><strong>Account:</strong> 0010000000355</p>
    <p><strong>Bank:</strong> Vietcombank</p>
    <p><strong>Amount:</strong> 100,000 VND</p>
    <p><strong>Content:</strong> Order #12345</p>
  </div>
</div>
```

### Email Receipt
```html
<table>
  <tr>
    <td align="center">
      <img src="[QR_URL]" alt="Payment QR Code" width="200" />
      <p>Scan to pay for your order</p>
    </td>
  </tr>
</table>
```

### PDF Invoice
Use QR URL in PDF generation libraries (wkhtmltopdf, Puppeteer, etc.)
