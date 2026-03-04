# RevenueCat Dashboard Setup Checklist

Checklist de verify RevenueCat Dashboard da config dung cho Artio app.

## 1. Project Setup

- [x] Project da tao tren https://app.revenuecat.com (`proj7a945f6d`)
- [x] **Test Store app** da them (Apps > + New > "Test Store") (`appa68f39b27b`)
- [x] API key prefix `test_` (current: `test_OMDqQPXskGuySoMsazAoFwKuaZo`)

## 2. Products

- [x] Product cho **Pro** (`artio_pro_monthly`, `artio_pro_yearly`)
- [x] Product cho **Ultra** (`artio_ultra_monthly`, `artio_ultra_yearly`)
- [ ] Moi product co price duoc set

## 3. Entitlements

- [x] Entitlement **`pro`** — match string `pro` trong code (`entl2665d1fa2e`)
- [x] Entitlement **`ultra`** — match string `ultra` trong code (`entl0aba27660b`)
- [x] Products Pro gan vao entitlement `pro`
- [x] Products Ultra gan vao entitlement `ultra`

## 4. Offerings

- [x] Offering **`default`** da tao (`ofrngab4dda9897`)
- [x] Danh dau la **Current** (code dung `offerings.current`)
- [x] 4 Packages (`$rc_monthly`, `$rc_annual`, `artio_ultra_monthly`, `artio_ultra_annual`)
- [x] Moi package gan dung product

## 5. Verify

- [x] Offerings > `default` > thay packages + products
- [x] Entitlements > `pro`/`ultra` > co products gan
- [ ] API Keys > key thuoc Test Store app
- [ ] Chay app debug > console in `"Offerings fetched"`
