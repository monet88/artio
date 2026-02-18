# Error Handling

**TypeScript:**
```typescript
try {
  const product = await polar.products.get(productId);
} catch (error) {
  if (error.statusCode === 404) {
    console.error('Product not found');
  } else if (error.statusCode === 429) {
    console.error('Rate limit exceeded');
  } else {
    console.error('API error:', error.message);
  }
}
```

**Python:**
```python
from polar_sdk.exceptions import PolarException

try:
    product = polar.products.get(product_id)
except PolarException as e:
    if e.status_code == 404:
        print("Product not found")
    elif e.status_code == 429:
        print("Rate limit exceeded")
    else:
        print(f"API error: {e.message}")
```
