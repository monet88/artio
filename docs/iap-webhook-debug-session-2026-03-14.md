# IAP / RevenueCat Webhook Debug Session — 2026-03-14

> **Mục tiêu:** Debug tại sao mua gói Pro/Ultra mà credits không được cộng vào app.
> **Kết quả:** Tìm và fix 3 root cause bugs. Build AAB v14 sẵn sàng upload.

---

## 1. Bối cảnh

- **Tài khoản test:** `<test-email>` (Supabase UUID: `<user-uuid>`)
- **Thiết bị:** Samsung A53, IP `<device-ip>`, cài app qua Google Play **Internal Testing**
- **Hiện tượng:** Mua Pro + Ultra, RC dashboard hiển thị webhook "Failure/Retrying", balance vẫn giữ nguyên 20 credits (chỉ có welcome bonus)
- **RC app_user_id** = Supabase UUID (correct — dùng `Purchases.logIn(userId)`)

---

## 2. Điều tra ban đầu

### 2.1 Xác nhận kết nối thiết bị và logcat
- App release build → Dart/Flutter logs không ra logcat, chỉ thấy native logs
- RC event payloads từ dashboard: tất cả có `app_user_id = <uuid>`, môi trường SANDBOX, `renewal_number` 1 và 2

### 2.2 Trạng thái DB ban đầu
```sql
-- profiles: subscription_tier=free, is_premium=false, revenuecat_app_user_id=NULL
-- user_credits: balance=20
-- credit_transactions: chỉ có welcome_bonus
```

### 2.3 Chuỗi sự kiện xác định
1. RC webhook events gửi tới `revenuecat-webhook` edge function → trả về **500** → RC đánh dấu Failure/Retrying
2. `revenuecat_app_user_id` trong DB là **NULL** → webhook không tìm được user profile
3. Tại sao NULL? Vì `signUpWithEmail` gọi `_revenuecatLogIn` trước khi tạo profile

---

## 3. Root Cause Bugs (3 bugs)

---

### Bug #1 — `crypto.subtle.timingSafeEqual` không tồn tại trong Supabase Edge Runtime

**File:** `supabase/functions/revenuecat-webhook/index.ts`

**Triệu chứng:** RC dashboard toàn bộ events đều "Failure", webhook trả về 500 Internal Server Error.

**Nguyên nhân:**
```typescript
// Code cũ — crash với "TypeError: crypto.subtle.timingSafeEqual is not a function"
const isValid = await crypto.subtle.timingSafeEqual(
  encoder.encode(authHeader),
  encoder.encode(expectedAuth)
);
```
`crypto.subtle.timingSafeEqual` là Web Crypto API nhưng **không được implement** trong Supabase Deno Edge Runtime. Mọi request đều throw exception → catch block trả về 500 → RC retry mãi.

**Fix (commit `9c551ec8`):**
```typescript
// Manual constant-time XOR comparison
const a = encoder.encode(authHeader ?? "");
const b = encoder.encode(expectedAuth);
let diff = a.length ^ b.length;
const len = Math.min(a.length, b.length);
for (let i = 0; i < len; i++) diff |= a[i] ^ b[i];
const authValid = authHeader !== null && diff === 0;
```

**Triển khai:** Deploy v17 → v19 lên Supabase. Xác nhận bằng manual curl test → `{"ok":true}` HTTP 200.

---

### Bug #2 — signUp race condition: `revenuecat_app_user_id` = NULL cho user mới

**File:** `lib/features/auth/data/repositories/auth_repository.dart`

**Triệu chứng:** User mới đăng ký → mua subscription → RC webhook fires → webhook lookup `profiles WHERE revenuecat_app_user_id = app_user_id` → **không tìm được** → trả 500 "User not linked" → RC retry.

**Nguyên nhân:**
```dart
// signUpWithEmail — THỨ TỰ SAI:
await _revenuecatLogIn(response.user!.id);  // UPDATE profiles SET rc_id = x WHERE id = x
                                             // → 0 rows affected! Profile chưa tồn tại!
await _createUserProfile(response.user!.id, email);  // INSERT profiles (không có rc_id)
```

