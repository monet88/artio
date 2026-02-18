# PHP

**Installation:**
```bash
composer require polar-sh/sdk
```

**Configuration:**
```php
use Polar\Polar;

$polar = new Polar(
    accessToken: $_ENV['POLAR_ACCESS_TOKEN'],
    server: 'production' // or 'sandbox'
);
```

**Usage:**
```php
// Products
$products = $polar->products->list(['organization_id' => 'org_xxx']);
$product = $polar->products->create(['name' => 'Pro Plan', ...]);

// Checkouts
$checkout = $polar->checkouts->create([
    'product_price_id' => 'price_xxx',
    'success_url' => 'https://example.com/success'
]);

// Subscriptions
$subs = $polar->subscriptions->list(['customer_id' => 'cust_xxx']);
$polar->subscriptions->update($subId, ['metadata' => ['plan' => 'pro']]);

// Orders
$orders = $polar->orders->list(['organization_id' => 'org_xxx']);
$order = $polar->orders->get($orderId);

// Events
$polar->events->create([
    'external_customer_id' => 'user_123',
    'event_name' => 'api_call',
    'properties' => ['tokens' => 1000]
]);
```
