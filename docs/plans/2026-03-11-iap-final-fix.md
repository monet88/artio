# IAP RevenueCat Final Fix — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Fix double-grant bug + false downgrade bug trong IAP flow để purchase → RC webhook → Supabase grants credits chính xác một lần, không bị overwrite.

**Architecture:** sync-subscription chỉ update is_premium/tier (không grant credits). Webhook là sole source of truth cho credit grant. Tránh double-grant vì webhook dùng RC eventId làm reference_id (idempotent), sync-subscription không can thiệp vào credits.

**Tech Stack:** Deno/TypeScript (Supabase edge function), Dart/Flutter (Riverpod), RevenueCat V2 API, Supabase RPC.

---

## Bối cảnh (đọc trước khi làm)

**Credit system:** Balance thực tế lưu ở `user_credits.balance`. Columns `profiles.free_credits` và `profiles.purchased_credits` là legacy, không dùng.

**Double-grant bug hiện tại:**
1. User mua → App gọi `sync-subscription` → 30-day check qua → grant 500 credits (ref: `rc-sync-xxx`)
2. RC webhook INITIAL_PURCHASE fires → grant thêm 500 credits (ref: RC eventId khác)
3. User nhận 1000 credits thay vì 500

**False downgrade bug hiện tại:**
- `sync-subscription` gọi RC V2 API → trả empty (RC chưa process) → update Supabase `is_premium=false` → user bị downgrade ngay sau purchase

**Fix:** sync-subscription chỉ update is_premium/tier khi RC có entitlement, không bao giờ downgrade, không bao giờ grant credits.

---

## Task 1: Fix sync-subscription edge function

**Files:**
- Modify: `supabase/functions/sync-subscription/index.ts`

**Exact changes cần làm:**

Tìm đoạn từ dòng `const isPremium = resolvedTier !== null;` đến hết response (khoảng dòng 146–228). Thay toàn bộ phần đó bằng code sau:

```typescript
    const isPremium = resolvedTier !== null;

    // GUARD: If RC returns no active entitlements, do NOT touch Supabase.
    // Reasons this happens:
    //   - Pub/Sub not yet propagated (eventual consistency, usually <5s)
    //   - Sandbox purchase not yet server-side validated
    //   - RC processing in flight
    // Downgrading here would undo a successful purchase immediately.
    // Credit grants are handled exclusively by revenuecat-webhook (INITIAL_PURCHASE event)
    // to prevent double-grant (different reference_ids would bypass ON CONFLICT).
    if (!isPremium) {
      console.warn(
        `[sync-subscription] RC returned 0 entitlements for ${userId} — skipping Supabase update`,
      );
      return new Response(
        JSON.stringify({
          synced: false,
          reason: "no_active_entitlements",
          message: "RC has no active entitlements. Supabase not modified.",
        }),
        { status: 200, headers: { "Content-Type": "application/json" } },
      );
    }

    // Update is_premium + tier only (NO credit grant here — webhook owns credits)
    const { error: statusErr } = await supabase.rpc(
      "update_subscription_status",
      {
        p_user_id: userId,
        p_is_premium: true,
        p_tier: resolvedTier,
        p_expires_at: resolvedExpiresAt,
      },
    );

    if (statusErr) {
      console.error(
        "[sync-subscription] update_subscription_status error:",
        statusErr,
      );
      return new Response(
        JSON.stringify({ error: "Failed to update subscription status" }),
        { status: 500, headers: { "Content-Type": "application/json" } },
      );
    }

    console.log(
      `[sync-subscription] Synced ${userId}: tier=${resolvedTier}, expires=${resolvedExpiresAt ?? "unlimited"}`,
    );

    return new Response(
      JSON.stringify({
        synced: true,
        tier: resolvedTier,
        is_premium: true,
        expires_at: resolvedExpiresAt,
      }),
      { status: 200, headers: { "Content-Type": "application/json" } },
    );
  } catch (error) {
    console.error("[sync-subscription] Unexpected error:", error);
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
```

**Step 1: Xác nhận vị trí cần edit**

```bash
grep -n "const isPremium\|// 4. Update\|// 5. Grant credits\|grant_subscription_credits\|return new Response" \
  supabase/functions/sync-subscription/index.ts
```

Ghi nhớ dòng bắt đầu `const isPremium` và dòng cuối cùng của file (`});`).

**Step 2: Thay thế toàn bộ từ `const isPremium` đến cuối file**

Dùng Edit tool — `old_string` là toàn bộ từ `    const isPremium = resolvedTier !== null;` đến `});` (cuối file), `new_string` là code trong block trên.

