# 🚀 Feature Implementation Plan: Compliance & Fixes

**Branch**: `feature/compliance-and-fixes`  
**Date**: 2026-02-22  
**Target**: Production-ready compliance

---

## 📋 IMPLEMENTATION TASKS

### PHASE 1: CRITICAL FIXES (P0)

#### 1.1 Fix Generation Error Handling ✅
**File**: `lib/features/template_engine/presentation/view_models/generation_view_model.dart`
- Replace `Exception` with `AppException`
- Add specific error messages for policy denials
- **Impact**: Users see actual error instead of "Something went wrong"

#### 1.2 Add Delete Account Feature 🔴 CRITICAL
**Requirement**: GDPR/CCPA compliance (mandatory for App Store/Play Store)
- Add "Delete Account" button in Settings
- Confirmation dialog (2-step: checkbox + confirm button)
- Backend: Cascade delete (user → profile → jobs → storage files)
- Logout + redirect to login after deletion
- **Files to create/modify**:
  - `lib/features/settings/presentation/widgets/delete_account_section.dart`
  - Update `lib/features/settings/presentation/screens/settings_screen.dart`
  - Add repository method in auth

#### 1.3 Add Privacy Policy & Terms Links 🔴 CRITICAL
**Requirement**: App Store/Play Store mandatory
- Add section in Settings screen
- Links to Privacy Policy & Terms of Service
- Create placeholder pages (can update URL later)
- **Files**:
  - Update `settings_screen.dart`
  - Add `legal_links_section.dart` widget
  - Use `url_launcher` package

---

### PHASE 2: GOOGLE/APPLE POLICY COMPLIANCE (P0)

#### 2.1 iOS Specific Requirements ✅ DONE
- [x] NSCameraUsageDescription
- [x] NSPhotoLibraryUsageDescription
- [x] NSUserTrackingUsageDescription

#### 2.2 Content Policy Compliance
**Required**:
- [ ] Age rating determination (4+ / 12+ / 17+)
- [ ] Content moderation policy
- [ ] Report abuse mechanism
- [ ] COPPA compliance (if targeting kids)

**Recommended**:
- Prompt filtering (block offensive keywords)
- Image validation (max size, allowed formats)
- User content guidelines

#### 2.3 Data Privacy
**Required**:
- [x] RLS policies (done)
- [ ] Data export functionality
- [ ] Account deletion (see 1.2)
- [ ] Privacy Policy URL (see 1.3)
- [ ] Cookie consent (web only)

---

### PHASE 3: UI/UX IMPROVEMENTS (P1)

#### 3.1 Onboarding Flow
**Missing**: First-time user experience
- Welcome screen (3 slides)
- Feature highlights
- Quick tutorial
- Skip button

#### 3.2 Empty States
**Current gaps**:
- Gallery empty → Show "No images yet" + CTA
- Templates loading → Skeleton loading
- Network error → Retry button
- Search no results → Helpful message

#### 3.3 Loading States
**Improve**:
- Generation progress: Better visual feedback
- Image upload: Progress indicator
- Login: Disable button while loading
- Form validation: Inline errors

#### 3.4 Error Recovery
**Add**:
- Retry button on errors
- "Try again" action
- Network status indicator
- Offline mode message

---

### PHASE 4: SETTINGS SCREEN ENHANCEMENTS (P1)

#### 4.1 Current Settings ✅
- [x] Theme switcher
- [x] Sign out
- [x] About dialog

#### 4.2 Missing Settings 🔴
- [ ] **Account section**:
  - Display name edit
  - Email display (read-only)
  - Change password
  - Delete account (CRITICAL)

- [ ] **Legal section**:
  - Privacy Policy link (CRITICAL)
  - Terms of Service link (CRITICAL)
  - Licenses (optional)

- [ ] **Support section**:
  - Help Center / FAQ
  - Contact support (email)
  - Report a problem

- [ ] **App Info**:
  - Version number ✅ (done)
  - Build number
  - Check for updates (optional)

- [ ] **Preferences**:
  - Language selection (if multi-language)
  - Notification settings
  - Default model selection

---

### PHASE 5: STORE SUBMISSION READINESS (P0)

#### 5.1 App Metadata
- [ ] App name: "Artio - AI Art Generator"
- [ ] Subtitle/Short description
- [ ] Keywords for ASO
- [ ] Category: Graphics & Design / Photo & Video
- [ ] Age rating: 4+ (or higher based on content)

#### 5.2 Visual Assets
- [ ] App icon (1024x1024 PNG)
- [ ] Launch screen
- [ ] Screenshots (all required sizes):
  - iPhone 6.7" (3 required)
  - iPhone 6.5" (3 required)
  - iPhone 5.5" (optional)
  - iPad Pro 12.9" (3 required)
  - Android Phone (4-8 required)
  - Android Tablet (optional)

#### 5.3 Store Listing Text
- [ ] App description (2-4 paragraphs)
- [ ] What's New (changelog)
- [ ] Promotional text

#### 5.4 Contact Information
- [ ] Support email
- [ ] Support URL (help center)
- [ ] Marketing URL (landing page)
- [ ] Privacy Policy URL (CRITICAL)

---

### PHASE 6: GOOGLE PLAY SPECIFIC (P0)

