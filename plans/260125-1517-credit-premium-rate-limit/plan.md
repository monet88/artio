---
title: "Credit, Premium & Rate Limit Architecture"
description: "Implement calculated credits, hybrid premium sync, and defense-in-depth rate limiting"
status: pending
priority: P1
effort: 6h
branch: master
tags: [backend, auth, monetization, security]
created: 2026-01-25
updated: 2026-01-25
audit_ref: "../reports/flutter-expert-260125-1548-tech-debt-audit.md"
depends_on: "260125-1516-phase46-architecture-hardening"
---

# Credit, Premium & Rate Limit Architecture

## Overview

Replace static credit balance with calculated availability, implement hybrid premium sync for instant UX, and add defense-in-depth rate limiting.

## Prerequisites

⚠️ **MUST complete Plan 1 (Architecture Hardening) before starting this plan.**

Reason: This plan uses paths from new 3-layer structure:
- `lib/features/template_engine/data/repositories/generation_repository.dart`
- `lib/features/auth/data/repositories/auth_repository.dart`
- `lib/features/premium/` (new feature)

## Context

- Brainstorm: `../reports/brainstorm-260125-1517-credit-premium-rate-limit-architecture.md`
- Tech Debt Audit: `../reports/flutter-expert-260125-1548-tech-debt-audit.md`

## Tech Debt Addressed

| Issue | From Audit | How Addressed |
|-------|------------|---------------|
| M3 | Hardcoded defaults (`credits: 5`) | Move to constants, but logic changes anyway |

## Phases

| # | Phase | Status | Effort | Link |
|---|-------|--------|--------|------|
| 1 | Database & Edge Function | Pending | 1.5h | [phase-01](./phase-01-database-edge-function.md) |
| 2 | Credit Availability System | Pending | 1.5h | [phase-02](./phase-02-credit-availability.md) |
| 3 | Rate Limiting & Cooldown | Pending | 1h | [phase-03](./phase-03-rate-limiting.md) |
| 4 | Premium Hybrid Sync | Pending | 1.5h | [phase-04](./phase-04-premium-sync.md) |
| 5 | Input Validation | Pending | 0.5h | [phase-05](./phase-05-input-validation.md) |

## Path Mappings (Post-Architecture Hardening)

| Old Path | New Path |
|----------|----------|
| `template_engine/repository/` | `template_engine/data/repositories/` |
| `template_engine/ui/view_model/` | `template_engine/presentation/view_models/` |
| `template_engine/ui/*.dart` | `template_engine/presentation/screens/` |
| `auth/repository/` | `auth/data/repositories/` |
| `auth/ui/view_model/` | `auth/presentation/view_models/` |

## Dependencies

- ✅ Supabase Edge Function access (`generate-image`)
- ✅ RevenueCat SDK already in `pubspec.yaml` (`purchases_flutter: ^9.0.0`)
- ✅ Supabase Realtime enabled
- ⏳ Architecture Hardening plan complete (dependency)

## Success Criteria

- Zero credit desync errors
- Premium unlock < 1s perceived latency
- No duplicate generation requests
- Rate limit bypass blocked
- Uses new 3-layer architecture paths
