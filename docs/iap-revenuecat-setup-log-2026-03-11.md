# IAP RevenueCat Setup Log — 2026-03-11

## Mục tiêu

Fix toàn bộ IAP flow để: purchase → RC server nhận → RC webhook fire → Supabase cập nhật `is_premium=true` + grant 500 credits.

---

## Vấn đề ban đầu

| Triệu chứng | Nguyên nhân |
|---|---|
| RC Dashboard: 0 Active Subscribers | Google Play RTDN topic = "adada" (invalid) + Pub/Sub chưa setup |
| Supabase: `is_premium=false` sau purchase | `sync-subscription` downgrade user về free khi RC API trả empty |
| Credits không được grant | Webhook không fire vì RC server chưa nhận event |
| Double-grant risk | `sync-subscription` VÀ webhook đều grant credits với reference_id khác nhau |

---

## Việc đã làm

### Code fixes (đã deploy)

**1. `supabase/functions/sync-subscription/index.ts`**
- Xóa hoàn toàn `grant_subscription_credits` section (tránh double-grant)
- Thêm guard: khi RC V2 API trả empty → return `{synced: false, reason: "no_active_entitlements"}`, không chạm Supabase
- Chỉ update `is_premium/tier` khi RC có entitlement thực sự
- Deployed lên production: `kytbmplsazsiwndppoji`

**2. `lib/features/subscription/presentation/providers/subscription_provider.dart`**
- `_syncToSupabase()`: parse response, log rõ `synced:false/true` để debug

**3. Version bump + AAB build**
- `pubspec.yaml`: `1.0.0+9` → `1.0.0+10`
- Built: `build/app/outputs/bundle/release/app-release.aab` (54.1MB)
- Uploaded lên Play Console Internal Testing track

### Dashboard setup (manual)

**Google Cloud Console:**
- Enable Cloud Pub/Sub API cho project `artio-revenuecat-2026`
- Tạo topic: `projects/artio-revenuecat-2026/topics/revenuecat-artio`
- Grant service account: `Pub/Sub Admin` role ở project level

**RC Dashboard (ARTIO → Play Store):**
- Connected to Google: ✅ `projects/artio-revenuecat-2026/topics/revenuecat-artio`
- Status: "Connected to Google" ✅

**Google Play Console (Monetization setup):**
- Topic name: `projects/artio-revenuecat-2026/topics/revenuecat-artio`
- Send test notification: ✅ thành công
- Notification content: "Subscriptions, voided purchases, and all one-time products"

---

## Kết quả test (2026-03-11 ~17:43)

**Email test:** `galaxypro710@gmail.com`
**Device:** SM-A536E (Samsung A53)
**App version:** 1.0.0+10 (Internal Testing)

| Check | Kết quả |
|---|---|
| App UI sau purchase | ✅ Hiện "Ultra premium" |
| RC Dashboard customers | ❌ Không có customer nào |
| Supabase `is_premium` | ❌ Vẫn `false` |
| Credits granted | ❌ Chưa được grant tự động |
| Webhook fired | ❌ Không có event nào |

**Manual fix đã thực hiện:**
- `is_premium=true`, `subscription_tier=ultra` cho galaxypro710
- Grant 500 credits (ref: `manual-fix-2026-03-11`)
- Balance hiện tại: 504

---

## Root Cause còn lại

**Vấn đề:** RC server chưa nhận được purchase event.

**Nguyên nhân có thể:**

1. **Timing** (khả năng cao): Purchase xảy ra ~1.5h sau khi setup Pub/Sub. RC's Push Subscription endpoint cần thời gian để RC backend activate. Pipeline chưa stable khi purchase được thực hiện.

2. **36h credentials propagation**: RC service account cần tối đa 36h để Google Play Developer API chấp nhận. Dù RC hiện "Valid credentials ✅", nếu service account vừa được tạo gần đây, validation có thể chưa hoàn toàn hoạt động.

3. **RC chưa nhận RTDN test**: RC Dashboard hiện "No notifications received" — chưa confirm Pub/Sub → RC pipeline đang hoạt động.

---

## Next Steps

### Kiểm tra ngay (không cần chờ)

1. **RC Dashboard** → ARTIO (Play Store) → cạnh "No notifications received" → click **"Send a test?"** (text link màu xanh nhỏ)
   - Nếu counter tăng → pipeline OK → thử purchase mới ngay
   - Nếu không tăng → RC chưa nhận được Pub/Sub messages → debug thêm

2. **Google Cloud Console** → Pub/Sub → Subscriptions → kiểm tra có subscription nào do RC tạo không (format: `revenuecat-*`)

### Nếu pipeline OK (test notification được nhận)

- Thử purchase với email mới chưa từng mua
- Verify: RC Dashboard hiện customer → Supabase update → 500 credits

### Nếu vẫn lỗi sau 36h

- Kiểm tra RC Webhook URL đã được set chưa: RC Dashboard → Integrations → Webhooks → phải có URL của Supabase edge function `revenuecat-webhook`
- Kiểm tra Supabase secrets: `REVENUECAT_WEBHOOK_SECRET` đã set chưa

---

## Webhook URL cần verify

Webhook URL phải là:
```
https://kytbmplsazsiwndppoji.supabase.co/functions/v1/revenuecat-webhook
```

Vào RC Dashboard → Integrations → Webhooks → verify URL này đã được add.

---

## Commits đã tạo

```
0cdc4394 fix(sync-subscription): remove credit grant (webhook owns credits), skip update when RC empty
f6c5a68e fix(subscription): log sync-subscription response for RC debugging
6c2f0542 chore: bump version to 1.0.0+10 for IAP fix build
a8b5a39e docs: fix version bump as required step in IAP plan
638f1a28 docs: patch IAP final fix plan
3b4ff6b8 docs: add final IAP fix implementation plan
```

PR: #69 `fix/credit-exhausted-no-upgrade-option`
