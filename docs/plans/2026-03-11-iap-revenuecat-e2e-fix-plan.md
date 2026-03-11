# IAP RevenueCat End-to-End Fix — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix toàn bộ IAP flow để purchase → RC records subscriber → Supabase updates is_premium + grants credits hoạt động đúng end-to-end.

**Architecture:** sync-subscription edge function hiện downgrade user về free khi RC API trả empty (bug). Fix: return early khi empty, không chạm Supabase. Sau khi Pub/Sub được cấu hình đúng (manual step), RC webhook sẽ là source of truth cho credit grant. sync-subscription là fallback post-purchase confirmation.

**Tech Stack:** Deno/TypeScript (edge function), Dart/Flutter (subscription_provider), RevenueCat SDK + V2 API, Supabase RPC.

---

## Pre-requisite: Dashboard Manual Steps (BẠN LÀM TRƯỚC KHI CODE)

Làm các bước này trước khi chạy Task 1-3:

**Bước 1 — RC Dashboard → Connect to Google Pub/Sub:**
1. Vào RC Dashboard → Apps & providers → ARTIO (Play Store)
2. Section "Google developer notifications" → dropdown "Select..."
3. Chọn topic RC đã tạo sẵn (format: `projects/artio-revenuecat-2026/topics/...`)
4. Click **"Connect to Google"**
5. **Copy** toàn bộ topic name (dùng ở bước 2)

**Bước 2 — Google Play Console → Fix RTDN topic:**
1. Google Play Console → Monetization setup → Google Play Billing
2. Topic name: xóa `"adada"` → paste topic từ bước 1
3. Click **"Send test notification"** → phải thấy "Test notification sent successfully"
4. Save

**Bước 3 — Verify Supabase Secrets:**
Chạy lệnh này để check secrets đã set chưa:
```bash
# Check secrets (cần supabase CLI đăng nhập)
supabase secrets list --project-ref kytbmplsazsiwndppoji
```
Phải có: `REVENUECAT_SECRET_KEY`, `REVENUECAT_PROJECT_ID`, `REVENUECAT_WEBHOOK_SECRET`

Nếu thiếu, set:
```bash
supabase secrets set REVENUECAT_SECRET_KEY=<rc_v2_secret_key> --project-ref kytbmplsazsiwndppoji
supabase secrets set REVENUECAT_PROJECT_ID=proj7a945f6d --project-ref kytbmplsazsiwndppoji
```

RC V2 Secret Key lấy từ: RC Dashboard → API Keys → V2 API Keys.

---

## Task 1: Fix sync-subscription — Không downgrade khi RC trả empty

**Files:**
- Modify: `supabase/functions/sync-subscription/index.ts:144-160`

**Context:** Hiện tại sau khi loop `tierPriority` không tìm thấy entitlement, `isPremium = false` rồi code vẫn gọi `update_subscription_status` với `p_is_premium: false`. Đây là bug: user vừa mua xong mà bị downgrade về free vì RC API chưa kịp process.

**Step 1: Tìm đúng vị trí cần sửa**

```bash
grep -n "const isPremium" supabase/functions/sync-subscription/index.ts
```
Expected output: `146:    const isPremium = resolvedTier !== null;`

**Step 2: Sửa logic — return early khi không có entitlement**

Thay đoạn từ dòng `const isPremium = resolvedTier !== null;` đến trước `// 4. Update subscription status`:

```typescript
    const isPremium = resolvedTier !== null;

    // If RC returns no active entitlements, do NOT downgrade the user.
    // This happens when:
    // - Google Play RTDN Pub/Sub not yet configured (RC hasn't received purchase event)
    // - RC is processing the purchase (eventual consistency)
    // - Sandbox/test purchase not yet propagated to RC server
    // Downgrading here would immediately undo a successful purchase on the client.
    if (!isPremium) {
      console.warn(
        `[sync-subscription] No active entitlements for user ${userId} — skipping Supabase update to avoid false downgrade`,
      );
      return new Response(
        JSON.stringify({
          synced: false,
          reason: "no_active_entitlements",
          message:
            "No active entitlements found in RevenueCat. Supabase not updated.",
        }),
        { status: 200, headers: { "Content-Type": "application/json" } },
      );
    }

    // 4. Update subscription status in profiles (only when we have confirmed entitlement)
```

**Step 3: Verify file looks correct after edit**

```bash
grep -n -A5 "no_active_entitlements" supabase/functions/sync-subscription/index.ts
```
Expected: thấy `synced: false` và `reason: "no_active_entitlements"`.

**Step 4: Deploy edge function**

```bash
cd /Users/mini4/1space/artio
supabase functions deploy sync-subscription --project-ref kytbmplsazsiwndppoji
```
Expected output: `Deployed Function sync-subscription on project kytbmplsazsiwndppoji`

**Step 5: Commit**

```bash
git add supabase/functions/sync-subscription/index.ts
git commit -m "fix(sync-subscription): return early when RC has no entitlements, prevent false downgrade"
```

---

## Task 2: Fix _syncToSupabase() — Parse response và log rõ

**Files:**
- Modify: `lib/features/subscription/presentation/providers/subscription_provider.dart:59-68`
- Test: `test/features/subscription/presentation/providers/subscription_provider_test.dart` (tạo mới nếu chưa có)

