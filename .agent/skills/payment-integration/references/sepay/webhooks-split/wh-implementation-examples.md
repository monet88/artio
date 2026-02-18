# Implementation Examples

### Node.js/Express
```javascript
app.post('/webhook/sepay', async (req, res) => {
  const transaction = req.body;

  // Check duplicates
  if (await isDuplicate(transaction.id)) {
    return res.json({ success: true });
  }

  // Process transaction
  if (transaction.transferType === 'in') {
    await processPayment({
      amount: transaction.transferAmount,
      content: transaction.content,
      referenceCode: transaction.referenceCode
    });
  }

  // Save to database
  await db.transactions.insert(transaction);

  res.json({ success: true });
});
```

### PHP
```php
<?php
$data = json_decode(file_get_contents('php://input'), true);

// Check duplicates
$exists = $db->query("SELECT id FROM transactions WHERE sepay_id = ?", [$data['id']]);
if ($exists) {
    echo json_encode(['success' => true]);
    exit;
}

// Process payment
if ($data['transferType'] == 'in') {
    processPayment($data['transferAmount'], $data['content']);
}

// Save to database
$db->insert('transactions', [
    'sepay_id' => $data['id'],
    'amount' => $data['transferAmount'],
    'content' => $data['content'],
    'reference_code' => $data['referenceCode']
]);

header('Content-Type: application/json');
echo json_encode(['success' => true]);
```
