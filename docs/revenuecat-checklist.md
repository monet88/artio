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

---

## Huong Dan Thuc Hien Cac Item Chua Check

### Item 1: Set price cho moi product (Section 2)

**Van de:** Products da tao nhung chua co price — can set gia tren RevenueCat dashboard.

**Buoc thuc hien:**

1. Mo https://app.revenuecat.com > Project `proj7a945f6d` > **Products**
2. Voi moi product, click vao va set price:

   | Product ID | Platform | Price |
   |-----------|----------|-------|
   | `artio_pro_monthly` | App Store / Play Store | $9.99/month |
   | `artio_pro_yearly` | App Store / Play Store | $79.99/year |
   | `artio_ultra_monthly` | App Store / Play Store | $19.99/month |
   | `artio_ultra_yearly` | App Store / Play Store | $149.99/year |

3. **Luu y:** Price thuc te phai set tren **App Store Connect** (iOS) va **Google Play Console** (Android), khong phai tren RevenueCat. RevenueCat chi map product ID toi store product.

   - **iOS**: App Store Connect > My Apps > Artio > Subscriptions > tao Subscription Group > them 4 products voi price tuong ung
   - **Android**: Google Play Console > Artio > Monetize > Products > Subscriptions > them 4 products voi price tuong ung

4. Quay lai RevenueCat > Products > verify moi product hien thi dung price tu store

### Item 2: Verify API Key thuoc Test Store app (Section 5)

**Van de:** Can xac nhan API key dang dung thuoc Test Store app (khong phai production).

**Buoc thuc hien:**

1. Mo https://app.revenuecat.com > Project > **API Keys** (sidebar)
2. Tim key bat dau bang `test_` — hien tai: `test_OMDqQPXskGuySoMsazAoFwKuaZo`
3. Verify:
   - Key co label/tag la **Test Store** (`appa68f39b27b`)
   - Key **KHONG** phai la production key (production key bat dau bang `appl_` hoac `goog_`)
4. Check file `.env.development` trong project:

   ```env
   REVENUECAT_APPLE_KEY=test_OMDqQPXskGuySoMsazAoFwKuaZo
   REVENUECAT_GOOGLE_KEY=test_OMDqQPXskGuySoMsazAoFwKuaZo
   ```

5. Confirm code doc key tu env — da xac nhan trong `lib/core/config/env_config.dart`:

   ```dart
   static String get revenuecatAppleKey =>
       dotenv.env['REVENUECAT_APPLE_KEY'] ?? '';
   static String get revenuecatGoogleKey =>
       dotenv.env['REVENUECAT_GOOGLE_KEY'] ?? '';
   ```

6. Key duoc truyen vao `Purchases.configure()` tai `lib/main.dart:72-80`:

   ```dart
   final rcKey = Platform.isIOS
       ? EnvConfig.revenuecatAppleKey
       : EnvConfig.revenuecatGoogleKey;
   await Purchases.configure(PurchasesConfiguration(rcKey));
   ```

**Ket qua mong doi:** Key prefix la `test_`, thuoc Test Store app, match voi `.env.development`.

### Item 3: Chay app debug, console in "Offerings fetched" (Section 5)

**Van de:** Can verify app co the fetch offerings thanh cong tu RevenueCat.

**Yeu cau truoc:**
- Device/emulator (iOS hoac Android) — **KHONG chay tren web** (RevenueCat skip web, xem `main.dart:71`)
- `.env.development` co `REVENUECAT_APPLE_KEY` hoac `REVENUECAT_GOOGLE_KEY` hop le
- Internet connection

**Buoc thuc hien:**

1. Chay app debug mode:

   ```bash
   flutter run --dart-define=ENV=development
   ```

2. RevenueCat tu dong bat debug log khi `kDebugMode` (`main.dart:77-79`):

   ```dart
   if (kDebugMode) {
     await Purchases.setLogLevel(LogLevel.debug);
   }
   ```

3. Quan sat console log, tim cac dong sau:

   ```
   // Mong doi thay (RevenueCat debug logs):
   [Purchases] - DEBUG: Configuring Purchases SDK
   [Purchases] - DEBUG: offerings fetched from network
   ```

4. Verify trong app:
   - Navigate toi Paywall screen (Settings > Upgrade hoac credit sheet > Upgrade)
   - Paywall hien thi danh sach packages (Pro Monthly, Pro Yearly, Ultra Monthly, Ultra Yearly)
   - Neu hien thi error: check console log, co the do:
     - Key sai → fix `.env.development`
     - Products chua tao tren store → thuc hien Item 1 truoc
     - Network error → check internet

5. Verify trong code — offerings provider tai `lib/features/subscription/presentation/providers/subscription_provider.dart:54`:

   ```dart
   @riverpod
   Future<List<SubscriptionPackage>> offerings(Ref ref) async {
     final repo = ref.watch(subscriptionRepositoryProvider);
     return repo.getOfferings();
   }
   ```

   Repository fetch tai `lib/features/subscription/data/repositories/subscription_repository.dart:33`:

   ```dart
   Future<List<SubscriptionPackage>> getOfferings() async {
     final offerings = await Purchases.getOfferings();
     final packages = offerings.current?.availablePackages ?? <Package>[];
     // ... map to domain SubscriptionPackage
   }
   ```

6. **Optional:** Them log tam de verify (xong thi xoa):

   ```dart
   // Trong subscription_repository.dart, sau dong 35:
   debugPrint('Offerings fetched: ${packages.length} packages');
   ```

**Ket qua mong doi:** Console hien thi RevenueCat debug logs, Paywall hien thi 4 packages dung gia.
