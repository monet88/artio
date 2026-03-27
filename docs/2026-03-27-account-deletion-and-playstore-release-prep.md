# Session Summary: Account Deletion Feature & Play Store Release Prep

**Date:** 2026-03-27
**Branch:** `feat/account-deletion` → merged to `main` via PR #85
**Related PRs:** #85 (account deletion), #86 (legal URL fix)

---

## Mục tiêu

1. Implement tính năng **Delete Account** (yêu cầu bắt buộc của Google Play & App Store)
2. Chuẩn bị **Play Store release**: fix code blockers, tạo assets (logo, feature graphic), viết store listing

---

## Phần 1 — Delete Account Feature

### Mục tiêu
Cho phép user xóa tài khoản và toàn bộ dữ liệu (images, storage, auth record) ngay trong app, đúng yêu cầu Play Store / App Store policy.

### Kiến trúc

```
Settings UI
  └─ onDeleteAccount() callback
       └─ AuthViewModel.deleteAccount()
            └─ IAuthRepository.deleteAccount()
                 └─ AuthRepository.deleteAccount()
                      ├─ supabase.functions.invoke('delete-account')   ← Edge Function
                      ├─ supabase.auth.signOut()                       ← clear local session
                      └─ RevenueCat.logOut()                           ← clear RC identity
```

**Edge Function `delete-account`** (Deno/TypeScript):
1. Validate JWT via `auth.getUser(token)`
2. Xóa Storage: `{userId}/` (generated images) + `{userId}/inputs/` (input images) — paginated loop, page size 1000
3. Xóa auth user via `auth.admin.deleteUser(userId)` → cascades toàn bộ DB tables qua FK

### Files thay đổi

| File | Thay đổi |
|------|----------|
| `supabase/functions/delete-account/index.ts` | Edge function mới: JWT auth, storage cleanup, user deletion |
| `supabase/config.toml` | Thêm `[functions.delete-account]` với `verify_jwt = false` |
| `lib/features/auth/domain/repositories/i_auth_repository.dart` | Thêm `deleteAccount()` vào interface |
| `lib/features/auth/data/repositories/auth_repository.dart` | Implement `deleteAccount()` |
| `lib/features/auth/presentation/view_models/auth_view_model.dart` | Thêm `deleteAccount()`, invalidate providers, set unauthenticated state |
| `lib/features/settings/presentation/settings_screen.dart` | Confirmation dialog + loading + error snackbar |
| `lib/features/settings/presentation/widgets/settings_sections.dart` | Delete Account tile với `Icons.delete_forever_outlined` + `AppColors.error` |

### Bugs tìm ra và fix (từ Codex + Adversarial review trong /ship)

| # | Bug | Fix |
|---|-----|-----|
| P1 | `verify_jwt` thiếu trong `config.toml` → 401 mọi request | Thêm `[functions.delete-account]` với `verify_jwt = false` |
| P1 | Ghost login: user bị xóa nhưng local session vẫn còn → auto-login sau khi xóa | Thêm `supabase.auth.signOut()` bên trong inner try/catch |
| P1 | Storage `inputs/` prefix không được cleanup | Extract `cleanupPrefix()` helper, gọi cho cả `userId` và `{userId}/inputs` |
| P2 | Edge function không check HTTP method | Thêm guard: return 405 cho non-POST |
| P2 | `on Exception` bỏ qua `AppException` (extends Object, không phải Exception) | Đổi thành `on Object`, bỏ dead arm |
| P2 | Dead `on AppException { rethrow }` arm trong repo | Xóa |

### Test coverage
- `test/features/auth/presentation/view_models/auth_view_model_test.dart` — tăng cường coverage cho `deleteAccount()`:
  - Happy path: xóa thành công, state → unauthenticated
  - Error path: repo throw, state không thay đổi, exception re-throw
  - Provider invalidation sau khi xóa

---

## Phần 2 — Legal URLs (PR #86)

### Vấn đề
URL Privacy Policy / ToS trỏ về `monet88.github.io` (account cũ), không tồn tại.

### Fix
1. Tạo GitHub Pages repo `ainear/artio-legal` với:
   - `privacy.html` — Privacy Policy
   - `terms.html` — Terms of Service
   - `index.html` — landing page
2. Update 4 URL trong Flutter app:
   - `settings_sections.dart` (×2): Privacy Policy + Terms of Service links
   - `paywall_screen.dart` (×2): Privacy Policy + Terms of Service links

**Live URLs:**
- Privacy Policy: https://ainear.github.io/artio-legal/privacy.html
- Terms of Service: https://ainear.github.io/artio-legal/terms.html

---

## Phần 3 — Play Store Release Prep

### Code blockers đã fix

#### 1. App label lowercase (`main` branch, commit `b38d1fcc`)

```xml
<!-- Before -->
android:label="artio"

<!-- After -->
android:label="Artio"
```

#### 2. Keystore password hardcoded trong `build.gradle.kts`

**Before:**
```kotlin
signingConfigs {
    create("release") {
        storePassword = "<your-keystore-password>"  // ❌ hardcoded secret in git
        keyAlias = "artio"
        keyPassword = "<your-key-password>"
    }
}
```

**After:** đọc từ `local.properties` (gitignored):
```kotlin
val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) load(f.inputStream())
}

signingConfigs {
    create("release") {
        storeFile = file(localProps.getProperty("storeFile") ?: "artio-upload.jks")
        storePassword = localProps.getProperty("storePassword")
        keyAlias = localProps.getProperty("keyAlias")
        keyPassword = localProps.getProperty("keyPassword")
    }
}
```

`android/local.properties` (gitignored, giữ local — KHÔNG commit file này):
```properties
storeFile=artio-upload.jks
storePassword=<your-keystore-password>
keyAlias=artio
keyPassword=<your-key-password>
```

