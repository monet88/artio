# 🔍 Audit Toàn Diện — Artio AI Art App

> **Vai trò**: Project Manager + QA Expert + Store Policy Specialist  
> **Ngày**: 2026-02-22  
> **Trạng thái tổng thể**: ⚠️ **CHƯA SẴN SÀNG LAUNCH** — Điểm: 65/100  

---

## 📊 Executive Summary

Artio có **nền tảng kỹ thuật xuất sắc** (Clean Architecture, 651+ tests, 0 lint errors), nhưng **chưa thể lên store** do thiếu nhiều yêu cầu bắt buộc về pháp lý, branding, và compliance.

| Category | Điểm hiện tại | Mục tiêu |
|---|---|---|
| Code Quality | 95/100 ⭐ | ✅ Đạt |
| Core Features | 80/100 ⭐ | ✅ Đạt |
| UI/UX | 55/100 ⚠️ | 75+ |
| Apple Compliance | 30/100 🔴 | 95+ |
| Google Compliance | 35/100 🔴 | 95+ |
| Monetization | 40/100 🔴 | 75+ |
| Store Assets | 5/100 🔴 | 90+ |
| **OVERALL** | **65/100** | **85+** |

---

## 🔴 NHÓM 1: STORE COMPLIANCE — LAUNCH BLOCKERS

> **Thiếu các mục này SẼ BỊ REJECT bởi App Store và Google Play.**

### 1.1 Pháp lý & GDPR

| Hạng mục | Trạng thái | Hệ quả |
|---|---|---|
| Privacy Policy URL | ❌ Chưa có | Store reject ngay |
| Terms of Service URL | ❌ Chưa có | Store reject + OAuth yêu cầu |
| Delete Account (GDPR) | ✅ Đã có backend | OK |
| Data Export (GDPR Art.20) | ❌ Chưa có | Vi phạm GDPR nếu có user EU |