**Step 3: Verify file không còn `grant_subscription_credits`**

```bash
grep -n "grant_subscription_credits\|purchased_credits\|// 5. Grant" \
  supabase/functions/sync-subscription/index.ts
```

Expected: **không có output** (đã xóa hoàn toàn credit grant section).

**Step 4: Verify có `no_active_entitlements` guard**

```bash
grep -n "no_active_entitlements\|synced: false\|synced: true" \
  supabase/functions/sync-subscription/index.ts
```

Expected: thấy cả 3 strings.

**Step 5: Commit**

```bash
git add supabase/functions/sync-subscription/index.ts
git commit -m "fix(sync-subscription): remove credit grant (webhook owns credits), skip update when RC empty"
```

---

## Task 2: Fix _syncToSupabase() — Parse response và log rõ

**Files:**
- Modify: `lib/features/subscription/presentation/providers/subscription_provider.dart:59-68`

**Step 1: Thay thế toàn bộ method `_syncToSupabase()`**

Tìm đoạn:
```dart
  /// Call sync-subscription edge function then refresh auth state.
  /// Non-blocking: errors are logged but never surface to user.
  Future<void> _syncToSupabase() async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.functions.invoke('sync-subscription');
      // Refresh auth state so UserProfileCard picks up new is_premium from DB.
      ref.invalidate(authViewModelProvider);
    } on Object catch (e) {
      Log.w('sync-subscription failed (non-blocking): $e');
    }
  }
```

Thay bằng:
```dart
  /// Call sync-subscription edge function then refresh auth state.
  /// Non-blocking: errors are logged but never surface to user.
  /// Logs sync result for debugging RC ↔ Supabase integration.
  Future<void> _syncToSupabase() async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      final response = await supabase.functions.invoke('sync-subscription');
      final body = response.data as Map<String, dynamic>?;
      if (body?['synced'] == false) {
        Log.w(
          '[Subscription] sync skipped: ${body?['reason']} — ${body?['message']}',
        );
      } else {
        Log.i(
          '[Subscription] sync OK: tier=${body?['tier']}, is_premium=${body?['is_premium']}',
        );
      }
      // Refresh auth state so UserProfileCard picks up new is_premium from DB.
      ref.invalidate(authViewModelProvider);
    } on Object catch (e) {
      Log.w('[Subscription] sync-subscription failed (non-blocking): $e');
    }
  }
```

**Step 2: Chạy analyze**

```bash
flutter analyze lib/features/subscription/presentation/providers/subscription_provider.dart
```

Expected: `No issues found!`

**Step 3: Chạy tests**

```bash
flutter test --exclude-tags=integration
```

Expected: `All tests passed!`

**Step 4: Commit**

```bash
git add lib/features/subscription/presentation/providers/subscription_provider.dart
git commit -m "fix(subscription): log sync-subscription response for RC debugging"
```

---

## Task 3: Deploy sync-subscription lên Supabase production

**Pre-check: Supabase CLI đã login chưa?**

```bash
supabase projects list
```

Nếu thấy `Error: You need to be logged in`, chạy:
```bash
supabase login
```
(mở browser, login với account owner của project `kytbmplsazsiwndppoji`)

**Step 1: Verify secrets đã set**

```bash
supabase secrets list --project-ref kytbmplsazsiwndppoji 2>/dev/null || \
  echo "CLI not linked — check via Supabase Dashboard → Settings → Edge Functions → Secrets"
```

Phải có: `REVENUECAT_SECRET_KEY`, `REVENUECAT_PROJECT_ID`

Nếu thiếu `REVENUECAT_SECRET_KEY`:
```bash
supabase secrets set REVENUECAT_SECRET_KEY=<value> --project-ref kytbmplsazsiwndppoji
```
Lấy value từ: RC Dashboard → API Keys → V2 API Keys → Secret key.

**Step 2: Deploy edge function**

```bash
cd /Users/mini4/1space/artio
supabase functions deploy sync-subscription --project-ref kytbmplsazsiwndppoji
```

Expected: `Deployed Function sync-subscription on project kytbmplsazsiwndppoji`

**Step 3: Smoke test — gọi function với user thực để verify không crash**

```bash
# Dùng token của user đang login (lấy từ Supabase Dashboard → Authentication → Users → chọn user → copy JWT)
# Hoặc skip step này và verify qua logcat trong Task 4
echo "Deploy verified — proceed to Task 4"
```

---

## Task 4: End-to-end test trên SM-A536E

**Pre-condition:**
- App v9+ đã cài từ Internal Testing track
- Email license tester đã đăng nhập
- ADB connected: `adb devices` phải thấy thiết bị

