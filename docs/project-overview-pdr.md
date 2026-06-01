# Project Overview & PDR

## Overview

Artio is a cross-platform AI image generation SaaS built with Flutter,
Supabase, and Supabase Edge Functions. The repository contains three active
surfaces:

| Surface | Path | Purpose |
| --- | --- | --- |
| Main app | `/` | Customer-facing Flutter app for Android, iOS, Web, and Windows |
| Admin app | `/admin` | Flutter Web admin dashboard for template and content management |
| Backend | `/supabase` | Postgres schema, migrations, storage rules, and Edge Functions |

## Product Goals

- Let users create AI images from templates or free-form prompts.
- Keep credit deduction and premium access server-authoritative.
- Support subscriptions, rewarded ads, and purchase verification without
  leaking trust to the client.
- Give admins a lightweight dashboard for managing templates and content.
- Keep the repo easy to understand, test, and deploy across the three surfaces.

## Current Product Scope

### Main app

- Authentication with email/password, Google OAuth, Apple Sign-In, and reset.
- Guest browsing before login.
- Template-driven creation flows with dynamic fields and image inputs.
- Free-form create flow with model selection and generation options.
- Gallery, download/share/delete, and credit history screens.
- Subscription paywall and rewarded ad credit flow.
- Offline-aware UI and content moderation pre-checks.

### Admin app

- Admin sign-in gate and protected routing.
- Dashboard page with summary data.
- Template list, search/filter, CRUD, and drag-and-drop reorder.

### Backend

- `generate-image`: generation pipeline, model routing, credit deduction,
  refund handling, and storage mirroring.
- `reward-ad`: rewarded-ad nonce and claim flow.
- `revenuecat-webhook`: subscription status sync plus credit grant.
- `sync-subscription`: subscription state reconciliation from RevenueCat.
- `verify-google-purchase`: Google Play purchase credit grant.
- `delete-account`: authenticated account deletion and storage cleanup.

## Primary Users

- End users who generate and manage AI images.
- Paying subscribers who expect premium models and credits to work reliably.
- Admin/operators who maintain templates and observe system health.
- Maintainers who need predictable build, test, and deployment flows.

## Success Criteria

- Create, download, and manage generated images without manual backend work.
- Credit balance and subscription state remain consistent across retries.
- Admin template edits persist correctly and are reflected in the app.
- Main app, admin app, and backend can be configured from documented env vars.
- Documentation stays aligned with code changes instead of drifting.

## Current Constraints

- Main app env comes from `--dart-define=ENV=<name>` plus `.env.<name>` files.
- Admin app reads `.env.example` and a local `.env` override.
- Supabase functions require service-role and provider secrets set outside Git.
- Client model lists and server model config must stay synchronized.
- Credit and subscription updates are server-owned, not client-owned.

## Notes

This is an initial product baseline derived from the live codebase, not a future
specification.
