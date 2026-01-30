# Project Overview & Product Development Requirements

**Project**: Artio - AI Image Generation SaaS
**Updated**: 2026-01-30
**Version**: 1.2

---

## Executive Summary

**Artio** ("Art Made Simple") is a cross-platform AI image generation SaaS delivering enterprise-grade image creation through two distinct modes:

1. **Template Engine** (Home tab): Guided image-to-image transformation with curated presets
2. **Text-to-Image** (Create tab): Freeform prompt-based generation

**Market Position:** Consumer-facing AI creativity tool with freemium monetization, targeting casual creators and small businesses.

---

## Product Vision

### Mission
Democratize AI image generation through intuitive templates and flexible text prompts, removing technical barriers for non-technical users.

### Target Users

| Segment | Use Case | Pain Point |
|---------|----------|------------|
| Social Media Managers | Brand-consistent content creation | Manual editing time-consuming |
| Small Business Owners | Product mockups, marketing assets | Professional design tools too complex |
| Content Creators | Thumbnail generation, visual storytelling | Generic stock photos lack originality |
| Hobbyists | Personal projects, gifts | AI tools require prompt engineering skills |

### Value Proposition

- **Template Engine:** Zero learning curve - select template, fill inputs, generate
- **Text-to-Image:** Full creative control for advanced users
- **Cross-Platform:** Same experience on iOS, Android, Web
- **Freemium Model:** Free tier with credits, unlimited with subscription

---

## Functional Requirements

### FR-1: Authentication & User Management

**Priority:** P0 (MVP Blocker)

**User Stories:**
- As a new user, I want to sign up with email/password so I can create an account
- As an existing user, I want to sign in with Google/Apple so I can skip password entry
- As a user, I want to manage my profile (display name, avatar) so I can personalize my account
- As a user, I want to reset my password via email if I forget it

**Acceptance Criteria:**
- [x] Email/password registration with email verification
- [x] Google OAuth on all platforms (iOS, Android, Web)
- [x] Apple Sign-In on iOS (required by App Store)
- [ ] Profile photo upload to Supabase Storage
- [x] Password reset flow via email link
- [x] Session persistence (auto-login on app restart)

**Implementation:**
- Supabase Auth for backend
- `auth` feature (3-layer architecture)
- `authNotifierProvider` for state management
- `AppRouter` auth guards for protected routes

---

### FR-2: Template-Based Image Generation

**Priority:** P0 (MVP Core Feature)

**User Stories:**
- As a user, I want to browse templates by category so I can find relevant styles
- As a user, I want to see a preview of each template so I know what to expect
- As a user, I want to fill dynamic input fields (text, image upload, dropdowns) to customize my generation
- As a user, I want to track generation progress in real-time so I know when it's ready
- As a user, I want to view/download my generated image

**Acceptance Criteria:**
- [x] Template grid with category filters (All, Portrait, Landscape, Product, etc.)
- [x] Template detail view with dynamic input fields
- [x] Support for input types: text, image upload, dropdown (aspect ratio)
- [x] Real-time job status updates (pending → processing → completed/failed)
- [x] Generated image preview with download button
- [x] Error messages for failed generations (user-friendly via AppExceptionMapper)

**Implementation Status:**
- ✓ Complete: Phase 4 (Template Engine)
- ✓ Complete: Phase 4.6 (Architecture Hardening)
- ✓ Complete: 25+ Templates added via SQL migration (Portrait, Editing, Art Style, Fun)
- Pending: KIE API integration in Edge Function

---

### FR-3: Text-to-Image Generation

**Priority:** P1 (Post-MVP)

**User Stories:**
- As a user, I want to enter a custom prompt to generate unique images
- As a user, I want to select generation parameters (style, size, negative prompt)
- As a user, I want to save prompts for reuse

**Acceptance Criteria:**
- [x] Create Screen UI implemented
- [ ] Prompt input with character limit (500 chars)
- [ ] Parameter controls: style (photorealistic, artistic, cartoon), size (1024x1024, etc.)
- [ ] Negative prompt support
- [ ] Prompt history (last 10 prompts)
- [ ] Generation queue (same flow as template engine)

**Implementation:**
- `create` feature (UI implemented)
- Reuses `GenerationRepository` backend
- Edge Function calls Imagen 4 API instead of Nano Banana

---

### FR-4: User Gallery

**Priority:** P1 (Post-MVP)

**User Stories:**
- As a user, I want to view all my generated images in a grid so I can browse my creations
- As a user, I want to filter by date/template/status
- As a user, I want to download images in bulk
- As a user, I want to delete unwanted images

