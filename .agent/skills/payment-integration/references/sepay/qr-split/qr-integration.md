# Integration

### HTML
```html
<img src="https://qr.sepay.vn/img?acc=0010000000355&bank=Vietcombank&amount=100000"
     alt="Payment QR Code" />
```

### JavaScript (Dynamic)
```javascript
function generatePaymentQR(account, bank, amount, description) {
  const params = new URLSearchParams({
    acc: account,
    bank: bank,
    amount: amount,
    des: description
  });
  return `https://qr.sepay.vn/img?${params}`;
}

// Usage
const qrUrl = generatePaymentQR(
  '0010000000355',
  'Vietcombank',
  100000,
  'Order #12345'
);

document.getElementById('qr-code').src = qrUrl;
```

### PHP (Dynamic)
```php
<?php
function generatePaymentQR($account, $bank, $amount, $description) {
    return 'https://qr.sepay.vn/img?' . http_build_query([
        'acc' => $account,
        'bank' => $bank,
        'amount' => $amount,
        'des' => $description
    ]);
}

// Usage
$qrUrl = generatePaymentQR(
    '0010000000355',
    'Vietcombank',
    100000,
    'Order #' . $orderId
);

echo "<img src='{$qrUrl}' alt='Payment QR' />";
?>
```

### Node.js (Express)
```javascript
app.get('/payment/:orderId/qr', async (req, res) => {
  const order = await Order.findById(req.params.orderId);

  const qrUrl = new URL('https://qr.sepay.vn/img');
  qrUrl.searchParams.set('acc', process.env.SEPAY_ACCOUNT);
  qrUrl.searchParams.set('bank', process.env.SEPAY_BANK);
  qrUrl.searchParams.set('amount', order.total);
  qrUrl.searchParams.set('des', `Order ${order.id}`);

  res.render('payment', { qrUrl: qrUrl.toString() });
});
```

### React Component
```jsx
function PaymentQR({ account, bank, amount, description }) {
  const qrUrl = useMemo(() => {
    const params = new URLSearchParams({
      acc: account,
      bank: bank,
      amount: amount,
      des: description
    });
    return `https://qr.sepay.vn/img?${params}`;
  }, [account, bank, amount, description]);

  return (
    <div className="payment-qr">
      <img src={qrUrl} alt="Payment QR Code" />
      <p>Scan to pay {amount.toLocaleString('vi-VN')} VND</p>
    </div>
  );
}
```
