# Python

**Installation:**
```bash
pip install polar-sdk
```

**Configuration:**
```python
from polar_sdk import Polar

polar = Polar(
    access_token=os.environ["POLAR_ACCESS_TOKEN"],
    server="production"  # or "sandbox"
)
```

**Sync Usage:**
```python
# Products
products = polar.products.list(organization_id="org_xxx")
product = polar.products.create(name="Pro Plan", ...)

# Checkouts
checkout = polar.checkouts.create(
    product_price_id="price_xxx",
    success_url="https://example.com/success"
)

# Subscriptions
subs = polar.subscriptions.list(customer_id="cust_xxx")
polar.subscriptions.update(sub_id, metadata={"plan": "pro"})

# Orders
orders = polar.orders.list(organization_id="org_xxx")
order = polar.orders.get(order_id)

# Events
polar.events.create(
    external_customer_id="user_123",
    event_name="api_call",
    properties={"tokens": 1000}
)
```

**Async Usage:**
```python
import asyncio
from polar_sdk import AsyncPolar

async def main():
    polar = AsyncPolar(access_token=os.environ["POLAR_ACCESS_TOKEN"])

    products = await polar.products.list(organization_id="org_xxx")
    checkout = await polar.checkouts.create(...)

asyncio.run(main())
```
