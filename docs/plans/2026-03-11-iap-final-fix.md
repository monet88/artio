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

**Testing constraint:** Không test qua ADB/WiFi vì IAP yêu cầu app được cài từ Play Store. Quy trình: build AAB → upload Play Console Internal Testing → cài trên thiết bị từ Play Store → test.

---

## Task 1: Fix sync-subscription edge function

**Files:**
- Modify: `supabase/functions/sync-subscription/index.ts`

**Step 1: Verify vị trí cần edit**

```bash
grep -n "const isPremium" supabase/functions/sync-subscription/index.ts
```
Expected: `146:    const isPremium = resolvedTier !== null;`

**Step 2: Thay thế bằng Edit tool**

Dùng Edit tool với **exact** old_string sau (từ dòng 146 đến hết file):

```
    const isPremium = resolvedTier !== null;

    // 4. Update subscription status in profiles
    const { error: statusErr } = await supabase.rpc(
      "update_subscription_status",
      {
        p_user_id: userId,
        p_is_premium: isPremium,
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
        {
          status: 500,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    // 5. Grant credits if active subscription AND not already granted this billing period
    if (isPremium && resolvedCredits > 0) {
      const billingPeriodStart = new Date();
      billingPeriodStart.setDate(billingPeriodStart.getDate() - 30);

      const { data: existing } = await supabase
        .from("credit_transactions")
        .select("id")
        .eq("user_id", userId)
        .eq("type", "subscription")
        .gte("created_at", billingPeriodStart.toISOString())
        .maybeSingle();

      if (!existing) {
        const referenceId = `rc-sync-${userId}-${resolvedExpiresAt ?? "unlimited"}`;
        const { error: creditErr } = await supabase.rpc(
          "grant_subscription_credits",
          {
            p_user_id: userId,
            p_amount: resolvedCredits,
            p_description: `${resolvedTier} subscription — sync`,
            p_reference_id: referenceId,
          },
        );

        if (creditErr) {
          console.error(
            "[sync-subscription] grant_subscription_credits error:",
            creditErr,
          );
          // Non-fatal: subscription status already updated
        }
      }
    }

    console.log(
      `[sync-subscription] Synced user ${userId}: tier=${resolvedTier ?? "free"}, premium=${isPremium}`,
    );

    return new Response(
      JSON.stringify({
        ok: true,
        tier: resolvedTier,
        is_premium: isPremium,
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

new_string (thay thế toàn bộ phần trên):

```
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

    // Update is_premium + tier only (NO credit grant — webhook owns credits)
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

**Step 3: Verify — không còn grant_subscription_credits**

```bash
grep -n "grant_subscription_credits\|// 5. Grant\|billingPeriodStart\|rc-sync-" \
  supabase/functions/sync-subscription/index.ts
```
Expected: **không có output** (đã xóa hoàn toàn credit grant section).

**Step 4: Verify — có guard mới**

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

> Note: `_syncToSupabase()` là fire-and-forget (non-blocking). Không cần test mới — existing tests tại
> `test/features/subscription/presentation/providers/subscription_provider_test.dart`
> đã cover purchase/restore state machine. Thay đổi này chỉ là logging.

**Step 1: Thay thế method `_syncToSupabase()`**

Dùng Edit tool với exact old_string:

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

new_string:

```dart
  /// Call sync-subscription edge function then refresh auth state.
  /// Non-blocking: errors are logged but never surface to user.
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
Expected: `All tests passed!` (703+ tests)

**Step 4: Commit**

```bash
git add lib/features/subscription/presentation/providers/subscription_provider.dart
git commit -m "fix(subscription): log sync-subscription response for RC debugging"
```

---

## Task 3: Deploy sync-subscription lên Supabase production

**Step 1: Verify supabase CLI version và syntax**

```bash
supabase --version
```
Expected: `2.x.x` (nếu < 2.67.1 thì update)

```bash
# Verify deploy command syntax (dry-run bằng --help)
supabase functions deploy --help | head -10
```

**Step 2: Verify supabase CLI đã login**

```bash
supabase projects list 2>&1 | head -5
```

Nếu thấy `not logged in` hoặc `Error`:
```bash
supabase login
# Mở browser, login với account owner của project kytbmplsazsiwndppoji
```

**Step 3: Verify secrets đã set**

```bash
supabase secrets list --project-ref kytbmplsazsiwndppoji
```
Phải có: `REVENUECAT_SECRET_KEY`, `REVENUECAT_PROJECT_ID`

Nếu thiếu `REVENUECAT_SECRET_KEY`:
```bash
supabase secrets set REVENUECAT_SECRET_KEY=<value> --project-ref kytbmplsazsiwndppoji
```
Lấy value từ: RC Dashboard → API Keys → V2 API Keys → Secret key.

**Step 4: Deploy**

```bash
cd /Users/mini4/1space/artio
supabase functions deploy sync-subscription --project-ref kytbmplsazsiwndppoji
```
Expected: `Deployed Function sync-subscription on project kytbmplsazsiwndppoji`

Nếu `--project-ref` không được nhận, thử:
```bash
supabase link --project-ref kytbmplsazsiwndppoji
supabase functions deploy sync-subscription
```

---

## Task 4: Build AAB + Upload + E2E Test

**Lưu ý:** Test IAP phải cài app từ Play Store (Internal Testing track), không thể test qua ADB install trực tiếp vì Google Play Billing bị block với sideloaded APK.

**Step 1: Bump version (BẮT BUỘC — Play Console từ chối build number cũ)**

Hiện tại: `version: 1.0.0+9` trong `pubspec.yaml`.
Sửa thành `1.0.0+10`:

```bash
sed -i '' 's/^version: 1.0.0+9/version: 1.0.0+10/' pubspec.yaml
grep "^version:" pubspec.yaml
```
Expected: `version: 1.0.0+10`

```bash
git add pubspec.yaml
git commit -m "chore: bump version to 1.0.0+10 for IAP fix build"
```

**Step 2: Build release AAB**

```bash
cd /Users/mini4/1space/artio
flutter build appbundle --dart-define=ENV=production --release
```
Expected: `Built build/app/outputs/bundle/release/app-release.aab`

**Step 2: Upload lên Play Console Internal Testing**

1. Vào Play Console → Internal Testing → Create new release
2. Upload `build/app/outputs/bundle/release/app-release.aab`
3. Save và Publish release

**Step 3: Cài trên thiết bị**

Trên SM-A536E (đăng nhập email license tester):
1. Mở Play Store → tìm "Artio" hoặc dùng link Internal Testing
2. Update/Install app mới
3. Verify version đúng trong Settings

**Step 4: Test purchase flow**

Trên thiết bị (email license tester, chưa từng mua):
1. Đăng nhập app
2. Vào Create → tap Upgrade → chọn Ultra → Subscribe Now
3. Hoàn tất Google Play dialog với payment method test
4. Kiểm tra: phải thấy "🎉 Subscription activated!" + "Ultra plan premium" trong Settings

**Step 5: Verify Supabase (sau 30-60 giây)**

```bash
SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt5dGJtcGxzYXpzaXduZHBwb2ppIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc3MTA0MTI5MSwiZXhwIjoyMDg2NjE3MjkxfQ.ItnOIiw6NB39PIeyQlE-OJ-AwSKnO_qUuel2_obc590"

# Profiles: is_premium=true?
curl -s "https://kytbmplsazsiwndppoji.supabase.co/rest/v1/profiles?select=email,is_premium,subscription_tier&order=updated_at.desc&limit=3" \
  -H "apikey: $SERVICE_KEY" -H "Authorization: Bearer $SERVICE_KEY"

# user_credits: balance tăng 500?
curl -s "https://kytbmplsazsiwndppoji.supabase.co/rest/v1/user_credits?select=user_id,balance&order=updated_at.desc&limit=3" \
  -H "apikey: $SERVICE_KEY" -H "Authorization: Bearer $SERVICE_KEY"

# credit_transactions: chỉ 1 subscription entry?
curl -s "https://kytbmplsazsiwndppoji.supabase.co/rest/v1/credit_transactions?select=user_id,amount,type,reference_id,created_at&order=created_at.desc&limit=5" \
  -H "apikey: $SERVICE_KEY" -H "Authorization: Bearer $SERVICE_KEY"
```

**Expected:**
- `is_premium: true`, `subscription_tier: "ultra"` ✅
- `user_credits.balance` tăng đúng 500 ✅
- **Chỉ 1** credit_transaction type=subscription (reference_id là RC event ID, không phải `rc-sync-xxx`) ✅

**Step 6: Verify RC Dashboard**

RC Dashboard → Customers → tìm email vừa test:
- Phải có active entitlement "ultra"
- Overview → Active Subscribers: tăng

**Step 7: Test Restore**

Logout → login lại cùng email → vào Paywall → tap "Restore":
- Phải thấy "✅ Purchases restored!"
- Settings: "Ultra plan premium" vẫn còn
- `user_credits.balance` không thay đổi (không duplicate)

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
- [ ] Task 1: sync-subscription return early khi RC empty (no downgrade)
- [ ] Task 1: response trả `{synced: true/false}` thay vì `{ok: true}`
- [ ] Task 2: `_syncToSupabase()` parse + log response
- [ ] Task 3: edge function deployed thành công
- [ ] Task 4: Build AAB v10+ uploaded lên Internal Testing
- [ ] Task 4: RC Dashboard hiện active subscriber
- [ ] Task 4: Supabase `is_premium=true`, `subscription_tier="ultra"`
- [ ] Task 4: `user_credits.balance` += 500 (1 lần, từ webhook)
- [ ] Task 4: credit_transactions có đúng 1 subscription entry với RC eventId
- [ ] Task 4: Restore flow hoạt động, balance không đổi
- [ ] Task 5: `flutter analyze` No issues
- [ ] Task 5: `flutter test` All 703+ passed
