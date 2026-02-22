# 🚀 Quick Reference: Artio Development

**Last Updated**: 2026-02-22

---

## ✅ TRẠNG THÁI HIỆN TẠI

**Main App**: ✅ SẴN SÀNG BUILD DEBUG  
**Admin App**: 🔄 70% complete (210 errors - không block main app)  
**Overall Progress**: ~88%

---

## 🎯 BUILD NGAY

```bash
# Android Debug APK
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk

# Run trên device
flutter run

# iOS (cần Xcode)
open ios/Runner.xcworkspace
```

---

## 🚨 VẤN ĐỀ CẦN FIX NGAY

### 1. iOS Permissions (CRITICAL)

**Vấn đề**: App crash khi dùng Camera/Gallery trên iOS

**Fix**: Thêm vào `ios/Runner/Info.plist` (trước `</dict>` cuối):

```xml
<key>NSCameraUsageDescription</key>
<string>Artio cần camera để chụp ảnh cho AI generation.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Artio cần thư viện ảnh để chọn ảnh cho AI generation.</string>

<key>NSUserTrackingUsageDescription</key>
<string>Định danh để cung cấp quảng cáo cá nhân hóa.</string>
```

### 2. Subscription UI (HIGH)

**Status**: Phase 6 - 40% còn lại  
**Thiếu**: Paywall screen, Package selection, Restore purchases  
**Estimate**: 6-8 hours

---

## 📊 CODE QUALITY

| Metric | Status |
|--------|--------|
| Linter Errors | ✅ 0 |
| Linter Warnings | ✅ 0 |
| Tests | ✅ 651+ passing |
| Type Safety | ✅ 100% |
| Architecture | ⭐️ A- (95%) |

---

## 🔑 ENVIRONMENT

**Hiện tại**: TestNet/Development

**`.env` có**:
- ✅ Supabase URL + Keys
- ✅ RevenueCat Test Keys
- ✅ AdMob Test IDs
- ✅ Stripe Test Key

**Chú ý**: 
- AdMob dùng Test IDs → OK cho development
- Khi production phải đổi production IDs
- SERVICE_ROLE_KEY không dùng trong client (chỉ Edge Functions)

---

## 🧪 TESTING

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test
flutter test test/features/auth/data/repositories/auth_repository_test.dart

# Integration tests
flutter test integration_test/template_e2e_test.dart
```

---

## 📝 DEPENDENCIES

```bash
# Install
flutter pub get

# Generate code
dart run build_runner build --delete-conflicting-outputs

# Check outdated
flutter pub outdated

# Upgrade (cẩn thận!)
flutter pub upgrade
```

---

## 🛠️ TROUBLESHOOTING

### "Target doesn't exist" errors
→ Ignore admin app errors, chỉ build main app

### Android license warning
```bash
flutter doctor --android-licenses
```

### iOS signing issues
→ Mở Xcode, chọn Team trong Signing & Capabilities

### App crash khi chụp ảnh
→ Fix iOS permissions (xem trên)

---

## 📚 DOCUMENTATION

| File | Purpose |
|------|---------|
| `docs/project-audit-report.md` | Phân tích toàn diện dự án |
| `docs/build-status-report.md` | Build verification & commands |
| `docs/session-log-2026-02-22.md` | Session work log |
| `docs/development-roadmap.md` | Development phases |
| `docs/system-architecture.md` | Architecture deep dive |
| `docs/code-standards.md` | Coding conventions |

---

## 🎯 TODO NGẮN HẠN

**Tuần này**:
- [ ] Fix iOS permissions (10 min)
- [ ] Build APK debug (5 min)
- [ ] Test trên device thật
- [ ] Complete Phase 6 (Subscription UI)
- [ ] Setup RevenueCat Dashboard

**Tuần sau**:
- [ ] E2E testing
- [ ] Performance testing
- [ ] UI polish
- [ ] Bug fixes

---

## 🚀 BUILD FOR PRODUCTION (Sau này)

**Checklist**:
- [ ] Privacy Policy + Terms of Service
- [ ] Production Supabase project
- [ ] Production API keys (RevenueCat, AdMob)
- [ ] App icon + splash screen
- [ ] App Store + Play Console listing
- [ ] Marketing materials
- [ ] Code signing certificates

---

## 📞 QUICK LINKS

- Supabase: https://app.supabase.com
- RevenueCat: https://app.revenuecat.com
- AdMob: https://admob.google.com
- Sentry: https://sentry.io

---

**Ready to build?**
```bash
flutter build apk --debug && echo "✅ APK ready!"
```
