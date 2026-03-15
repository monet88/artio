# Session Summary — v16 Internal Testing & v17 Release
**Date:** 2026-03-16
**Branch flow:** `release/v16-internal-testing` → merged to `main` → v17 bump

---

## Mục tiêu

1. Debug RC webhook events "Retrying" → fix để events trở thành "Sent"
2. Merge v16 fixes vào `main` + dọn stale PRs/issues
3. Bump version → build AAB v17
4. Xử lý cubic code review comments (P1/P2)
5. Cập nhật documentation + IAP skill

---

## Những vấn đề đã phát hiện & fix

### Bug 1 — RC Webhook Secret Mismatch (P1, đã fix)

**Symptom:** Tất cả RC webhook events trả về 401 "Failure".

**Root cause:** `REVENUECAT_WEBHOOK_SECRET` trong Supabase có giá trị khác với token trong RC Dashboard. Set ở hai thời điểm khác nhau.

**Fix:**
```bash
supabase secrets set REVENUECAT_WEBHOOK_SECRET=67b6cd6c... --project-ref kytbmplsazsiwndppoji
```

---

### Bug 2 — `event.id` Null → `p_reference_id` NULL → DB Exception → 500 (P1, đã fix)

**Symptom:** RC sandbox RENEWAL events trả về 500 "Retrying".

**Root cause:** RC sandbox đôi khi bỏ qua field `event.id`. Webhook code dùng `event.id` làm `p_reference_id`. DB RPC `grant_subscription_credits` có guard `IF p_reference_id IS NULL THEN RAISE EXCEPTION`.

**Fix** (`supabase/functions/revenuecat-webhook/index.ts`):
```typescript
const eventId: string =
  event.id ??
  event.transaction_id ??
  `${appUserId}-${eventType}-${event.event_timestamp_ms ?? Date.now()}`;
```

**Commit:** `e8c7bcd5`

---

### Bug 3 — RC Auth Header Bearer Prefix Sai (P1, đã fix)

**Symptom:** RC webhook vẫn 401 sau khi fix secret mismatch.

**Root cause:** RC gửi Authorization header EXACTLY như nhập trong dashboard — **không tự thêm `Bearer ` prefix**. Webhook code cũ dùng `` `Bearer ${REVENUECAT_WEBHOOK_SECRET}` `` → length mismatch → XOR diff ≠ 0 → 401 vĩnh viễn.

**Verification:**
```bash
# Raw token (RC format) → 500 user-not-linked = AUTH PASSED ✅
curl -H "Authorization: 67b6cd6c..." <webhook-url>

# Bearer prefix → 401 ✅ (xác nhận RC không gửi Bearer)
curl -H "Authorization: Bearer 67b6cd6c..." <webhook-url>
```

**Fix** (`supabase/functions/revenuecat-webhook/index.ts`):
```typescript
// TRƯỚC: const expectedAuth = `Bearer ${REVENUECAT_WEBHOOK_SECRET}`;
const expectedAuth = REVENUECAT_WEBHOOK_SECRET; // raw token, no prefix
```

**Commits:** `29a6718c` → `fe8d6127` (PR #77)

**Kết quả sau fix:** 4 RC events → "Sent" ✅, user credits: 820 ✅

---

### Bug 4 — Restore Purchases UX: Luôn Show Success (P2, đã fix)

**Root cause:** `SubscriptionNotifier.restore()` dùng `AsyncValue.guard()` — lỗi lưu vào `state`, không throw. `try/catch` trong `_restorePurchases()` không bắt được lỗi → luôn show "✅ Purchases restored!".

**Fix** (`lib/features/settings/presentation/settings_screen.dart`):
```dart
await ref.read(subscriptionNotifierProvider.notifier).restore();
if (!context.mounted) return;
final hasError = ref.read(subscriptionNotifierProvider).hasError;
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(hasError ? 'Restore failed. Please try again.' : '✅ Purchases restored!')),
);
```

---

### Bug 5 — Restore Purchases Enabled trên Desktop (P2, đã fix)

**Root cause:** Guard chỉ check `kIsWeb`, bỏ qua macOS/Windows/Linux nơi RevenueCat không hỗ trợ.

**Fix** (`lib/features/settings/presentation/widgets/settings_sections.dart`):
```dart
// TRƯỚC: onTap: kIsWeb ? null : onRestore,
onTap: (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) ? null : onRestore,
```

---

### Bug 6 — SKILL.md + CLAUDE.md Docs Sai (P2, đã fix)

- SKILL.md:68 ghi `Authorization: Bearer YOUR_SECRET` → sai → gây 401 cho bất kỳ dev nào follow docs
- CLAUDE.md:167 ghi "200 = correct token" → sai → correct token + unlinked user → 500

**Fix:** Cập nhật cả hai file, thêm Gotcha #18 về `event.id` null.

---

## Pull Requests Trong Session

| PR | Title | Status |
|---|---|---|
| #74 | feat: Restore Purchases tile | CLOSED (commits on main) |
| #75 | fix: UX polish AdMob/retry/watermark | CLOSED (commits on main) |
| #76 | fix: merge v16 webhook fixes → main | MERGED ✅ |
| #77 | fix: RC auth without Bearer prefix | MERGED ✅ |
| #78 | chore: bump version to 1.0.0+17 | MERGED ✅ |
| #79 | fix: cubic P1/P2 review issues | MERGED ✅ |

---

## Issues

| Issue | Status |
|---|---|
| #65 — No upgrade option when credits run out | CLOSED (fixed in PR #69) |
| #68 — Apple RC key is test placeholder | OPEN (defer — v18 iOS IAP) |

---

## Kết quả

### Production (Supabase Edge Function)
- `revenuecat-webhook` deployed với auth fix + eventId fallback
- `REVENUECAT_WEBHOOK_SECRET` = raw token (khớp RC dashboard)
- 4 RC events "Sent" trong RC Dashboard ✅
- User `test-user@example.com`: 820 credits ✅

### Repository (main branch)
- `version: 1.0.0+17` trong `pubspec.yaml`
- `flutter analyze` → No issues found ✅
- 38 settings tests pass ✅
- AAB built: `build/app/outputs/bundle/release/app-release.aab` (49MB)

### Documentation
- `CLAUDE.md` — RC auth gotcha corrected
- `.agent/skills/iap-revenuecat/SKILL.md` — Gotcha #6 fixed, Gotcha #18 added, pre-check updated

---

## PR Comments (cubic automated review)

| PR | Cubic result |
|---|---|
| #77 | No issues found ✅ |
| #78 | No issues found ✅ |
| #79 | Pending (mới merged, chưa review) |

---

## Vấn đề còn tồn đọng

| Hạng mục | Priority | Ghi chú |
|---|---|---|
| iOS IAP (StoreKit 2) | P0 | Issue #68. Cần sprint riêng (v18). RC key Apple hiện là placeholder |
| AdMob production IDs | P1 | Đang dùng test IDs. Cần real IDs trước khi public launch |
| Upload v17 AAB lên Play Store | P1 | AAB đã build xong, cần user upload thủ công |
| cubic review PR #79 | P2 | Chờ cubic run xong, có thể có thêm issues |

---

## Lesson Learned — RC Webhook Auth

> RC gửi Authorization header EXACTLY như bạn nhập trong dashboard. Không có prefix tự động.
> Store raw token trong `REVENUECAT_WEBHOOK_SECRET`. So sánh trực tiếp, không thêm `Bearer `.
> Để verify: `curl -H "Authorization: <raw-token>" <endpoint>` → 500 "User not linked" = auth OK.
