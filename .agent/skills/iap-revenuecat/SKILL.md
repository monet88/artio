---
name: iap-revenuecat
description: >
  Complete In-App Purchase (IAP) setup guide using RevenueCat for Flutter/mobile apps.
  Covers Google Play Console, Google Cloud Console, RevenueCat dashboard, Supabase webhook,
  and Flutter SDK integration. Includes gotchas, 2024-2025 policy changes, and pre-check checklist.
skills:
  - mobile-developer
  - backend-specialist
---

# IAP + RevenueCat Setup Skill

> **Last Updated:** 2026-03-08 (Based on real production setup of Artio app)
> **Stack:** Flutter + RevenueCat + Google Play + Supabase webhook

---

## 🗺️ Overview Architecture

```
Flutter App
  └── RevenueCat SDK (goog_xxx key)
        └── Google Play Billing
              └── Purchase verified server-side via...
                    └── RevenueCat Webhook → Supabase Edge Function
                          └── Update user subscription in DB
```

---

## ⚠️ CRITICAL GOTCHAS (Read FIRST)

### 1. API Access in Google Play Console REMOVED (2024+)
- **Old way:** Settings → API access → Link Google Cloud project
- **New way (2024+):** Go to **Users & Permissions → Invite new users** → paste service account email
- If you navigate to `/apiAccess` URL → redirects to home = permission issue or feature removed

### 2. Service Account Key Creation Disabled (Google Workspace)
- Google Workspace orgs + new projects auto-enforce `iam.disableServiceAccountKeyCreation`
- **Fix:** Use a personal `@gmail.com` account to create a NEW Google Cloud project
- Personal Gmail does not inherit org policies
- Then invite that service account email into Google Play Console

### 3. Package Name Must Match EXACTLY
- RevenueCat package name must match `applicationId` in `android/app/build.gradle.kts`
- The package name used during Google Play app creation is permanent — cannot change
- Common mistake: `com.company.app` vs `com.company.appname` — check carefully

### 4. Service Account Propagation Delay
- After inviting service account to Play Console → wait UP TO 24 HOURS
- RevenueCat will show "Credentials need attention" during this period → normal
- Do not delete and recreate — just wait

### 5. RevenueCat Key Types
- `goog_xxx` = Public (client-side) key for Flutter SDK
- Service Account JSON = Server credential for RevenueCat to verify purchases
- **Both are required** — different purpose

### 6. Webhook Auth Header Format
- RevenueCat sends: `Authorization: Bearer YOUR_SECRET`
- Code must compare: `authHeader === \`Bearer \${secret}\``
- Use timing-safe comparison to prevent timing attacks

### 7. AAB Rebuild Required After .env Changes
- `.env` files are Flutter assets → bundled into APK/AAB
- Changing any key in `.env.*` requires full rebuild + new upload to Play Store

---

## 📋 Step-by-Step Setup (2024-2025)

### PHASE 1: Google Play Console

#### 1.1 Create app
- Application ID (package name) — set once, cannot change
- Upload first AAB → must be **release-signed** (not debug)
- Create release keystore: `keytool -genkey -v -keystore app.jks -keyalg RSA -keysize 2048 -validity 10000`

#### 1.2 Create Subscription Products
- Monetize → Subscriptions → Create subscription
- ID format: `appname_tier_period` (e.g., `artio_pro_monthly`)
- Add base plan → set billing period → add pricing
- Status must be **Active** before RevenueCat can fetch

#### 1.3 Internal Testing Track
- Testing → Internal testing → Create release → Upload AAB
- Add tester emails
- Add test Gmail to **Settings → License testing** (critical for sandbox purchases!)

---

### PHASE 2: Google Cloud Console + Service Account

#### 2.1 Create Google Cloud Project
```
# Use personal @gmail.com account (avoids Workspace org policy restrictions)
1. console.cloud.google.com → New Project → name: "appname-revenuecat"
2. APIs & Services → Enable → "Google Play Android Developer API"
```

#### 2.2 Create Service Account
```
IAM & Admin → Service Accounts → Create service account
  Name: revenuecat-appname
  Role: (leave empty — permissions set in Play Console)
  → Create and continue → Done
```