**Acceptance Criteria:**
- [x] Infinite scroll gallery with pagination
- [x] Filter by status (all, completed, failed)
- [x] Sort by date (newest first)
- [x] Multi-select for bulk actions (delete, download)
- [x] Fullscreen viewer with hero animation
- [x] Soft delete with undo functionality

**Implementation:**
- `gallery` feature (Complete)
- Query `generation_jobs` table filtered by `user_id`
- `cached_network_image` for thumbnails

---

### FR-5: Subscription & Credits System

**Priority:** P1 (Monetization)

**User Stories:**
- As a free user, I want to see my credit balance so I know how many generations I have left
- As a free user, I want to purchase credits or subscribe to Pro for unlimited generations
- As a Pro user, I want unlimited generations without credit deductions
- As a mobile user, I want to watch rewarded ads to earn free credits

**Acceptance Criteria:**
- [ ] Free tier: 10 credits on signup, 1 credit per generation
- [ ] Pro tier: $9.99/month, unlimited generations
- [ ] Credit purchase packs: 50 credits ($4.99), 100 credits ($8.99)
- [ ] RevenueCat integration (iOS/Android)
- [ ] Stripe integration (Web)
- [ ] Rewarded ads (AdMob - mobile only)
- [ ] Real-time subscription sync across devices

**Implementation:**
- `subscription` feature (skeleton exists)
- Payment abstraction layer (platform-specific)
- `credits` table in Supabase
- Edge Function to deduct credits on generation

---

### FR-6: Settings & Account Management

**Priority:** P2 (Polish)

**User Stories:**
- As a user, I want to switch between light/dark/system theme
- As a user, I want to change my password
- As a user, I want to delete my account and all data
- As a user, I want to sign out from all devices

**Acceptance Criteria:**
- [x] Theme switcher (persisted in SharedPreferences)
- [ ] Change password flow (requires current password)
- [ ] Delete account with confirmation dialog (cascade deletes profile, jobs, storage files)
- [x] Sign out button (clears local session)
- [x] About dialog (version, credits, privacy policy link)

**Implementation:**
- `settings` feature (Complete)
- `themeProvider` (Riverpod)
- Supabase Auth API for password change
- RLS policies ensure cascade delete

---

### FR-7: Admin Template Management

**Priority:** P2 (Content Management)

**User Stories:**
- As an admin, I want to create/edit/delete templates without code changes
- As an admin, I want to upload template thumbnails
- As an admin, I want to define input fields via JSON editor
- As an admin, I want to reorder templates via drag-and-drop

**Acceptance Criteria:**
- [ ] Admin web app (separate Flutter web project)
- [ ] Admin role check via Supabase RLS (service role key)
- [ ] CRUD UI for templates
- [ ] Visual JSON editor for `input_fields` (Ace Editor or Monaco)
- [ ] Drag-to-reorder (updates `display_order` column)
- [ ] Preview template before publishing

**Implementation:**
- Separate Flutter web app (admin.artio.app)
- Reuses `TemplateModel` from main app
- Admin RLS policy: `auth.jwt() ->> 'role' = 'admin'`

---

## Non-Functional Requirements

### NFR-1: Performance

| Metric | Target | Measurement |
|--------|--------|-------------|
| Cold start time | <2s | Time to interactive on mid-range device |
| Template grid load | <500ms | From tap to full render |
| Generation time (template) | <30s | Pending → Completed (depends on KIE API) |
| Generation time (text-to-image) | <60s | Pending → Completed |
| Image upload | <5s | 5MB image to Storage |

**Implementation:**
- Riverpod auto-dispose for memory management
- `cached_network_image` for thumbnails
- Database indexes on `user_id`, `status`
- Edge Function timeout: 120s (Supabase limit)

---

### NFR-2: Scalability

**MVP Targets:**
- 1,000 DAU (Daily Active Users)
- 10,000 generations/month
- 50 templates

**Growth Targets (Year 1):**
- 50,000 DAU
- 500,000 generations/month
- 200 templates

**Scaling Strategy:**
- Supabase free tier → Pro plan at 5,000 DAU
- KIE API: Monitor rate limits, implement queue if needed
- CDN for Storage (Cloudflare)
- Database read replicas for high query load

---

### NFR-3: Security

**Requirements:**
- No secrets in client code (OWASP MASVS Level 1)
- HTTPS only (enforced by Supabase)
- Row Level Security on all tables
- Input validation (client + server)
- No PII in logs
- GDPR compliance (data export/delete)

