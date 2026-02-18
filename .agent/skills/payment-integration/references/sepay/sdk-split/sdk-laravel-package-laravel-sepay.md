# Laravel Package (laravel-sepay)

**Installation:**
```bash
composer require sepayvn/laravel-sepay

# For Laravel 7-8 with PHP 7.4+
composer require "sepayvn/laravel-sepay:dev-lite"
```

**Setup:**
```bash
php artisan vendor:publish --tag="sepay-migrations"
php artisan migrate
php artisan vendor:publish --tag="sepay-config"
php artisan vendor:publish --tag="sepay-views"  # optional
```

**Configuration (.env):**
```
SEPAY_WEBHOOK_TOKEN=your_secret_key
SEPAY_MATCH_PATTERN=SE
```

**Create Event Listener:**
```bash
php artisan make:listener SePayWebhookListener
```

**Listener Implementation:**
```php
<?php

namespace App\Listeners;

use SePayWebhookEvent;

class SePayWebhookListener
{
    public function handle(SePayWebhookEvent $event)
    {
        $transaction = $event->transaction;

        if ($transaction->transfer_type === 'in') {
            // Handle incoming payment
            Order::where('code', $transaction->content)
                ->update(['status' => 'paid']);

            // Send confirmation email
            Mail::to($order->customer->email)
                ->send(new PaymentConfirmation($order));
        }
    }
}
```

**Register Listener:**
```php
// app/Providers/EventServiceProvider.php
protected $listen = [
    SePayWebhookEvent::class => [
        SePayWebhookListener::class,
    ],
];
```
