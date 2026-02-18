# PHP SDK (sepay/sepay-pg)

**Installation:**
```bash
composer require sepay/sepay-pg
```

**Requirements:** PHP 7.4+, ext-json, ext-curl, Guzzle

**Quick Start:**
```php
use SePay\SePayClient;
use SePay\Builders\CheckoutBuilder;

$sepay = new SePayClient(
    'SP-TEST-XXXXXXX',
    'spsk_live_xxxxxxxxxxxxx',
    SePayClient::ENVIRONMENT_SANDBOX
);

$checkoutData = CheckoutBuilder::make()
    ->currency('VND')
    ->orderAmount(100000)
    ->operation('PURCHASE')
    ->orderDescription('Test payment')
    ->orderInvoiceNumber('INV_001')
    ->successUrl('https://yoursite.com/success')
    ->errorUrl('https://yoursite.com/error')
    ->cancelUrl('https://yoursite.com/cancel')
    ->build();

echo $sepay->checkout()->generateFormHtml($checkoutData);
```

**Error Handling:**
```php
try {
    $order = $sepay->orders()->retrieve('INV_001');
} catch (AuthenticationException $e) {
    // Invalid credentials
} catch (ValidationException $e) {
    // Invalid request data
    $errors = $e->getErrors();
} catch (NotFoundException $e) {
    // Resource not found
} catch (RateLimitException $e) {
    // Rate limit exceeded
    $retryAfter = $e->getRetryAfter();
} catch (ServerException $e) {
    // Server error (5xx)
}
```

**Configuration:**
```php
$sepay->setConfig([
    'timeout' => 30,
    'retry_attempts' => 3,
    'retry_delay' => 1000,
    'debug' => true,
    'user_agent' => 'MyApp/1.0',
    'logger' => $psrLogger
]);
```