`_revenuecatLogIn` làm UPDATE trên bảng `profiles`, nhưng profile chưa được INSERT. UPDATE match 0 rows, không có error → silent fail → `revenuecat_app_user_id` không bao giờ được set.

Tương tự bug trong `fetchOrCreateProfile` (dùng cho Google/Apple OAuth).

**Fix (commit `1bd73435`):**
```dart
// signUpWithEmail — đúng thứ tự:
await _createUserProfile(response.user!.id, email);  // INSERT trước
await _revenuecatLogIn(response.user!.id);            // UPDATE sau (profile đã tồn tại)

// fetchOrCreateProfile — đúng thứ tự:
var profile = await _fetchUserProfile(user.id);
if (profile == null) {
  await _createUserProfile(user.id, user.email ?? '');  // INSERT trước
}
await _revenuecatLogIn(user.id);  // UPDATE sau

// _createUserProfile — belt-and-suspenders: include field ngay trong INSERT
await _supabase.from('profiles').insert({
  ...
  'revenuecat_app_user_id': userId,  // ← thêm mới
});
```

---

### Bug #3 — UI credits không refresh sau khi mua subscription

**File:** `lib/features/subscription/presentation/providers/subscription_provider.dart`

**Triệu chứng:** User mua gói xong → app vẫn hiện số credits cũ (e.g., 20 thay vì 220).

**Nguyên nhân:**
```dart
Future<void> _syncToSupabase() async {
  await supabase.functions.invoke('sync-subscription');
  ref.invalidate(authViewModelProvider);  // ← chỉ refresh auth/tier
  // creditBalanceNotifierProvider không được invalidate!
}
```

Mặc dù `CreditBalanceNotifier` dùng `watchBalance()` là Supabase Realtime stream (tự cập nhật khi DB thay đổi), khi Realtime push có delay hoặc chưa hoạt động, UI sẽ không cập nhật ngay lập tức.

**Fix (commit `23073528`):**
```dart
// purchase() — invalidate ngay sau khi purchase thành công
Future<void> purchase(SubscriptionPackage package) async {
  state = const AsyncLoading();
  state = await AsyncValue.guard(() async {
    final result = await repo.purchase(package);
    unawaited(_syncToSupabase());
    return result;
  });
  if (state.hasValue) {
    ref.invalidate(creditBalanceNotifierProvider);  // ← thêm mới
  }
}

// _syncToSupabase() — cascade invalidate cả 2
ref
  ..invalidate(authViewModelProvider)
  ..invalidate(creditBalanceNotifierProvider);  // ← thêm mới
```

---

## 4. Luồng hoạt động đúng (sau khi fix)

```
User mua gói
  │
  ├── Purchases.purchase() (RC SDK) ──────────────────────────────────┐
  │     └── rawToken = GPA.xxx (orderId)                              │
  │                                                                   │
  ├── [non-blocking] _verifyWithGooglePlay(rawToken, productId)       │
  │     └── verify-google-purchase edge fn                            │
  │           ├── Validate GPA format                                 │
  │           ├── 25-day guard check                                  │
  │           └── grant_subscription_credits RPC → balance +credits   │
  │                                                                   │
  ├── [non-blocking] _syncToSupabase()                                │
  │     ├── sync-subscription edge fn → update_subscription_status    │
  │     └── ref.invalidate(authViewModelProvider)                     │
  │         ref.invalidate(creditBalanceNotifierProvider) ← fix #3    │
  │                                                                   │
  └── state.hasValue → ref.invalidate(creditBalanceNotifierProvider)  │
                                                                      │
  [Async, vài phút sau — SANDBOX] RC webhook                         │
    └── revenuecat-webhook edge fn                                    │
          ├── Auth: manual XOR comparison ← fix #1                   │
          ├── Lookup: profiles.revenuecat_app_user_id ← fix #2       │
          ├── update_subscription_status                              │
          └── grant_subscription_credits (25-day guard)              │
                                                                      │
  Supabase Realtime stream → watchBalance() → UI auto-update ─────────┘
```

---

