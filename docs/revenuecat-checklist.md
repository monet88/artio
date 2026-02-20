# RevenueCat Dashboard Setup Checklist

Checklist để verify RevenueCat Dashboard đã config đúng cho Artio app.

## 1. Project Setup

- [ ] Project đã tạo trên https://app.revenuecat.com
- [ ] **Test Store app** đã thêm (Apps → + New → "Test Store")
- [ ] API key prefix `test_` (current: `test_OMDqQPXskGuySoMsazAoFwKuaZo`)

## 2. Products

- [ ] Product cho **Pro** (e.g. `pro_monthly`, `pro_yearly`)
- [ ] Product cho **Ultra** (e.g. `ultra_monthly`, `ultra_yearly`)
- [ ] Mỗi product có price được set

## 3. Entitlements

- [ ] Entitlement **`pro`** — match string `pro` trong code
- [ ] Entitlement **`ultra`** — match string `ultra` trong code
- [ ] Products Pro gắn vào entitlement `pro`
- [ ] Products Ultra gắn vào entitlement `ultra`

## 4. Offerings

- [ ] Offering **`default`** đã tạo
- [ ] Đánh dấu là **Current** (code dùng `offerings.current`)
- [ ] Ít nhất 1 Package (e.g. `$rc_monthly`, `$rc_annual`)
- [ ] Mỗi package gắn đúng product

## 5. Verify

- [ ] Offerings → `default` → thấy packages + products
- [ ] Entitlements → `pro`/`ultra` → có products gắn
- [ ] API Keys → key thuộc Test Store app
- [ ] Chạy app debug → console in `"Offerings fetched"`
