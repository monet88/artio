# Development Roadmap

**Project**: Artio - AI Art Generation App
**Last Updated**: 2026-01-28
**Current Phase**: 90% Complete → Subscription or Create Feature Next

---

## Execution Order (Re-Prioritized)

> **Note**: Phase 6 (Subscription) deferred to LAST - awaiting Stripe/RevenueCat setup

| # | Plan | Status | Effort | Priority |
|---|------|--------|--------|----------|
| 0 | Artio Bootstrap | ✅ Phase 1-5,7,8 Complete | 38h | P0 |
| 0.5 | Documentation Standardization | ✅ Complete | 2h | P1 |
| 1 | Architecture Hardening | ✅ Complete | 10h | P1 |
| 2 | Gallery Feature | ✅ Complete | 4h | P1 |
| 4 | Settings Feature | ✅ Complete | 2h | P2 |
| **8** | **[Admin App](#plan-8-admin-app)** | ✅ **Complete** | **3h** | **P1** |
| 9 | Create Feature (Text-to-Image) | 🔲 **NEXT** | 4h | P1 |
| 6 | Subscription & Credits | ⏸️ Deferred | 8h | P2 |
| 5 | TypedGoRoute Migration | ⏸️ Deferred | 4h | P3 |

---

## Completed Plans

### Plan 0: Artio Bootstrap
**Status**: ✅ Phase 1-5,7 Complete (35h)

| Phase | Focus | Status |
|-------|-------|--------|
| 1 | Project Setup | ✅ |
| 2 | Core Infrastructure | ✅ |
| 3 | Auth Feature | ✅ |
| 4 | Template Engine | ✅ |
| 5 | Gallery Feature | ✅ |
| 6 | Subscription & Credits | ⏸️ Deferred |
| 7 | Settings Feature | ✅ |
| 8 | Admin App | ✅ Complete |

### Plan 1: Architecture Hardening
**Status**: ✅ Complete (2026-01-27)
- 3-layer architecture for all features
- Repository DI with Supabase constructor injection
- Error mapper for user-friendly messages
- Code quality improvements

---

## Plan 8: Admin App

**Path**: `plans/260125-0120-artio-bootstrap/phase-08-admin-app.md`
**Status**: ✅ Complete (2026-01-28)
**Effort**: 3h
**Priority**: P1 (High)

### Why Now?
- No payment dependencies (Stripe/RevenueCat not required)
- Enables template management without database access
- Unblocks content creation workflow

### Core Features
| Feature | Description | Priority |
|---------|-------------|----------|
| Template CRUD | Create, Read, Update, Delete templates | P0 |
| Reorder | Drag-drop template ordering | P0 |
| JSON Editor | Edit input fields as JSON | P0 |
| Admin Auth | Email/password with role check | P0 |
| Image Upload | Upload thumbnail for templates | P1 |
| Search/Filter | Find templates by name/category | P1 |
| Bulk Actions | Enable/disable multiple templates | P2 |

### Deliverables
```
admin/                          # Separate Flutter web project
├── lib/
│   ├── core/
│   │   ├── router/            # GoRouter with admin guard
│   │   └── theme/             # Admin theme
│   ├── features/
│   │   ├── auth/              # Admin login
│   │   ├── templates/         # CRUD pages
│   │   └── dashboard/         # Analytics (optional)
│   └── main.dart
├── pubspec.yaml
└── web/
```

### Database Changes
```sql
-- Add role column to profiles
ALTER TABLE profiles ADD COLUMN role TEXT DEFAULT 'user';

-- Admin RLS policy for templates
CREATE POLICY "Admins can manage templates"
ON templates FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE profiles.id = auth.uid()
    AND profiles.role = 'admin'
  )
);
```

### Todo List
- [ ] Create admin Flutter web project
- [ ] Configure Supabase connection
- [ ] Add admin role to profiles table
- [ ] Create RLS policies for admin access
- [ ] Implement admin auth guard
- [ ] Create templates list page (Card UI)
- [ ] Create template editor page (Form + JSON)
- [ ] Add drag-drop reordering
- [ ] Add image upload for thumbnails
- [ ] Add search/filter functionality
- [ ] Test all CRUD operations
- [ ] Deploy to admin.artio.app

### Success Criteria
- [ ] Only admin users can access
- [ ] Templates CRUD works correctly
- [ ] Reordering updates database
- [ ] JSON validation before save
- [ ] Changes reflect in main app immediately
- [ ] Admin app deploys separately

---

## Plan 6: Subscription & Credits (DEFERRED)

**Status**: ⏸️ Deferred - Awaiting payment setup
**Effort**: 8h
**Priority**: P2 (Medium)

### Blocking Factors
- ❌ Stripe account not registered
- ❌ RevenueCat not configured

### When to Execute
1. Register Stripe account
2. Configure RevenueCat dashboard
3. Then implement this phase

### Features (Planned)
- Credit system (purchase/earn/spend)
- Subscription tiers (Free/Pro)
- RevenueCat integration (mobile)
- Stripe integration (web)
- Rate limiting

---

## Plan 5: TypedGoRoute Migration (DEFERRED)

**Status**: ⏸️ Deferred
**Priority**: P3 (Low)
**Blocked by**: go_router_builder compatibility

---

## Progress Summary

### Completed (90%)
| Feature | Status |
|---------|--------|
| Authentication | ✅ Email, OAuth, Password Reset |
| Template Engine | ✅ Browse, Generate, Track Progress |
| Gallery | ✅ Masonry Grid, View, Download, Share, Delete |
| Settings | ✅ Theme Switcher |
| Admin App | ✅ Flutter Web Dashboard |
| Architecture | ✅ 3-layer, DI, Error Handling |
| Documentation | ✅ README, ROADMAP, AGENTS, CLAUDE |

### Remaining (10%)
| Feature | Effort | Priority | Dependency |
|---------|--------|----------|------------|
| **Create Feature** | 4h | P1 | None |
| Subscription & Credits | 8h | P2 | Stripe/RevenueCat |
| TypedGoRoute | 4h | P3 | go_router_builder |

---

## Quick Commands

```bash
# Start Admin App development
flutter create --org com.artio --project-name artio_admin admin
cd admin && flutter config --enable-web

# Run admin app locally
cd admin && flutter run -d chrome

# Deploy admin app
cd admin && flutter build web
# Then deploy build/web to Cloudflare Pages/Vercel/Netlify
```

---

## Timeline Estimate

| Milestone | Effort | Target |
|-----------|--------|--------|
| Admin App MVP | 3-4h | This week |
| Full Admin App | 5-6h | This week |
| Subscription (when ready) | 8h | After payment setup |
| Production Release | - | After all features |

---

## Legend

| Symbol | Meaning |
|--------|---------|
| 🔲 | Pending |
| 🔄 | In Progress |
| ✅ | Complete |
| ⏸️ | Blocked/Deferred |