## 5. Kiểm chứng

### Test thủ công user-A (webhook)
```bash
curl -X POST https://<project-ref>.supabase.co/functions/v1/revenuecat-webhook \
  -H "Authorization: Bearer <REVENUECAT_WEBHOOK_SECRET>" \
  -d '{"event":{"type":"INITIAL_PURCHASE","id":"test-debug-003","app_user_id":"<user-uuid>","product_id":"artio_ultra_monthly:..."}}'
# → {"ok":true} HTTP 200
# → balance: 20 → 520 ✅
```

### Test thủ công user-B (webhook)
```bash
# → {"ok":true} HTTP 200
# → balance: 20 → 220 ✅, subscription_tier=pro, is_premium=true ✅
```

### DB state sau fix (user-A — Ultra)
```
subscription_tier: ultra
is_premium: true
revenuecat_app_user_id: <user-uuid> ✅
balance: 520 (20 welcome + 500 ultra)
```

### DB state sau fix (user-B — Pro)
```
subscription_tier: pro
is_premium: true
revenuecat_app_user_id: <user-uuid> ✅
balance: 220 (20 welcome + 200 pro)
```

---

## 6. Ghi chú về "SANDBOX DATA"

RC hiển thị "SANDBOX DATA" cho tất cả purchases từ Internal Testing track — đây là **hành vi đúng**, không phải bug.

| Track | Billing Mode |
|-------|-------------|
| Internal Testing | Luôn là SANDBOX |
| Closed/Open Testing | Sandbox (với license testers) |
| Production | Real billing |

- "No active customers" trong RC customer list = bình thường — list này chỉ hiển thị production customers
- SANDBOX purchases auto-renew mỗi ~5 phút trong Google Play sandbox

---

## 7. Commits trong session này

| Commit | Mô tả |
|--------|-------|
| `9c551ec8` | fix(webhook): replace crypto.subtle.timingSafeEqual with manual constant-time comparison |
| `1bd73435` | fix(iap): fix signUp race condition causing revenuecat_app_user_id to be null for new users |
| `23073528` | fix(subscription): invalidate credit balance after purchase so UI reflects granted credits |
| `73a3da98` | chore: bump version code to 14 for Play Store release |

---

## 8. Build

```
flutter build appbundle --dart-define=ENV=production --release
→ build/app/outputs/bundle/release/app-release.aab (54.1MB)
Version: 1.0.0+14
```

---

## 9. Bugs còn tiềm ẩn (chưa xác nhận)

| # | Bug tiềm ẩn | Mô tả | Trạng thái |
|---|------------|-------|-----------|
| 1 | RC webhook retry cho halo | Events từ trước khi fix (3:04 PM) đã "Failure" vĩnh viễn. Events sau fix (3:28 PM "Retrying") sẽ tự retry. Credits đã được manually granted | ⚠️ Cần verify retry thành công |
| 2 | verify-google-purchase với empty rawToken | Nếu orderId empty (free trial), `_verifyWithGooglePlay` bị skip. Credits sẽ phải chờ RC webhook. SKILL.md có timestamp fallback pattern nhưng code hiện tại đã bỏ fallback đó vì security concern. | ⚠️ Cần xác nhận behaviour |
| 3 | E2E test với v14 build | Chưa install và test thực tế v14 | ⚠️ Pending upload + test |
| 4 | Realtime stream trên `user_credits` | Chưa verify Realtime được enable trên table này trong Supabase | ⚠️ Cần verify |

---

## 10. Việc cần làm tiếp theo

1. [ ] Upload AAB v14 lên Google Play Internal Testing
2. [ ] Install và test: đăng ký account mới → mua gói → verify credits cập nhật ngay
3. [ ] Kiểm tra RC dashboard cho adstudio@gmail.com events (sau khi RC gửi)
4. [ ] Verify `user_credits` table có Realtime enabled trong Supabase Dashboard
5. [ ] Sau khi E2E confirmed: cân nhắc update `iap-revenuecat` SKILL.md với 3 bugs mới tìm
6. [ ] Merge PR #70 vào main sau khi test pass