#### 2.3 Download JSON Key
```
Click service account → Keys tab → Add Key → Create new key → JSON
→ Download file (keep safe, never commit to git!)
```

**If "Key creation disabled" error:**
```bash
# Via gcloud CLI:
gcloud iam service-accounts keys create ./service-account.json \
  --iam-account=SERVICE_ACCOUNT_EMAIL \
  --project=PROJECT_ID

# Or override org policy (if you own the project):
# IAM & Admin → Organization Policies → iam.disableServiceAccountKeyCreation
# → Override parent → Set enforcement: OFF → Save
```

---

### PHASE 3: Link Service Account to Play Console

**2024+ method (API access page removed):**
```
Google Play Console → Users and permissions → Invite new users
  Email: service-account-name@project-id.iam.gserviceaccount.com
  Permissions:
    ✅ View financial data, orders, and cancellation survey responses
    ✅ Manage orders and subscriptions
→ Invite user → Done
```

> Note: Takes up to 24h to propagate

---

### PHASE 4: RevenueCat Dashboard

#### 4.1 App Setup
```
app.revenuecat.com → New App → Android (Play Store)
  App name: [Your App Name]
  Google Play package name: com.your.app  ← MUST match build.gradle applicationId
  Service Account Credentials JSON: upload file from Phase 2.3
```

#### 4.2 Products
```
Product catalog → Products → Import Products (button)
  If import fails (credentials not active yet):
    → New product manually:
    Display name: Artio Pro Monthly
    Product type: Subscription
    Subscription: artio_pro_monthly  ← Google Play subscription ID
    Base plan Id: artio-pro-monthly  ← Base plan ID from Google Play
    Backwards compatible: ✅
```

#### 4.3 Entitlements
```
Product catalog → Entitlements → + New
  pro:   attach artio_pro_monthly, artio_pro_yearly
  ultra: attach artio_ultra_monthly, artio_ultra_yearly
```

#### 4.4 Offerings
```
Product catalog → Offerings → default → Packages tab
  Monthly:       $rc_monthly     → link Pro Monthly product
  Yearly:        $rc_annual      → link Pro Yearly product
  Ultra Monthly: (custom)        → link Ultra Monthly product
  Ultra Yearly:  (custom)        → link Ultra Yearly product
```

#### 4.5 API Keys
```
RevenueCat → Project settings → API Keys
  Android: goog_xxxxxxxxxxxx  → add to .env as REVENUECAT_GOOGLE_KEY
  iOS:     appl_xxxxxxxxxxxx  → add to .env as REVENUECAT_APPLE_KEY
```

---

### PHASE 5: Webhook Setup

#### 5.1 RevenueCat Webhook Config
```
RevenueCat → Integrations → Webhooks → + New webhook
  Name: Supabase Webhook (or Backend Webhook)
  URL: https://YOUR_PROJECT.supabase.co/functions/v1/revenuecat-webhook
  Authorization header: YOUR_SECRET_VALUE
  Environment: Production and Sandbox  ← Use BOTH for testing!
  Events: Initial purchase ✅, Renewal ✅, Product change ✅, Cancellation ✅, Expiration ✅
```

#### 5.2 Set Secret in Supabase
```bash
# Via Dashboard: supabase.com/dashboard → Settings → Edge Functions → Secrets
REVENUECAT_WEBHOOK_SECRET = YOUR_SECRET_VALUE

# Via CLI:
supabase secrets set REVENUECAT_WEBHOOK_SECRET=YOUR_SECRET_VALUE \
  --project-ref YOUR_PROJECT_REF
```

#### 5.3 Webhook Edge Function Template
```typescript
const REVENUECAT_WEBHOOK_SECRET = Deno.env.get("REVENUECAT_WEBHOOK_SECRET")!;

// Verify auth (timing-safe)
const authHeader = req.headers.get("Authorization");
const expectedAuth = `Bearer ${REVENUECAT_WEBHOOK_SECRET}`;
const isValid = timingSafeEqual(authHeader, expectedAuth);

// Handle event types
switch (event.type) {
  case "INITIAL_PURCHASE":
  case "RENEWAL":
    // Grant subscription + credits
    break;
  case "CANCELLATION":
  case "EXPIRATION":
    // Revoke subscription
    break;
  case "PRODUCT_CHANGE":
    // Update tier
    break;
}
```

