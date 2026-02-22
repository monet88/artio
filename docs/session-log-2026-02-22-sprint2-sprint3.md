# Session Log — Sprint 2 UX + Sprint 3 Fixes

**Date:** 2026-02-22 (21:30–22:30 +07:00)  
**Developer:** Antigravity AI  
**Tester:** minhthang421992@gmail.com (premium account)  
**Device:** Samsung SM-A536E (Galaxy A53 5G)  
**Branches:** `feat/sprint2-ux-improvements` → `feat/sprint3-fixes`

---

## Mục tiêu phiên làm việc

1. Pre-check và test Sprint 1+2 trên thiết bị thật
2. Fix các bug phát hiện trong quá trình test
3. Tiếp tục Sprint 3 — fix Google Sign-In

---

## Công việc đã thực hiện

### 1. Build & cài APK test (21:32)
- Phát hiện 3 compile errors chặn build:
  - `Ref` type không tìm thấy trong 2 provider files → thêm `flutter_riverpod` import
  - `.timeout()` gọi sai trên `Refreshable` thay vì `Future` → sửa thành `ref.read(provider.future).timeout()`
- Build thành công, cài vào SM-A536E

### 2. Bug: Onboarding loop vô hạn (21:38)
- User báo: bấm "Get Started" nhưng không vào được app
- Logcat xác nhận: `going to /home → redirecting to /onboarding` lặp mãi
- Root cause: `markOnboardingDone()` chỉ lưu vào disk, `AuthViewModel._onboardingDone` in memory vẫn `false`
- Fix: Thêm `completeOnboarding()` vào `AuthViewModel` — cập nhật memory + notify router

### 3. Thay đổi logic onboarding (21:57)
- User yêu cầu: onboarding cho TẤT CẢ user lần đầu, không cần login
- Sửa `AuthViewModel.redirect()`: check `!_onboardingDone` không phụ thuộc `isLoggedIn`
- Rebuild + reinstall

### 4. Guest mode (21:51)
- Bỏ rule `!isLoggedIn → /login` trong `redirect()`
- User mở app → thẳng Home
- Auth gate vẫn còn trong `create_screen.dart` khi bấm Generate

### 5. Test xác nhận Sprint 1+2 (22:02)
- ✅ Onboarding 3 slides hoạt động
- ✅ Settings → Legal (Privacy/ToS/Licenses) OK
- ✅ Settings → Support (Help/Report) OK
- ✅ Generate hoạt động với acc premium

### 6. Fix: Generate button bị nav bar che (22:06)
- Dùng `MediaQuery.of(context).viewPadding.bottom` thay SafeArea
- Tạo branch mới `feat/sprint3-fixes`

### 7. Fix: Google Sign-In stuck loading (22:15)
- User báo login Google loading mãi không vào được
- Phân tích: `AndroidManifest.xml` thiếu intent-filter cho scheme `com.artio.app://`
- OAuth callback từ browser không redirect về được app
- Fix: Thêm deep link intent-filter vào AndroidManifest
- Rebuild + reinstall

### 8. Docs & Logs (22:28)
- Tạo `docs/devlog-2026-02-22-sprint2-sprint3.md`
- Cập nhật `docs/project-changelog.md`
- Cập nhật `docs/session-log-2026-02-22-sprint2-sprint3.md` (file này)
- Push tất cả lên GitHub

---

## Kết quả

| Tính năng | Trạng thái |
|-----------|-----------|
| Onboarding 3 slides | ✅ Hoạt động |
| Guest mode | ✅ OK |
| Settings Legal + Support | ✅ OK |
| Credit History | ✅ Cài xong |
| Paywall redesign | ✅ Cài xong |
| Generate button không bị che | ✅ Fix đã apply |
| Google Sign-In | ✅ Deep link fix đã apply |

---

## Pending / To-test

- [ ] Google Sign-In sau khi có deep link intent-filter
- [ ] Generate button clearance sau khi có MediaQuery fix
- [ ] RevenueCat `UnknownBackendError` (code 7981) — cần kiểm tra API key

---

## Commits trong phiên

```
cd240a5  fix(auth,create): Google OAuth deep link + generate button bottom padding
3c1c256  fix(create): add SafeArea bottom so Generate button clears navigation bar
3e033e2  fix(onboarding): show intro slides for ALL first-time users
26fccb8  feat(auth): guest mode — remove forced login on app open
19ba94e  fix(onboarding): break infinite redirect loop on Get Started
5368c15  fix(build): resolve 3 compile errors blocking APK build
984c8c0  feat(ux): paywall redesign, credit history screen, settings improvements
0591412  feat(onboarding): first-time onboarding flow with 3 slides + routing redirect
```