#### 6.1 Required
- [ ] Feature graphic (1024x500)
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] Declare ad types (AdMob)
- [ ] Declare permissions usage
- [ ] Content rating questionnaire
- [ ] Target audience (age groups)

#### 6.2 Privacy & Security
- [ ] Data safety section (what data collected)
- [ ] Declare third-party SDKs:
  - Supabase
  - RevenueCat
  - AdMob
  - Sentry

---

### PHASE 7: APP STORE SPECIFIC (P0)

#### 7.1 Required
- [ ] App Review Information:
  - Demo account credentials
  - Special instructions
  - Contact info
- [ ] Export Compliance (encryption usage)
- [ ] Advertising Identifier usage (IDFA)
- [ ] SKAdNetwork identifiers (AdMob)

#### 7.2 Apple Sign-In Requirements
- [x] Apple Sign-In implemented
- [ ] "Sign in with Apple" button (must be prominent)
- [ ] Privacy manifest (PrivacyInfo.xcprivacy)

---

## 🎨 UI/UX ISSUES FOUND

### Critical UX Issues

1. **No error recovery** - Users stuck when errors happen
2. **No empty states** - Confusing when gallery is empty
3. **No onboarding** - New users don't know how to start
4. **Generic error messages** - "Something went wrong" everywhere
5. **No loading feedback** - Users don't know if app is working

### Design Improvements Needed

1. **App Icon** - Currently using default Flutter icon
2. **Splash Screen** - Plain white/black screen
3. **Color scheme** - Need consistent brand colors
4. **Typography** - Inconsistent font sizes
5. **Spacing** - Some screens too cramped

---

## 📱 COMPETITOR ANALYSIS

### What competitors have that we don't:

1. **Better onboarding** (Midjourney, DALL-E)
2. **Image history with search** (we have gallery but no search)
3. **Favorites/Collections** (organize images)
4. **Style presets** (quick style selection)
5. **Batch generation** (3-5 images at once)
6. **Image variations** (generate similar images)
7. **Upscaling** (2K → 4K)
8. **Social sharing** (Instagram/Facebook one-tap)

---

## 🔒 SECURITY & PRIVACY COMPLIANCE

### Current Status: ⚠️ INCOMPLETE

#### Missing (CRITICAL for launch):
1. ❌ Privacy Policy URL
2. ❌ Terms of Service URL
3. ❌ Account deletion
4. ❌ Data export
5. ❌ Content moderation

#### Have (GOOD):
1. ✅ RLS policies
2. ✅ Auth guards
3. ✅ Input validation
4. ✅ HTTPS only
5. ✅ No secrets in code

---

## 💰 MONETIZATION REVIEW

### Current Implementation:
- ✅ Credits system (server-side enforcement)
- ✅ Rewarded ads (AdMob with SSV)
- ⚠️ RevenueCat SDK (init only, no purchase flow)
- ❌ No paywall UI
- ❌ No pricing page

### Recommendations:
1. **Complete Phase 6** (Subscription purchases)
2. **Add upsell prompts**:
   - After 3 generations → Show Pro benefits
   - When credits low → Prompt to upgrade
   - Premium model gating (existing but needs UI polish)
3. **Implement restore purchases**
4. **Add referral program** (invite friends → earn credits)

---

## 🎯 PRIORITY MATRIX

### MUST HAVE (P0) - Launch Blockers
1. 🔴 Delete Account functionality
2. 🔴 Privacy Policy + Terms links
3. 🔴 Fix generation error messages
4. 🔴 App icon + splash screen
5. 🔴 Store screenshots
6. 🔴 Store listing text

### SHOULD HAVE (P1) - Launch Week
1. 🟠 Onboarding flow
2. 🟠 Empty states
3. 🟠 Error recovery (retry buttons)
4. 🟠 Account settings (change password, profile)
5. 🟠 Support/Help section

### NICE TO HAVE (P2) - Post-Launch
1. 🟡 Image search in gallery
2. 🟡 Favorites/Collections
3. 🟡 Batch generation
4. 🟡 Image variations
5. 🟡 Social sharing enhancements

---

## 📅 IMPLEMENTATION TIMELINE

### Week 1 (Current Sprint)
- [x] Create feature branch
- [ ] Fix generation error handling
- [ ] Add delete account
- [ ] Add privacy/terms links
- [ ] Create privacy policy draft
- [ ] Create terms of service draft

### Week 2 (Pre-Launch)
- [ ] App icon design + implementation
- [ ] Splash screen
- [ ] Store screenshots
- [ ] Store listing text
- [ ] Onboarding flow
- [ ] Empty states

### Week 3 (Launch Prep)
- [ ] Beta testing (50-100 users)
- [ ] Bug fixes
- [ ] Performance optimization
- [ ] Final testing
- [ ] Store submission

### Week 4 (Launch)
- [ ] App Store submission
- [ ] Play Store submission
- [ ] Marketing campaign
- [ ] Monitor analytics

---

## 🚀 SUCCESS CRITERIA

### Technical:
- [ ] 0 critical bugs
- [ ] All P0 tasks complete
- [ ] Test coverage >80%
- [ ] Performance <2s cold start
- [ ] Store review guidelines met

### Business:
- [ ] 100 beta signups
- [ ] 4.5+ star rating
- [ ] <5% crash rate
- [ ] 30% D1 retention
- [ ] 5% conversion to Pro

---

**Next Steps**: Start implementing P0 tasks in this branch
