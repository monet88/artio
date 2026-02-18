# Framework Examples

### Next.js
```typescript
// app/actions/checkout.ts
'use server'

export async function createCheckout(productPriceId: string) {
  const session = await polar.checkouts.create({
    product_price_id: productPriceId,
    success_url: `${process.env.NEXT_PUBLIC_URL}/success?checkout_id={CHECKOUT_ID}`,
    external_customer_id: await getCurrentUserId()
  });

  return session.url;
}

// app/product/page.tsx
export default function ProductPage() {
  async function handleCheckout() {
    const url = await createCheckout(productPriceId);
    window.location.href = url;
  }

  return <button onClick={handleCheckout}>Buy Now</button>;
}
```

### Laravel
```php
Route::post('/checkout', function (Request $request) {
    $polar = new Polar(config('polar.access_token'));

    $session = $polar->checkouts->create([
        'product_price_id' => $request->input('product_price_id'),
        'success_url' => route('checkout.success'),
        'external_customer_id' => auth()->id(),
    ]);

    return redirect($session['url']);
});
```
