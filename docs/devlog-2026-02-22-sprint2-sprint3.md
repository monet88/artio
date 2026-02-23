# DEVLOG — Sprint 2 UX Improvements + Sprint 3 Bug Fixes

**Date:** 2026-02-22 (evening session, ~21:30–22:30 +07:00)  
**Branch Sprint 2:** `feat/sprint2-ux-improvements`  
**Branch Sprint 3:** `feat/sprint3-fixes`  
**Tester device:** Samsung SM-A536E (Galaxy A53 5G)

---

## Sprint 2 — UX Improvements

### Feature 1: Onboarding Flow (3 Slides)

**Files:**
- `lib/features/auth/presentation/screens/onboarding_screen.dart` [NEW]
- `lib/features/auth/domain/providers/onboarding_provider.dart` [NEW]
- `lib/features/auth/presentation/view_models/auth_view_model.dart` [MODIFIED]
- `lib/routing/routes/app_routes.dart` [MODIFIED]

**Summary:**
- 3-slide dark gradient onboarding screen với emoji hero icons, dot indicators, Next/Skip/Get Started buttons
- SharedPreferences-backed `onboarding_done` flag
- Hiện cho TẤT CẢ user lần đầu mở app (guest hoặc logged-in)
- Sau khi bấm Get Started → vào Home, flag set, không hiện lại

**Bug fix during testing:**
- **Redirect loop bug:** `markOnboardingDone()` lưu SharedPreferences nhưng `AuthViewModel._onboardingDone` vẫn `false` trong memory → router redirect về `/onboarding` mãi
- **Fix:** Thêm `completeOnboarding()` method vào `AuthViewModel` — set in-memory flag + save to disk + `_notifyRouter()` ngay lập tức
- **Root cause của lần 1:** `onboarding_done` chỉ check với `isLoggedIn` — guest không thấy onboarding
- **Fix lần 2:** Tách khỏi auth state, show cho mọi user khi `_onboardingDone == false`

---

### Feature 2: Guest Mode (No Forced Login)

**Files:**
- `lib/features/auth/presentation/view_models/auth_view_model.dart`

**Summary:**
- Bỏ rule `!isLoggedIn → redirect /login`
- User mở app → thẳng Home, browse template/gallery tự do
- Auth chỉ yêu cầu tại điểm hành động (Generate, Ads, IAP)
- `showAuthGateSheet()` đã sẵn có trong `create_screen.dart`

---

### Feature 3: Paywall Screen Redesign

**Files:**
- `lib/features/subscription/presentation/screens/paywall_screen.dart` [REWRITE]

**Summary:**
- Dark gradient background, glowing diamond hero icon
- Benefit chips grid
- Animated plan selection cards (Pro / Ultra) với "Popular" badge
- Gradient Subscribe CTA button
- Restore Purchases ở header
- Auto-renew legal fine print

---

### Feature 4: Credit History Screen

**Files:**
- `lib/features/credits/presentation/screens/credit_history_screen.dart` [NEW]
- `lib/features/credits/presentation/providers/credit_history_provider.dart` [NEW]
- `lib/routing/routes/app_routes.dart` — thêm `/credits/history`
- `lib/features/settings/presentation/widgets/settings_sections.dart` — thêm tile

**Summary:**
- Transaction list với type-specific icons (🎉 welcome, 📺 ad, 💎 sub, ✨ gen, ↩ refund)
- Amounts màu xanh (earn) / đỏ (spend)
- Date formatting via `intl`
- Empty state khi chưa có giao dịch
- Accessible từ Settings → Account → Credit History

---

## Compile Errors Fixed (bị phát hiện khi build APK)

| File | Error | Fix |
|------|-------|-----|
| `onboarding_provider.dart` | `Undefined class 'Ref'` | Add `flutter_riverpod` import |
| `credit_history_provider.dart` | `Undefined class 'Ref'` | Add `flutter_riverpod` import |
| `auth_view_model.dart` | `.timeout()` on `Refreshable` not `Future` | Change to `ref.read(provider.future).timeout()` |

---

## Sprint 3 — Bug Fixes

### Fix 1: Generate Button Covered by Android Navigation Bar

**File:** `lib/features/create/presentation/create_screen.dart`

**Symptom:** Nút Generate ở Create screen bị thanh home/navigation bar của Samsung A53 che mất.

**Root cause:** `SingleChildScrollView` không có bottom padding cho system navigation inset.

**Fix:** Thêm `MediaQuery.of(context).viewPadding.bottom` vào bottom padding:
```dart
padding: AppSpacing.screenPadding.copyWith(
  bottom: AppSpacing.screenPadding.bottom +
      MediaQuery.of(context).viewPadding.bottom +
      AppSpacing.lg,
),
```

---

### Fix 2: Google Sign-In Stuck on Loading

**File:** `android/app/src/main/AndroidManifest.xml`

**Symptom:** Bấm "Sign in with Google" → mở browser OAuth → xong nhưng app không nhận được callback → `AuthState` mãi ở `authenticating` (loading spinner không dừng).

**Root cause:** `AndroidManifest.xml` thiếu `intent-filter` cho deep link scheme `com.artio.app://`. Khi Google OAuth hoàn thành, browser muốn redirect về `com.artio.app://login-callback` nhưng Android không có app nào đăng ký xử lý scheme này → callback bị mất.

**Fix:**
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="com.artio.app"/>
</intent-filter>
```

**Note:** Đây là lý do tại sao Google OAuth hoạt động trên iOS (iOS có separate URL scheme config) nhưng không có trên Android — Android cần explicit `intent-filter` trong Manifest.

---

## Commit History (session)

```
cd240a5  fix(auth,create): Google OAuth deep link + generate button bottom padding
3c1c256  fix(create): add SafeArea bottom so Generate button clears navigation bar
3e033e2  fix(onboarding): show intro slides for ALL first-time users  
26fccb8  feat(auth): guest mode — remove forced login on app open
19ba94e  fix(onboarding): break infinite redirect loop on Get Started
5368c15  fix(build): resolve 3 compile errors blocking APK build
984c8c0  feat(ux): paywall redesign, credit history screen, settings improvements
0591412  feat(onboarding): first-time onboarding flow with 3 slides + routing redirect
404be96  feat(compliance): iOS ATT, SKAdNetwork, PrivacyInfo, content moderation, settings legal/support
```

---

## Test Results (SM-A536E, debug build)

| Tính năng | Result |
|-----------|--------|
| Onboarding 3 slides (first launch) | ✅ Pass |
| Get Started → vào Home (không loop) | ✅ Pass |
| Settings → Legal (Privacy/ToS/OSS) | ✅ Pass |
| Settings → Support (Help/Report) | ✅ Pass |
| Settings → Credit History | ✅ Cài xong |
| Guest mode (no login required) | ✅ Pass |
| Generate với account premium | ✅ Pass |
| Google Sign-In | 🔄 Testing (deep link fix applied) |
| Generate button không bị che | 🔄 Testing (MediaQuery fix applied) |

---

## Known Issues / Pending

- RevenueCat logIn returns `UnknownBackendError` (code 7981: Invalid IAM token) — non-blocking, không ảnh hưởng UX nhưng cần kiểm tra RevenueCat API key config
- Google OAuth cần test sau khi install với deep link fix mới