**Implementation:**
- Supabase RLS policies reviewed in Phase 4.6
- Edge Function validates input_data against template schema
- AppExceptionMapper sanitizes error messages (no stack traces)
- Account deletion cascade deletes all user data

---

### NFR-4: Reliability

**Targets:**
- 99.5% uptime (SLA via Supabase Pro plan)
- <5% error rate in production
- Graceful degradation (offline-first for settings)

**Error Handling:**
- Retry logic for transient API failures (exponential backoff)
- AppException hierarchy for typed error handling
- Sentry integration for crash reporting

---

### NFR-5: Usability

**Accessibility:**
- WCAG 2.1 Level AA compliance
- Screen reader support (Semantics widgets)
- Minimum touch target: 48x48dp
- High contrast mode support

**Internationalization:**
- English (US) - MVP
- Spanish, French, German - Post-MVP

**Responsive Design:**
- Mobile-first (primary target)
- Tablet layout optimizations (gallery grid 3-column)
- Web responsive (breakpoints: 600dp, 1024dp)

---

## Technical Constraints

### Platform Support

| Platform | Minimum Version | Notes |
|----------|----------------|-------|
| iOS | 13.0+ | Required for SwiftUI deep links |
| Android | 5.0+ (API 21) | 95% market coverage |
| Web | Modern browsers (Chrome 90+, Safari 14+) | PWA support optional |
| Windows | 10+ | Desktop support for development and testing |

### Dependencies

- Flutter SDK: 3.x (stable channel)
- Dart SDK: 3.x
- Supabase Flutter: ^2.x
- Riverpod: ^2.x (with riverpod_generator)
- go_router: ^14.x
- freezed: ^2.x

---

## Technical Debt & Known Issues

### High Priority

| Issue | Impact | Mitigation Plan |
|-------|--------|-----------------|
| ~~Test coverage 15% vs 80% target~~ | ~~Production readiness~~ | ✓ Achieved (324 tests, 80%+) |
### Medium Priority

| Issue | Impact | Mitigation Plan |
|-------|--------|-----------------|
| DTO leakage in domain entities | Architecture purity | Split to Entity + DTO when scaling |
| No DataSource layer | Backend coupling | Add abstraction if backend swap needed |
| Placeholder features not 3-layer | Consistency | Restructure when implementing |

### Accepted Trade-offs

- **Pragmatic Architecture:** Domain entities have JSON logic (acceptable for MVP velocity)
- **Manual Testing:** Comprehensive test suite deferred to post-MVP
- **Raw Navigation:** Awaiting go_router_builder stability

---

## Success Metrics

### Technical KPIs

- [x] `flutter analyze` 0 errors (achieved in Phase 4.6)
- [x] 80%+ test coverage on business logic (324 tests passing)
- [ ] <2s cold start time (to be measured)
- [ ] <500ms template grid load (to be measured)
- [ ] <5% error rate in production

### Product KPIs

| Metric | MVP Target | 6-Month Target |
|--------|-----------|----------------|
| Beta users | 100 | 5,000 |
| Subscription conversions | 5 (5%) | 250 (5%) |
| DAU/MAU ratio | 0.3 | 0.4 |
| App store rating | 4.5+ | 4.7+ |
| Generation completion rate | 90%+ | 95%+ |

---

## Roadmap

### Phase 1-3: Foundation (14h)
**Status:** Pending
- Project setup, dependencies, folder structure
- Core infrastructure (router, theme, HTTP client)
- Auth feature (email/password, OAuth)

### Phase 4: Template Engine (8h)
**Status:** ✓ Complete (2026-01-27)
- Template models, repositories, UI
- Generation job tracking
- Real-time updates

### Phase 4.6: Architecture Hardening (8.5h)
**Status:** ✓ Complete (2026-01-27)
- 3-layer architecture refactor
- Repository DI, error mapper
- Code quality improvements

### Phase 5: Gallery Feature (4h)
**Status:** ✓ Complete (2026-01-28)
- User gallery with pagination
- Image viewer, download/share/delete

### Phase 6: Subscription & Credits (8h)
**Status:** Pending
- Subscription tiers (Free/Pro)
- RevenueCat + Stripe integration
- Credits system, rewarded ads

### Phase 7: Settings Feature (3h)
**Status:** ✓ Complete (2026-01-28)
- Theme switcher, account management
- Sign out, delete account

### Phase 8: Admin App (3h)
**Status:** Pending
- Admin web app for template CRUD
- Visual JSON editor