### App Name

**Quyết định:** `Artio` (display name), subtitle `AI Art & Image Generator`

Lý do:
- Tên gọn, 5 ký tự — dễ nhớ, dễ gõ
- Không vi phạm trademark
- Subtitle nêu rõ chức năng cho Play Store SEO
- Không có từ cấm ("AI" trong tên gói không vi phạm policy khi đặt ở subtitle)

### Logo

**Quyết định: Variant 1 — A Monogram (Purple Gradient)**

| Tiêu chí | V1 Monogram ✅ | V2 Brush+Spark | V3 Wordmark |
|---|---|---|---|
| Scale 16px–1024px | Tốt nhất | Phức tạp ở nhỏ | Mất chữ ở nhỏ |
| App icon (48–512px) | ✅ | ⚠️ | ❌ |
| Notification icon 24px | ✅ | ❌ | ❌ |
| Premium feel | ✅ | ✅ | ✅ |

**Canva design (đã finalize):**
- Edit: https://www.canva.com/d/aFGjHkvB59ydFmO
- View: https://www.canva.com/d/lOSJ3zHaI9dOuRw

Các variant khác (để tham khảo):
- V1 options: https://www.canva.com/d/gAe8HbqrX3JVQdr | https://www.canva.com/d/n5h3BfOjughsmQa | https://www.canva.com/d/DHCjd5nqMDMtF5b
- V2 (Brush): https://www.canva.com/d/4HVDq4GsFATBhh- | https://www.canva.com/d/l0uxIrFlHSpflRP
- V3 (Wordmark): https://www.canva.com/d/yZdmGsQPD7FD_Di | https://www.canva.com/d/OouQi2867hpjdTl

### Feature Graphic (1024×500)

4 options tạo trên Canva (chọn 1, resize về 1024×500):
- https://www.canva.com/d/NKBY6XECXuh6Wlw
- https://www.canva.com/d/G8FLHWQWFR1DGcG
- https://www.canva.com/d/KFKMTLQECb4K-FN
- https://www.canva.com/d/ZyFQl5h4OQ1WEmX

### Store Listing

**Short Description (65/80 ký tự):**
```
Turn your ideas into stunning AI art. Generate images in seconds.
```

**Full Description:**
```
✨ Artio — AI Art Generator

Transform any idea into breathtaking artwork with the power of AI.
Whether you're a professional designer or a complete beginner,
Artio makes it effortless to create stunning visuals in seconds.

🎨 WHAT YOU CAN CREATE
• Digital paintings & illustrations
• Fantasy landscapes & abstract art
• Character concepts & portraits
• Product mockups & design assets
• Wallpapers & social media content

⚡ POWERFUL AI MODELS
Choose from multiple cutting-edge AI models to match your creative
vision — from photorealistic renders to painterly masterpieces.

🖼️ YOUR CREATIONS, YOUR COLLECTION
Every image you generate is saved to your personal gallery.
Browse, download, and share your artwork anytime.

💎 PREMIUM FEATURES
• Unlimited generations with Pro plan
• Priority processing — no waiting
• Access to the latest AI models
• High-resolution outputs

🔒 PRIVATE & SECURE
Your prompts and generated images belong to you. We never use
your creations to train AI models.

HOW IT WORKS
1. Describe what you want to create in plain language
2. Choose your preferred AI model and style
3. Tap Generate — your artwork appears in seconds
4. Download, share, or keep building

Perfect for artists, designers, content creators, game developers,
and anyone who loves visual creativity.

Start creating for free today — no art skills required.
```

---

## Checklist Play Store Release

### Tự động (đã xong) ✅

- [x] Delete Account feature (required by store policy)
- [x] Privacy Policy live: https://ainear.github.io/artio-legal/privacy.html
- [x] Terms of Service live: https://ainear.github.io/artio-legal/terms.html
- [x] App label: `"Artio"` (proper casing)
- [x] Keystore secrets: khỏi git (local.properties)
- [x] Logo design: Canva finalized
- [x] Feature graphic: Canva options ready
- [x] Store listing text: Short + Full description viết xong

### Thủ công (bạn cần làm)

- [ ] **Logo export**: Mở https://www.canva.com/d/aFGjHkvB59ydFmO → Share → Download → PNG, resize 512×512
- [ ] **Feature graphic export**: Chọn 1 trong 4 links trên → resize về 1024×500 → export PNG
- [ ] **Screenshots**: 5 màn hình từ emulator/device (1080×1920):
  1. Home screen (gallery + prompt bar)
  2. Generation in progress
  3. Result screen (full image)
  4. Settings screen
  5. Paywall / Premium screen
- [ ] **AdMob IDs**: Thay test IDs bằng production IDs trong `AndroidManifest.xml` (Android), `ios/Runner/Info.plist` (iOS) và `.env.production`
- [ ] **Data Safety form**: Khai báo trên Play Console (collect: email, usage data)
- [ ] **Content rating**: Hoàn thành questionnaire trên Play Console
- [ ] **Build AAB**: `flutter build appbundle --release`
- [ ] **Upload lên Play Console**: Internal testing → Closed testing → Production

---

## Ghi chú kỹ thuật

- `verify_jwt = false` là **bắt buộc** cho mọi edge function được gọi từ Flutter: GoTrue v2 phát JWT ES256, Supabase gateway dùng HS256 → mismatch → 401. Function tự validate JWT qua `auth.getUser()`.
- Keystore file `artio-upload.jks` phải backup riêng — nếu mất, không thể update app trên Play Store.
- AdMob Application ID (`ca-app-pub-3940256099942544~3347511713`) trong `AndroidManifest.xml` hiện là **test ID** — phải thay trước khi release production.
