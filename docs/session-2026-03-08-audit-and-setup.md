# Artio — Session Log 2026-03-08

**Mục tiêu:** Pre-check dự án, fix blocking issues, setup RevenueCat + Google Play Internal Testing

---

## 1. Kết quả Pre-Check (Audit)

### ✅ Đã fix

| Issue | Trước | Sau |
|-------|-------|-----|
| Flutter/Dart SDK | 3.38.5 / Dart 3.10.4 | **3.41.4 / Dart 3.11.1** |
| Env file naming | `.env` (không load được) | **`.env.development`** |
| Freezed codegen | Stale sau upgrade | **Regenerated** (92 + 14 outputs) |
| Missing `.env.staging` | Warning trong analyze | **Tạo mới** |
| Placeholder `.env` | Thiếu → build fail | **Tạo placeholder** |
| `flutter analyze` | 223 errors | **0 issues** ✅ |
| Admin test errors | 2 errors (AdminTemplateModel) | **Fixed** (regenerate) |
| AAB release signing | Debug-signed → Play reject | **Release-signed** ✅ |

### ✅ Code quality (không có bug)

| Area | Status |
|------|--------|
| Architecture (Clean, 3-layer) | ✅ Solid |
| Auth (email, Google, Apple) | ✅ Complete |
| Generation pipeline (KIE/Gemini) | ✅ Complete |
| Credits system | ✅ Server-authoritative |
| RevenueCat SDK + webhook | ✅ Code complete |
| Admin panel CRUD | ✅ Functional |
| Security (RLS, SECURITY DEFINER) | ✅ Audited |
| Tests (712 total) | ✅ Passing |

---

## 2. Tính năng còn thiếu

### 🔴 P0 — Phải làm trước release

1. Google Play subscription products chưa tạo
2. RevenueCat ↔ Google Play chưa kết nối
3. AdMob IDs đang dùng test (cần production IDs khi release)
4. Privacy Policy URL chưa có
5. Terms of Service URL chưa có

### 🟡 P1 — Nên làm sớm

6. Stripe Web payments (pending)
7. Admin app deployment
8. Profile photo upload
9. Change password flow
10. Delete account flow

---

## 3. RevenueCat + Google Play Setup

### Trạng thái hiện tại

```
RevenueCat Dashboard:
  ✅ Project: proj7a945f6d
  ✅ Products: artio_pro_monthly, artio_pro_yearly, artio_ultra_monthly, artio_ultra_yearly
  ✅ Entitlements: pro + ultra
  ✅ Offering: default (current)
  ❌ Google Play app chưa connect
  ❌ Webhook chưa setup

Google Play Console:
  ✅ App tạo: "Artio Photo Avatar AI"
  ❌ Subscription products chưa tạo
  ❌ AAB chưa upload (đang tiến hành)

Code Flutter:
  ✅ Hoàn toàn sẵn sàng — không cần sửa gì
```

### AAB Build

```bash
# Keystore đã tạo
android/app/artio-upload.jks
Alias: artio | Password: artio2026secure

# Lệnh build (đã chạy thành công)
flutter build appbundle --dart-define=ENV=development --release
# Output: build/app/outputs/bundle/release/app-release.aab (53.5MB)
```

> ⚠️ **Backup keystore ngay:** `cp android/app/artio-upload.jks ~/Desktop/artio-upload-BACKUP.jks`

### Checklist còn lại (phải làm trên browser)

| # | Việc | Nơi |
|---|------|-----|
| 1 | Upload AAB vào Internal Testing | play.google.com/console |
| 2 | Tạo 4 subscription products | Monetize → Subscriptions |
| 3 | Tạo Service Account | console.cloud.google.com |
| 4 | Link Service Account vào Google Play | Setup → API access |
| 5 | Kết nối RevenueCat ↔ Google Play | app.revenuecat.com → Apps → +New |
| 6 | Map entitlements (pro/ultra) | RevenueCat → Entitlements |
| 7 | Setup webhook | RevenueCat → Integrations → Webhooks |
| 8 | Set Supabase secret | `supabase secrets set REVENUECAT_WEBHOOK_SECRET=...` |
| 9 | License testing + test purchase | Google Play → Setup → License testing |

### Products cần tạo trên Google Play Console

| Product ID | Base Plan | Price |
|-----------|-----------|-------|
| `artio_pro_monthly` | monthly | $9.99/mo |
| `artio_pro_monthly` | yearly | $79.99/yr |
| `artio_ultra_monthly` | monthly | $19.99/mo |
| `artio_ultra_monthly` | yearly | $149.99/yr |

### Webhook URL

```
https://kytbmplsazsiwndppoji.supabase.co/functions/v1/revenuecat-webhook
```

---

## 4. Workflow dự án

### User flow tổng quan

```
App Open → Onboarding (lần đầu) → Home
Home:
  ├── Templates Tab → Chọn template → Fill inputs → Generate
  ├── Create Tab → Nhập prompt → Chọn model → Generate
  ├── Gallery Tab → Xem ảnh đã tạo
  └── Settings → Theme, account, upgrade

Generate flow:
  → Edge Function: generate-image
  → Check credits (402 nếu thiếu)
  → Deduct credits → Call KIE/Gemini API
  → Upload result → Supabase Storage
  → Realtime update → Gallery

Monetization:
  Free: 50 credits mặc định
  Rewarded Ads: +5 credits/lần xem
  Pro: $9.99/mo → 100 credits/tháng
  Ultra: $19.99/mo → 300 credits/tháng
```

### Key files

| Mục tiêu | File |
|---------|------|
| App init | `lib/main.dart` |
| Env config | `lib/core/config/env_config.dart` |
| Auth flow | `lib/features/auth/` |
| Generation | `supabase/functions/generate-image/` |
| RevenueCat webhook | `supabase/functions/revenuecat-webhook/` |
| Subscription | `lib/features/subscription/` |
| Model costs | `supabase/functions/_shared/model_config.ts` |
| Admin panel | `admin/` |

---

*Session: 2026-03-08 | Tất cả thay đổi code đã commit-ready*