---

### PHASE 6: Flutter SDK Integration

#### 6.1 pubspec.yaml
```yaml
dependencies:
  purchases_flutter: ^8.x.x
```

#### 6.2 Initialize
```dart
// In main() after env load:
await Purchases.setLogLevel(LogLevel.debug);
await Purchases.configure(
  PurchasesConfiguration(EnvConfig.revenuecatGoogleKey)
    ..appUserID = supabaseUser.id,  // Use auth user ID for cross-device sync
);
```

#### 6.3 Fetch Offerings
```dart
final offerings = await Purchases.getOfferings();
final current = offerings.current;
// Access packages: current?.monthly, current?.annual, etc.
```

#### 6.4 Make Purchase
```dart
try {
  final result = await Purchases.purchasePackage(package);
  // result.customerInfo.entitlements.active contains active entitlements
  final isPro = result.customerInfo.entitlements.active.containsKey('pro');
} on PurchasesErrorCode catch (e) {
  if (e == PurchasesErrorCode.purchaseCancelledError) return;
  // Handle other errors
}
```

---

## ✅ Pre-check Checklist

### Google Play Console
- [ ] App created with correct package name (permanent!)
- [ ] Release-signed AAB uploaded (NOT debug-signed)
- [ ] Subscription products created and **Active**
- [ ] Base plan configured with pricing
- [ ] Internal testing track has testers
- [ ] License testing: tester Gmail added in Settings → License testing
- [ ] Service account invited via Users & Permissions with correct permissions

### Google Cloud Console
- [ ] Project created
- [ ] Google Play Android Developer API enabled
- [ ] Service account created
- [ ] JSON key downloaded and stored safely (NOT in git)

### RevenueCat
- [ ] App created with correct package name
- [ ] Service account JSON uploaded
- [ ] Products match Google Play IDs exactly
- [ ] Entitlements configured
- [ ] Offerings configured with packages
- [ ] Public API key (`goog_xxx`) added to app `.env`
- [ ] Webhook configured with correct URL + secret
- [ ] Webhook environment: **Production AND Sandbox** (not Production only!)

### Flutter App
- [ ] `REVENUECAT_GOOGLE_KEY` = real `goog_xxx` key (not test key)
- [ ] RevenueCat initialized with `appUserID` = auth user ID
- [ ] `.env` files NOT committed to git
- [ ] Version code bumped before each new Play Store upload
- [ ] AAB rebuilt after any `.env` change

### Supabase
- [ ] `REVENUECAT_WEBHOOK_SECRET` set in Edge Function secrets
- [ ] Webhook function deployed and accessible
- [ ] DB has `revenuecat_app_user_id` or equivalent column in users table
- [ ] RPC functions for `update_subscription_status` and `grant_subscription_credits`

---

## 🐛 Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| "Credentials need attention" on RevenueCat | Service account not yet active | Wait up to 24h after inviting |
| "Could not check" on products | Same as above | Wait 24h |
| "Service account key creation is disabled" | Org policy on Google Workspace | Use personal @gmail.com for GCloud project |
| "Forbidden resource" on supabase secrets | CLI not logged in | Run `supabase login` or use dashboard |
| AAB rejected "signed in debug mode" | Wrong keystore used | Configure release signing in build.gradle.kts |
| apiAccess URL redirects to home | Feature removed 2024, or insufficient permissions | Use Users & Permissions → Invite new users |
| Purchase fails in testing | Test account not in License testing | Add Gmail to Settings → License testing in Play Console |
| Webhook not receiving events | "Production only" in RevenueCat | Change to "Production and Sandbox" |
| Wrong tier applied | Product ID prefix mismatch | Check `startsWith("appname_tier_")` in webhook code |

---

## 📁 File Structure Reference

```
android/app/
  build.gradle.kts          ← applicationId, signingConfigs, keystoreProps
  *.jks                     ← Release keystore (DO NOT COMMIT)
  keystore.properties       ← Keystore credentials (DO NOT COMMIT)

lib/
  core/config/env_config.dart    ← All env var accessors

.env.development                 ← Dev secrets (git-ignored)
.env.production                  ← Prod secrets (git-ignored)

supabase/functions/
  revenuecat-webhook/index.ts    ← Server webhook handler
```