**Context:** Hiện tại `_syncToSupabase()` gọi edge function nhưng bỏ qua response hoàn toàn. Không biết được sync có thành công không. Sau Task 1, edge function có thể trả `synced: false` (RC empty) — cần log rõ để debug.

**Step 1: Sửa _syncToSupabase() trong subscription_provider.dart**

Tìm `_syncToSupabase()` ở dòng 59-68. Thay toàn bộ method:

```dart
  /// Call sync-subscription edge function then refresh auth state.
  /// Non-blocking: errors are logged but never surface to user.
  /// Logs sync result clearly for debugging RC integration issues.
  Future<void> _syncToSupabase() async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      final response = await supabase.functions.invoke('sync-subscription');
      final body = response.data as Map<String, dynamic>?;
      if (body?['synced'] == false) {
        Log.w(
          '[Subscription] sync-subscription skipped: ${body?['reason']} — ${body?['message']}',
        );
      } else {
        Log.i(
          '[Subscription] sync-subscription OK: tier=${body?['tier']}, is_premium=${body?['is_premium']}',
        );
      }
      // Refresh auth state so UserProfileCard picks up new is_premium from DB.
      ref.invalidate(authViewModelProvider);
    } on Object catch (e) {
      Log.w('[Subscription] sync-subscription failed (non-blocking): $e');
    }
  }
```

**Step 2: Chạy analyze để verify không có lỗi**

```bash
flutter analyze lib/features/subscription/presentation/providers/subscription_provider.dart
```
Expected: `No issues found!`

**Step 3: Chạy toàn bộ tests**

```bash
flutter test --exclude-tags=integration
```
Expected: `All tests passed!` (703+ tests)

**Step 4: Commit**

```bash
git add lib/features/subscription/presentation/providers/subscription_provider.dart
git commit -m "fix(subscription): log sync-subscription response clearly for debugging"
```

---

## Task 3: Verify full flow sau fix

**Không có code change — chỉ verify.**

**Step 1: Build và deploy lên Internal App Sharing**

```bash
# Build release AAB
flutter build appbundle --dart-define=ENV=production --release

# Upload lên Play Console → Internal App Sharing
# https://play.google.com/console/about/internalappsharing/
```

**Step 2: Test purchase flow với email mới**

Dùng 1 Gmail mới (chưa từng mua) vào app:
1. Tap "Upgrade" → chọn Ultra → tap "Subscribe Now"
2. Hoàn tất Google Play billing dialog
3. Kiểm tra app: phải thấy "🎉 Subscription activated!" và "Ultra plan premium" trong Settings

**Step 3: Verify RC Dashboard**

Sau khi mua, vào RC Dashboard → Customers:
- Phải thấy customer mới với active "ultra" entitlement
- RC Dashboard → Overview → Active Subscribers phải tăng lên 1+

**Step 4: Verify Supabase**

```bash
# Query profiles qua curl
SERVICE_KEY="<SUPABASE_SERVICE_ROLE_KEY>"
curl "https://kytbmplsazsiwndppoji.supabase.co/rest/v1/profiles?select=email,is_premium,subscription_tier,free_credits,purchased_credits&order=updated_at.desc&limit=3" \
  -H "apikey: $SERVICE_KEY" \
  -H "Authorization: Bearer $SERVICE_KEY"
```
Expected: user mới có `is_premium: true`, `subscription_tier: "ultra"`.

**Step 5: Verify credits được grant**

```bash
curl "https://kytbmplsazsiwndppoji.supabase.co/rest/v1/credit_transactions?select=*&order=created_at.desc&limit=5" \
  -H "apikey: $SERVICE_KEY" \
  -H "Authorization: Bearer $SERVICE_KEY"
```
Expected: có entry `type: "subscription"`, `amount: 500` cho user vừa mua.

**Step 6: Test Restore flow**

Logout → login lại → tap "Restore" trong Paywall:
- Phải thấy "✅ Purchases restored!"
- Settings phải hiển thị "Ultra plan premium"
- Credits phải vẫn còn (không duplicate)

**Step 7: Final analyze + test**

```bash
flutter analyze
flutter test --exclude-tags=integration
```
Expected cả hai: No issues, All tests passed.

**Step 8: Push và update PR**

```bash
git push origin fix/credit-exhausted-no-upgrade-option
```

---

## Checklist hoàn thiện

- [ ] Dashboard: RC "Connect to Google" Pub/Sub đã click
- [ ] Dashboard: Google Play RTDN topic đã update (không còn "adada")
- [ ] Supabase secrets: REVENUECAT_SECRET_KEY đã set
- [ ] Code: sync-subscription return early khi RC empty (không downgrade)
- [ ] Code: _syncToSupabase() log response rõ
- [ ] Deploy: sync-subscription đã deploy lên production
- [ ] Test: RC Dashboard hiện active subscriber sau purchase
- [ ] Test: Supabase is_premium=true sau purchase
- [ ] Test: 500 credits được grant
- [ ] Test: Restore flow hoạt động
- [ ] flutter analyze: No issues
- [ ] flutter test: All 703+ passed