**Total Estimated Effort:** 48.5h
**Current Progress:** 77% (37.5h complete)

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| KIE API rate limits | High | High | Implement queue + exponential backoff; monitor usage |
| RevenueCat web beta limitations | Medium | Medium | Use Stripe directly for web (already planned) |
| Cross-platform payment testing | High | High | Budget iOS/Android test devices; use sandbox mode |
| Supabase free tier limits | Medium | Medium | Monitor usage dashboard; upgrade early if needed |
| Template content creation | Medium | Medium | MVP with 10 seed templates; hire designer post-launch |
| App Store approval delays | Medium | Low | Submit beta early; address review feedback promptly |

---

## Compliance & Legal

### Data Privacy

- GDPR: User data export/delete via account settings
- CCPA: Same mechanisms as GDPR
- Privacy Policy: Hosted at artio.app/privacy (required by App Store)

### Terms of Service

- User-generated content ownership: Users retain rights to generated images
- Service limitations: Fair use policy (no illegal/harmful content)
- Refund policy: 7-day window for subscription cancellations

### Content Moderation

- Image upload validation: Max 10MB, allowed formats (JPEG, PNG, WebP)
- Prompt filtering: Block offensive keywords (server-side)
- Report abuse: Email contact for user reports

---

## Dependencies & Integrations

### External Services

| Service | Purpose | Plan |
|---------|---------|------|
| Supabase | Backend (DB, Auth, Storage, Functions) | Free tier (MVP) → Pro ($25/mo) |
| Kie API | Image generation (primary) | Pay-per-use (TBD pricing) |
| Gemini | Image generation (fallback) | Pay-per-use |
| RevenueCat | Subscription management (mobile) | Free tier (<$2.5K MRR) |
| Stripe | Payment processing (web) | 2.9% + 30¢ per transaction |
| AdMob | Rewarded ads (mobile) | Revenue share (68%) |
| Sentry | Error tracking | Free tier (5K errors/mo) |

### Third-Party Libraries

- `supabase_flutter`: ^2.x
- `riverpod`: ^2.x + `riverpod_generator`
- `go_router`: ^14.x
- `freezed`: ^2.x + `freezed_annotation` + `json_serializable`
- `cached_network_image`: ^3.x
- `image_picker`: ^1.x
- `share_plus`: ^7.x
- `revenue_cat`: ^6.x (mobile only)
- `url_launcher`: ^6.x

---

## Development Guidelines

### Code Standards

- Feature-first clean architecture (domain/data/presentation)
- Riverpod for state management (@riverpod annotations)
- Freezed for immutable models
- Repository pattern with interfaces
- AppException hierarchy for errors
- Constants extracted to `AppConstants`

See: `docs/code-standards.md` for detailed conventions

### Git Workflow

- Conventional commits (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`)
- Small, focused commits
- Test locally before commit
- Never commit secrets (.env, credentials)

### Testing Requirements

- 80%+ line coverage for production
- Unit tests for repositories, notifiers
- Widget tests for complex UI
- Integration tests for critical flows (auth, generation)

---

## Deployment Strategy

### Environments

- **Dev:** Local Supabase instance (optional)
- **Staging:** Supabase staging project, Flutter debug builds
- **Production:** Supabase prod project, Flutter release builds

### Release Process

1. Code review → merge to `main`
2. Run tests (`flutter test`)
3. Build release (`flutter build apk/ipa/web`)
4. Submit to stores:
   - iOS: Xcode → App Store Connect → TestFlight → Production
   - Android: Gradle → Google Play Console → Internal → Production
   - Web: `flutter build web` → Firebase Hosting / Vercel
5. Monitor Sentry for crashes

---

## Open Questions

1. **KIE API Pricing:** Awaiting pricing details from Nano Banana (affects unit economics)
2. **Template Content:** Design in-house or outsource? (affects timeline)
3. **Localization Priority:** Which languages after English? (user research needed)
4. **Admin Access:** Single admin account or role-based? (affects RLS complexity)
5. **Image Retention:** How long to store generated images? (affects storage costs)

---

## References

- **Development Roadmap:** `docs/development-roadmap.md`
- **Code Standards:** `docs/code-standards.md`
- **System Architecture:** `docs/system-architecture.md`
- **Bootstrap Plan:** `plans/260125-0120-artio-bootstrap/plan.md`
- **Phase 4.6 Report:** `plans/reports/code-reviewer-260127-1959-phase46-architecture-hardening.md`

---

**Document Version:** 1.2
**Last Updated:** 2026-01-30
**Next Review:** Post-Phase 6 (Subscription implementation)
