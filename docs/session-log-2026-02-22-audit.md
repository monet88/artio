# Session Log — 2026-02-22 (19:40 ICT)

**Chủ đề**: Audit toàn diện dự án Artio  
**Vai trò AI**: Project Manager + QA Expert + Store Policy Specialist  
**Kết quả**: Báo cáo audit đầy đủ + action plan

---

## Nội dung buổi làm việc

### Yêu cầu của user

> Kiểm tra lại xem dự án còn thiếu hay sai sót gì về giao diện, policy sai với Google/Apple, cần bổ sung gì để đúng chuẩn, đề xuất mọi góc nhìn để dự án tốt hơn và cạnh tranh thu hút người dùng.

### Quy trình phân tích

1. **Đọc codebase**: `ARCHITECTURE.md`, `STACK.md` → hiểu toàn bộ tech stack và feature set
2. **Đọc docs hiện có**: `launch-checklist.md`, `production-readiness-report.md`, `project-audit-report.md`
3. **Phân tích từ 3 góc độ**:
   - Store Compliance (Apple + Google)
   - UI/UX Gaps
   - Competitive Positioning
4. **Tổng hợp** → `docs/audit-pm-qa-2026-02-22.md`

---

## Kết quả chính

### Tổng điểm: 65/100 ⚠️ CHƯA SẴN SÀNG LAUNCH

| Category | Điểm |
|---|---|
| Code Quality | 95/100 ⭐ |
| UI/UX | 55/100 ⚠️ |
| Apple Compliance | 30/100 🔴 |
| Google Compliance | 35/100 🔴 |
| Monetization | 40/100 🔴 |
| Store Assets | 5/100 🔴 |

---

## Các phát hiện quan trọng

### 🔴 Apple Store — Sẽ bị reject nếu không fix

1. **ATT Popup** chưa có → vi phạm iOS 14.5+ policy, AdMob bắt buộc
2. **PrivacyInfo.xcprivacy** chưa có → required từ May 2024
3. **SKAdNetwork IDs** chưa có trong `Info.plist` → AdMob revenue -40%
4. **NSPhotoLibraryUsageDescription** + **NSCameraUsageDescription** → app crash khi dùng camera
5. **Privacy Policy URL** + **ToS URL** → bắt buộc, chưa có
6. **Restore Purchases button** trong paywall → guideline 3.8

### 🔴 Google Play — Sẽ bị reject nếu không fix

1. **Data Safety Section** chưa khai báo trong Play Console
2. **Content Rating Questionnaire** chưa hoàn thành
3. **Ad Declaration** chưa khai báo sử dụng AdMob
4. **Content moderation** chưa có → risk với AI-generated content policy

### 🟠 UI/UX thiếu sót

1. **Onboarding**: Không có → D1 retention thấp
2. **Paywall UI**: 40% chưa làm → $0 revenue subscription
3. **Settings**: Thiếu Privacy Policy link, ToS link, credit history, support
4. **Error messages**: Quá generic → user bối rối
5. **Empty states**: Gallery trắng khi chưa có ảnh

### 🟡 Competitive gaps

1. Batch generation (2-4 ảnh/lần)
2. Image variations
3. Gallery search
4. Credit packs (one-time IAP)
5. Số lượng templates còn ít (25 vs 100+ của đối thủ)

---

## Action Plan tổng hợp

### Sprint 1 (~20h, Tuần 1-2): PHẢI LÀM TRƯỚC KHI SUBMIT
- Privacy Policy + ToS → host online → link vào Settings
- ATT popup + PrivacyInfo.xcprivacy + SKAdNetwork
- iOS permissions (NSPhotoLibrary, NSCamera)
- Content moderation cơ bản (prompt filtering)
- App Icon + Splash Screen branded
- Store screenshots + descriptions

### Sprint 2 (~26h, Launch Week): UX Polish
- Onboarding flow 3 slides
- Paywall UI hoàn chỉnh + Restore Purchases
- Empty states + error messages cụ thể
- Account settings + credit history

### Sprint 3 (~30h, Post-Launch): Competitive Features
- Batch generation, Image variations
- Gallery search, Favorites
- Credit packs (one-time IAP)
- Push notifications

---

## Files tạo ra trong session này

| File | Mô tả |
|---|---|
| [`docs/audit-pm-qa-2026-02-22.md`](./audit-pm-qa-2026-02-22.md) | Báo cáo audit đầy đủ |
| [`docs/session-log-2026-02-22-audit.md`](./session-log-2026-02-22-audit.md) | File này |

---

*Session kết thúc: 2026-02-22 ~19:45 ICT*
