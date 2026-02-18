# Go

**Installation:**
```bash
go get github.com/polarsource/polar-go
```

**Usage:**
```go
import (
    "github.com/polarsource/polar-go"
)

client := polar.NewClient(
    polar.WithAccessToken(os.Getenv("POLAR_ACCESS_TOKEN")),
    polar.WithEnvironment("production"),
)

// Products
products, err := client.Products.List(ctx, &polar.ProductListParams{
    OrganizationID: "org_xxx",
})

// Checkouts
checkout, err := client.Checkouts.Create(ctx, &polar.CheckoutCreateParams{
    ProductPriceID: "price_xxx",
    SuccessURL:     "https://example.com/success",
})
```
