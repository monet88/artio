# SPEC.md — Project Specification

> **Status**: `FINALIZED`
> **Date**: 2026-02-17

## Vision

Artio is a freemium AI art generation app. Users open the app and immediately start browsing and creating — no login wall. Monetization follows a **hybrid ads + subscription** model: free users watch rewarded ads to earn credits, while subscribers receive monthly credit allocations and access to premium AI models. The goal is maximum user engagement through a frictionless onboarding experience, converting engaged users into subscribers through demonstrated value.

## Goals

1. **Remove login wall** — Users enter the app directly to Home screen, can browse templates and generate images immediately
2. **Credit-based economy** — All image generation costs credits; credits are the universal currency
3. **Rewarded ads for free users** — Free users earn credits by watching Google AdMob rewarded ads
4. **Subscription tiers** — Pro and Ultra subscriptions provide monthly credits, premium model access, and ad-free experience
5. **Lazy authentication** — Login/signup only prompted when user triggers a premium action or needs account persistence

## Non-Goals (Out of Scope)

- **Credit packs** — No direct credit purchases; only subscriptions
- **Stripe / Web payments** — Defer to future milestone; this milestone is mobile-only (iOS + Android)
- **Social login** — Existing Google/Apple login stays, no new OAuth providers
- **Image-to-image / editing models** — Existing models stay, no new generation modes
- **Referral / affiliate system** — Not in this version

## Users

### Anonymous User (Free Tier)
- Opens app, lands on Home screen immediately
- Browses templates, views template details
- Receives **20 welcome credits** on first launch
- Watches **rewarded ads** (max 10/day) to earn **5 credits per ad** (max 50 credits/day)
- Can only use **free models** (`isPremium: false`)
- Generated images have a **small watermark**
- Prompted to login/subscribe when:
  - Selecting a premium model
  - Running out of credits (with option to watch ad or subscribe)

### Authenticated Free User
- Same as anonymous but credits tied to account (persists across devices)
- Gallery synced via Supabase

### Subscriber (Pro / Ultra)
- Monthly credit allocation
- Access to all models including premium (`isPremium: true`)
- No ads, no watermark
- Priority generation queue (future)

## Monetization Model

### Credit Economy

| Action | Credits |
|--------|---------|
| Watch rewarded ad | +5 credits |
| Welcome bonus (new user) | +20 credits |
| Pro subscription (monthly) | +200 credits |
| Ultra subscription (monthly) | +500 credits |

All generation costs from existing `AiModelConfig.creditCost` (4-20 credits per image).

### Subscription Tiers

| Tier | Monthly | Annual | Credits/month | Premium Models | Ads | Watermark |
|------|---------|--------|---------------|----------------|-----|-----------|
| **Free** | $0 | $0 | Earn via ads | ❌ | ✅ | ✅ |
| **Pro** | $9.99 | $79.99 | 200 | ✅ | ❌ | ❌ |
| **Ultra** | $19.99 | $149.99 | 500 | ✅ | ❌ | ❌ |

### Ad Limits

| Limit | Value |
|-------|-------|
| Credits per ad | 5 |
| Max ads per day | 10 |
| Max daily ad credits | 50 |
| Ad type | Google AdMob Rewarded Video |

## Constraints

- **Payment provider**: RevenueCat only (iOS + Android in-app purchases)
- **Ad provider**: Google AdMob (already in pubspec: `google_mobile_ads: ^6.0.0`)
- **Backend**: Supabase (existing) — needs new tables for credits, subscriptions, ad tracking
- **Edge Function**: Currently requires JWT — must support anonymous Supabase auth for free users
- **Existing architecture**: Clean Architecture per feature must be maintained
- **State management**: Riverpod with codegen (existing pattern)
- **Anonymous tracking**: Device UUID stored in `SharedPreferences` until account creation

## Success Criteria

- [ ] App opens directly to Home screen — no login required
- [ ] Anonymous user can browse all templates and view details
- [ ] Anonymous user receives 20 welcome credits on first launch
- [ ] Anonymous user can generate images with free models using credits
- [ ] Rewarded ad flow works: watch ad → receive 5 credits (max 10 ads/day)
- [ ] Premium model selection triggers login + subscription prompt
- [ ] Credit deduction happens before generation starts
- [ ] Insufficient credits shows "Watch Ad" or "Subscribe" options
- [ ] Pro subscription ($9.99/month, $79.99/year) grants 200 credits + premium access
- [ ] Ultra subscription ($19.99/month, $149.99/year) grants 500 credits + premium access
- [ ] Subscribers see no ads and images have no watermark
- [ ] Free tier images have small, non-intrusive watermark
- [ ] RevenueCat integration handles subscription lifecycle (purchase, renewal, cancellation, restore)
- [ ] Credits persist across app restarts (local for anonymous, Supabase for authenticated)
- [ ] Monthly credit allocation auto-replenishes for active subscribers