**Fix**: Dùng [iubenda.com](https://iubenda.com) hoặc [termly.io](https://termly.io) → host tại `artio.app/privacy` + `artio.app/terms` → thêm link vào Settings screen.

---

### 1.2 Apple App Store — Vấn đề cụ thể

#### 🔴 ATT (App Tracking Transparency) — iOS 14.5+
- **Vấn đề**: AdMob đang dùng mà chưa hiển thị ATT popup
- **Hệ quả**: Apple REJECT hoặc xóa khỏi store sau khi publish
- **Fix**: Gọi `AppTrackingTransparency.requestTrackingAuthorization()` trước khi init AdMob. Thêm `NSUserTrackingUsageDescription` vào `Info.plist`.

#### 🔴 Privacy Manifest (iOS 17+ — Required từ May 2024)
- **Vấn đề**: Thiếu file `PrivacyInfo.xcprivacy`
- **Hệ quả**: Apple reject mọi submission
- **Fix**: Khai báo APIs sử dụng, third-party SDKs (Supabase, RevenueCat, AdMob, Sentry), tracking domains

#### 🔴 SKAdNetwork IDs
- **Vấn đề**: Thiếu danh sách SKAdNetwork trong `Info.plist`
- **Hệ quả**: AdMob không track được conversion → revenue giảm ~40%
- **Fix**: Download và paste Google's SKAdNetwork list từ [Google AdMob docs](https://developers.google.com/admob/ios/skadnetwork)

#### 🟠 iOS Permissions thiếu trong Info.plist
```xml
<!-- BẮT BUỘC — App crash nếu thiếu -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Artio needs to access your photos to select images for AI generation.</string>

<key>NSCameraUsageDescription</key>
<string>Artio needs camera access to capture photos for AI generation.</string>

<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads to you.</string>
```

#### 🟠 Restore Purchases Button
- **Vấn đề**: Paywall UI chưa có nút Restore Purchases
- **Hệ quả**: Apple guideline 3.8 — bắt buộc, thiếu = rejection
- **Fix**: Thêm vào PaywallScreen khi complete Phase 6

#### 🟡 Demo Account cho Apple Reviewer
- Apple review team cần tài khoản demo đã có sẵn credits → không có = reject

---

### 1.3 Google Play — Vấn đề cụ thể

#### 🔴 Data Safety Section
- **Vấn đề**: Chưa khai báo trong Play Console
- **Hệ quả**: Google Play REJECT hoặc cảnh báo users
- **Phải khai báo**: Email address, User-generated content (images), Device identifiers (GAID), App activity

#### 🔴 Content Rating Questionnaire
- Artio có AI generation → phải khai báo "User Generated Content" và content moderation policy

#### 🟠 Target Audience Declaration
- App AI generation → Phải explicit "18+" hoặc có content filter nghiêm ngặt
- Google rất nghiêm về AI-generated content + minors

#### 🟠 Ad Declaration
- Phải khai báo sử dụng AdMob trong Play Console listing

#### 🟠 Feature Graphic (1024×500)
- Chưa có → listing trông amateur

---

### 1.4 Nội dung AI và Chính sách Nội dung

> **Đây là risk lớn nhất thường bị bỏ qua với AI generation apps.**

| Vấn đề | Mức độ |
|---|---|
| Không có content moderation | 🔴 Critical |
| User có thể tạo nội dung NSFW | 🔴 Blocker |
| Không có abuse reporting | 🟠 High |
| Không có rate limiting server-side | 🟠 High |

**Apple điều 3.1.3(b)**: App không được tạo nội dung gây hại/NSFW không có safeguards.

**Giải pháp minimum viable**:
1. Content policy trong ToS: "Cấm tạo nội dung người lớn, bạo lực..."
2. Prompt filtering (block từ nhạy cảm)
3. Server-side rate limiting: 20 requests/hour/user
4. Report button trong gallery

---

## 🟠 NHÓM 2: UI/UX GAPS

### 2.1 Onboarding — Critical for Activation

```
Hiện tại: User đăng ký → thấy ngay grid templates → bối rối
Vấn đề: Không biết credits là gì, không hiểu cách dùng app
Kết quả: D1 retention thấp (~20-30%)
```

**Đề xuất**: 3-slide onboarding sau lần đăng nhập đầu tiên:
1. "Tạo ảnh AI trong 10 giây" — Show template → generated image
2. "Credits = năng lượng sáng tạo" — Giải thích free credits + ads
3. "Premium không giới hạn" — Upsell nhẹ nhàng

---

### 2.2 Empty States

| Màn hình | Hiện tại | Nên có |
|---|---|---|
| Gallery (lần đầu) | Màn hình trống | "Chưa có ảnh" + CTA "Tạo ảnh đầu tiên" |
| Search không kết quả | — | "Không tìm thấy" + gợi ý |
| Network offline | Banner đơn giản | Full-page offline + Retry |
| Generation đang chờ | Spinner | Progress + estimated time |

---

### 2.3 Settings Screen — Thiếu nhiều tính năng bắt buộc

```
Còn thiếu:
❌ Privacy Policy link → Apple REJECT nếu không có
❌ Terms of Service link → Apple REJECT nếu không có
❌ Account settings (edit name, email)
❌ Change password
❌ Credit history / Transaction log
❌ Subscription management
❌ Help/Support link
❌ Report a problem
❌ Open Source Licenses
```

---

### 2.4 Subscription/Paywall UI — 40% Chưa xong = $0 Revenue

**Paywall screen cần có**:
- Tier comparison (Free vs Pro vs Ultra)
- Tính năng nổi bật mỗi tier rõ ràng
- Monthly/Yearly toggle với "tiết kiệm X%"
- **Restore Purchases button** (BẮT BUỘC — Apple guideline 3.8)
- CTA rõ ràng (VD: "Dùng thử 7 ngày miễn phí")

---

### 2.5 Credit UX — Người dùng không hiểu hệ thống

**Cần thêm**:
- Credit cost hiển thị trước khi generate ("Sẽ tốn 5 credits")
- Credit history screen (backend đã có, thiếu UI)
- "Earn more credits" section cho free users
- Low credit warning ("Còn 5 credits — Watch ad?")

---

### 2.6 Error Messages — Gây Confusion

```
Hiện tại: "Something went wrong. Please try again." (cho tất cả lỗi)

Nên có:
✅ "Không đủ credits. Xem quảng cáo?" [Watch Ad] [Upgrade]
✅ "Mất kết nối mạng." [Retry]
✅ "Phiên đăng nhập hết hạn." [Login]
✅ "Lỗi tạo ảnh — credits đã được hoàn trả." [OK]
```

---

### 2.7 Loading States

| Tình huống | Hiện tại | Nên |
|---|---|---|
| Template grid load | Blank → load | Shimmer skeleton |
| Image generation | Spinner | Progress bar + text |
| Login | Button bình thường | Disabled + spinner |
| Image download | Không có | Progress + success toast |

---

### 2.8 Watermark Logic

```
Hiện tại: Free users thấy watermark overlay trong app
Recommendation:
- Watermark chỉ khi download, không hiển thị trong app
- Hoặc watermark nhỏ, mờ ở góc
- Thêm upsell: "Xóa watermark → Upgrade Pro"
```

---

## 🟡 NHÓM 3: COMPETITIVE GAPS

### 3.1 Feature Gap vs Competitors

| Feature | Artio | Leonardo | DALL-E | Priority |
|---|---|---|---|---|
| Templates | ✅ 25 | ✅ 100+ | ❌ | Cần tăng lên 50-100 |
| Batch generation | ❌ | ✅ 4 images | ❌ | HIGH |
| Image variations | ❌ | ✅ | ✅ | HIGH |
| Gallery search | ❌ | ✅ | ✅ | HIGH |
| Favorites/Collections | ❌ | ✅ | ❌ | MEDIUM |
| Prompt history | ❌ | ✅ | ✅ | MEDIUM |
| Credit packs (one-time) | ❌ | ✅ | N/A | HIGH |
| Social sharing feed | ❌ | ✅ | ❌ | LOW |

**Unique Strengths cần leverage**:
- ✅ Templates = easiest UX cho non-experts
- ✅ Free credits via ads = không competitor nào làm
- ✅ Cross-platform native (iOS + Android)
- ✅ Giá Pro tier rẻ nhất ($9.99)

---

### 3.2 ASO (App Store Optimization)

**Keyword strategy**:
- Primary: "ai art generator", "ai image maker"
- Secondary: "text to image", "ai painting", "art ai"
- Long-tail: "free ai art", "ai art from photo"
- VN market: "tạo ảnh AI"

**Screenshots strategy** (3 đầu quan trọng nhất):
1. "Tạo ảnh AI trong 10 giây" — Before/after wow shot
2. "100+ Templates mọi phong cách" — Grid view
3. "Miễn phí + kiếm credits từ quảng cáo" — Credits UI

---

### 3.3 Monetization Optimization

**Vấn đề hiện tại**:
- 10 ads × 5 credits = 50 free credits/ngày → quá nhiều, không pressure upgrade
- Không có credit packs (one-time purchase)
- Không có upsell triggers tự động

**Recommendations**:
1. Giảm ads xuống 5/ngày hoặc 3 credits/ad
2. Thêm Credit Packs: 100c/$1.99, 500c/$7.99, 1000c/$12.99
3. Upsell sau 3 lần generate → paywall nhẹ nhàng
4. Subscription trial 7 ngày free
5. Yearly discount 20-30%

---

### 3.4 Retention Improvements

| Feature | D1 Impact | D7 Impact | Effort |
|---|---|---|---|
| Daily free credits | HIGH | HIGH | Medium |
| "Ảnh của ngày" challenge | LOW | HIGH | Low |
| Push notifications | LOW | MEDIUM | Low |
| Achievement system | LOW | MEDIUM | Medium |
| Referral program | MEDIUM | LOW | Medium |

---

## 🔒 SECURITY & PRIVACY

| Vấn đề | Risk | Fix |
|---|---|---|
| `.env` chứa service role key | HIGH | Remove từ client env |
| Không có rate limiting | HIGH | Supabase RLS + Edge Function rate limit |
| Không có content moderation | HIGH | Prompt filtering + report system |
| AdMob test IDs trong production | HIGH | Env-based config |

---

## 📋 PRIORITY ACTION PLAN

### 🔴 Sprint 1 — PHẢI LÀM TRƯỚC KHI SUBMIT (~20h, Tuần 1-2)

| # | Task | Thời gian | Blocker cho |
|---|---|---|---|
| 1 | Privacy Policy + ToS (iubenda.com) | 2h | App Store + Play Store |
| 2 | Thêm PP/ToS link vào Settings | 1h | Apple review |
| 3 | ATT popup + NSUserTrackingUsageDescription | 1h | iOS 14.5+ |
| 4 | SKAdNetwork list vào Info.plist | 30min | AdMob iOS |
| 5 | PrivacyInfo.xcprivacy | 3h | iOS 17+ |
| 6 | NSPhotoLibraryUsageDescription + NSCameraUsageDescription | 30min | iOS crash |
| 7 | Content policy + prompt filtering cơ bản | 2h | Apple 3.1.3(b) |
| 8 | App Icon 1024×1024 + Splash Screen | 4h | Store listing |
| 9 | Store screenshots (tất cả sizes) | 4h | Store submission |
| 10 | Store descriptions + keywords | 2h | Store submission |
| 11 | Demo account cho Apple reviewer | 30min | iOS review |

---

### 🟠 Sprint 2 — CẦN TRONG TUẦN ĐẦU SAU LAUNCH (~26h)

| # | Task | Thời gian |
|---|---|---|
| 1 | Onboarding flow (3 slides) | 6h |
| 2 | Empty states (Gallery, Search, Offline) | 2h |
| 3 | Error messages cụ thể theo từng lỗi | 2h |
| 4 | Loading states + shimmer | 2h |
| 5 | Paywall screen + Package selection UI | 8h |
| 6 | Restore Purchases button | 1h |
| 7 | RevenueCat Dashboard production setup | 2h |
| 8 | Account settings (edit name, change password) | 3h |

---

### 🟡 Sprint 3 — POST-LAUNCH (~30h)

| # | Task | Thời gian | Impact |
|---|---|---|---|
| 1 | Gallery search | 4h | High |
| 2 | Batch generation (2-4 images) | 6h | Very High |
| 3 | Image variations | 6h | High |
| 4 | Credit packs (one-time IAP) | 3h | High |
| 5 | Favorites/Collections | 4h | Medium |
| 6 | Prompt history | 3h | Medium |
| 7 | Push notifications | 4h | Medium |

---

## 🎯 Kết luận

**3 việc quan trọng nhất cần làm NGAY**:
1. **Privacy Policy + ToS** → Không có = không submit được store
2. **ATT Prompt + PrivacyInfo.xcprivacy** → Apple reject iOS 17+ apps
3. **Paywall UI hoàn chỉnh** → Không có = $0 revenue subscription mãi mãi

**Estimate thời gian đến launch**:
- Tối thiểu (P0 only): **2 tuần**
- Thực tế (P0 + P1): **4 tuần**
- Conservative (P0 + P1 + polish): **6 tuần**

---

*Prepared by: PM/QA Expert Analysis | 2026-02-22*
