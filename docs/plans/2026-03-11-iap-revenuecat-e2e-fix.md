# IAP RevenueCat End-to-End Fix — Design Document

**Date:** 2026-03-11
**Branch:** fix/credit-exhausted-no-upgrade-option
**Status:** Approved, ready for implementation

---

## Problem Statement

User mua subscription thành công trên device (RC SDK trả về entitlement ultra), nhưng:
1. RC Dashboard: 0 Active Subscribers (RC server chưa nhận/record purchase)
2. Supabase: `is_premium=false`, `subscription_tier=free` (sync-subscription downgrade về free)
3. Credits: 0 (không có `grant_subscription_credits` nào fire)
4. Sau reinstall/logout: entitlement local trên device sẽ mất

---

## Root Causes

| # | Vấn đề | Layer | Mức độ |
|---|--------|-------|--------|
| 1 | Google Play RTDN topic = "adada" (invalid) | Dashboard | Critical |
| 2 | RC Dashboard chưa "Connect to Google" Pub/Sub | Dashboard | Critical |
| 3 | sync-subscription downgrade user về free khi RC API trả empty | Code | High |
| 4 | _syncToSupabase() fire-and-forget, lỗi im lặng | Code | Medium |

---

## Architecture: Full IAP Flow (sau khi fix)

```
User tap "Subscribe Now"
  → RC SDK → Google Play Billing dialog
  → Purchase confirmed → RC SDK sends receipt to RC server
  → RC server validates với Google Play Publisher API (service account ✅)
  → RC records subscriber → Dashboard hiện active ✅
  → Google Play RTDN → Pub/Sub topic → RC confirms ✅
  → RC webhook (revenuecat-webhook) fires → Supabase:
      - update_subscription_status (is_premium=true, tier=ultra)
      - grant_subscription_credits (500 credits, idempotent)
  → App gọi sync-subscription (immediate fallback):
      - RC V2 API trả về ultra entitlement ✅
      - update_subscription_status (double-confirm)
      - grant_subscription_credits (idempotent — no duplicate)
  → UI refresh: Settings hiện "Ultra plan", credits = 500
```

---

## Design

### Part 1: Dashboard Configuration (Manual — bạn thực hiện)

**A. RC Dashboard → Connect to Google Pub/Sub**
1. RC Dashboard → Apps & Providers → ARTIO (Play Store)
2. Section "Google developer notifications" → dropdown "Select..."
3. RC sẽ show 1 topic đã tạo sẵn (format: `projects/artio-revenuecat-2026/topics/revenuecat-artio-...`)
4. Chọn topic đó → click **"Connect to Google"**
5. **Copy** toàn bộ topic name

**B. Google Play Console → Fix RTDN Topic**
1. Google Play Console → Monetization setup → Google Play Billing
2. Real-time developer notifications → Topic name
3. Xóa "adada" → paste topic name từ bước A
4. Save → click "Send test notification" để verify

**Pub/Sub explained (để reference sau này):**
- Google Cloud Pub/Sub = hệ thống message queue của Google
- RC tạo 1 "topic" (hộp thư) trên Google Cloud project `artio-revenuecat-2026`
- Google Play gửi events (purchase/renewal/cancel/expiration) vào topic đó
- RC subscribe và xử lý các events → cập nhật subscriber database
- Bạn không cần làm gì trên Google Cloud Console — RC tự quản lý

---

### Part 2: Code Fix — sync-subscription Edge Function

**File:** `supabase/functions/sync-subscription/index.ts`

**Vấn đề:**
```typescript
// Hiện tại: RC trả empty → isPremium = false → downgrade!
const isPremium = resolvedTier !== null;  // false khi empty
await supabase.rpc("update_subscription_status", { p_is_premium: false })
```

**Fix:**
```typescript
// Nếu RC không trả entitlement → return early, KHÔNG downgrade
if (!isPremium) {
  return new Response(JSON.stringify({
    synced: false,
    reason: "no_active_entitlements",
    message: "No active entitlements in RevenueCat — skipping Supabase update"
  }), { status: 200, headers: { "Content-Type": "application/json" } });
}
// Chỉ chạy khi có entitlement thực sự
await supabase.rpc("update_subscription_status", { p_is_premium: true, p_tier: resolvedTier, ... })
await supabase.rpc("grant_subscription_credits", { ... })
```

---

### Part 3: Code Fix — subscription_provider.dart

**File:** `lib/features/subscription/presentation/providers/subscription_provider.dart`

**Vấn đề:** `_syncToSupabase()` là fire-and-forget hoàn toàn — không phân biệt được sync thành công hay thất bại.

**Fix:** Parse response body và log rõ ràng:
```dart
Future<void> _syncToSupabase() async {
  try {
    final response = await supabaseClient.functions.invoke('sync-subscription');
    final body = response.data as Map<String, dynamic>?;
    if (body?['synced'] == false) {
      Log.w('[Subscription] RC sync skipped: ${body?['reason']}');
    } else {
      Log.i('[Subscription] RC sync OK: tier=${body?['tier']}');
    }
  } catch (e) {
    Log.e('[Subscription] Sync to Supabase failed: $e');
  }
}
```

---

### Part 4: Verify Supabase Secrets

Cần verify các secrets sau đã được set trong Supabase edge functions:
```
REVENUECAT_SECRET_KEY  → RC V2 API Secret Key (từ RC Dashboard → API Keys)
REVENUECAT_PROJECT_ID  → proj7a945f6d (default trong code, verify đúng không)
REVENUECAT_WEBHOOK_SECRET → secret cho revenuecat-webhook verify
```

---

## Success Criteria

- [ ] RC Dashboard hiện ít nhất 1 active subscriber sau test purchase
- [ ] Supabase `profiles`: `is_premium=true`, `subscription_tier=ultra` sau mua
- [ ] Supabase `credit_transactions`: có entry +500 type=subscription
- [ ] `free_credits` hoặc `purchased_credits` tăng 500 sau mua
- [ ] Restore flow: tap Restore → subscription được khôi phục → credits OK
- [ ] `flutter analyze` → No issues
- [ ] `flutter test --exclude-tags=integration` → All tests pass

---

## Files Changed

| File | Type | Change |
|------|------|--------|
| `supabase/functions/sync-subscription/index.ts` | Code | Return early khi RC empty, không downgrade |
| `lib/features/subscription/presentation/providers/subscription_provider.dart` | Code | Parse sync response, log rõ hơn |
| Dashboard RC | Manual | Connect to Google Pub/Sub |
| Google Play Console | Manual | Fix RTDN topic từ "adada" → real topic |