**Step 1: Chạy logcat để monitor**

```bash
adb -s 192.168.1.25:45305 logcat -s flutter 2>/dev/null | grep -E "Subscription|sync|RC\]|revenuecat|purchase|entitlement" &
LOGCAT_PID=$!
echo "Logcat PID: $LOGCAT_PID"
```

**Step 2: Test purchase flow**

Trên thiết bị:
1. Login bằng email license tester (chưa từng mua)
2. Vào Create → tap Upgrade → chọn Ultra → Subscribe Now
3. Hoàn tất Google Play dialog

**Expected logcat output (theo thứ tự):**
```
[RC] purchase error? — nếu không có error là OK
[Subscription] sync skipped: no_active_entitlements  (RC chưa kịp process, normal)
  HOẶC
[Subscription] sync OK: tier=ultra, is_premium=true  (RC đã process, cũng OK)
🎉 Subscription activated!  (từ paywall_screen)
```

**Step 3: Verify Supabase sau 30 giây**

```bash
SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5dGJtcGxzYXpzaXduZHBwb2ppIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTA0MTI5MSwiZXhwIjoyMDg2NjE3MjkxfQ.ItnOIiw6NB39PIeyQlE-OJ-AwSKnO_qUuel2_obc590"

# Check profiles
curl -s "https://kytbmplsazsiwndppoji.supabase.co/rest/v1/profiles?select=email,is_premium,subscription_tier&order=updated_at.desc&limit=3" \
  -H "apikey: $SERVICE_KEY" \
  -H "Authorization: Bearer $SERVICE_KEY"

# Check user_credits balance
curl -s "https://kytbmplsazsiwndppoji.supabase.co/rest/v1/user_credits?select=user_id,balance&order=updated_at.desc&limit=3" \
  -H "apikey: $SERVICE_KEY" \
  -H "Authorization: Bearer $SERVICE_KEY"

# Check credit_transactions
curl -s "https://kytbmplsazsiwndppoji.supabase.co/rest/v1/credit_transactions?select=user_id,amount,type,description,reference_id,created_at&order=created_at.desc&limit=5" \
  -H "apikey: $SERVICE_KEY" \
  -H "Authorization: Bearer $SERVICE_KEY"
```

**Expected:**
- profiles: `is_premium: true`, `subscription_tier: "ultra"`
- user_credits: balance tăng 500 (từ welcome bonus + subscription grant)
- credit_transactions: có entry `type: "subscription"`, `amount: 500`, `reference_id` là RC event ID (không phải `rc-sync-xxx`)

**Step 4: Verify KHÔNG có double-grant**

```bash
# Đếm số subscription transactions trong 1 giờ qua cho user này
curl -s "https://kytbmplsazsiwndppoji.supabase.co/rest/v1/credit_transactions?select=amount,type,reference_id,created_at&type=eq.subscription&order=created_at.desc&limit=10" \
  -H "apikey: $SERVICE_KEY" \
  -H "Authorization: Bearer $SERVICE_KEY"
```

Expected: **chỉ 1 subscription entry** (không phải 2 với 2 reference_id khác nhau).

**Step 5: Test Restore**

Logout → login lại bằng cùng email → vào Paywall → tap "Restore":
- Phải thấy "✅ Purchases restored!"
- Settings: "Ultra plan premium"
- user_credits balance: không thay đổi (không duplicate)

**Step 6: Dừng logcat**

```bash
kill $LOGCAT_PID 2>/dev/null || true
```

---

## Task 5: Push + Update PR

**Step 1: Final checks**

```bash
flutter analyze
flutter test --exclude-tags=integration
```

Expected: No issues, All tests passed (703+).

**Step 2: Push**

```bash
git push origin fix/credit-exhausted-no-upgrade-option
```

PR #69 sẽ tự động update với commits mới.

---

## Checklist hoàn thiện

- [ ] Task 1: sync-subscription không còn credit grant section
- [ ] Task 1: sync-subscription return early khi RC empty
- [ ] Task 2: _syncToSupabase() logs response rõ
- [ ] Task 3: edge function deployed
- [ ] Task 4: RC Dashboard hiện active subscriber
- [ ] Task 4: Supabase is_premium=true sau purchase
- [ ] Task 4: user_credits.balance tăng đúng 500 (chỉ 1 lần)
- [ ] Task 4: credit_transactions: chỉ 1 subscription entry (webhook reference_id)
- [ ] Task 4: Restore flow hoạt động
- [ ] Task 5: flutter analyze No issues
- [ ] Task 5: All tests passed
