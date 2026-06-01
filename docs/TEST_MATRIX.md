# Test Matrix

This file maps current Artio behavior to proof.

A row is only `implemented` when the contract exists in code and the relevant
proof exists in the repository.

## Status Values

| Status | Meaning |
| --- | --- |
| planned | Accepted as intended behavior, not yet implemented |
| in_progress | Actively being built or validated |
| implemented | Implemented and proof exists |
| changed | Contract changed after earlier implementation |
| retired | No longer part of the product contract |

## Matrix

| Story | Contract | Unit | Integration | E2E | Platform | Status | Evidence |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Main app auth | Email/password, Google OAuth, Apple Sign-In, reset, guest browsing | yes | partial | yes | no | implemented | `test/features/auth/*`, `lib/features/auth/*`, `README.md` |
| Generation flow | Template and create flows route into `generate-image` with credit deduction and refunds | yes | yes | partial | yes | implemented | `test/features/create/*`, `test/features/template_engine/*`, `supabase/functions/generate-image/index.ts` |
| Credit handling | Server-authoritative credit deduction, refund, and 402 handling | yes | yes | partial | no | implemented | `test/features/credits/*`, `supabase/functions/_shared/credit_logic.ts`, `README.md` |
| Gallery operations | Gallery render, viewer, download/share/delete actions | yes | partial | yes | no | implemented | `test/features/gallery/*`, `lib/features/gallery/*` |
| Subscription sync | RevenueCat webhook, sync-subscription, and verify-google-purchase keep tier and credits aligned | yes | yes | partial | yes | implemented | `test/features/subscription/*`, `supabase/functions/revenuecat-webhook/index.ts`, `supabase/functions/sync-subscription/index.ts`, `supabase/functions/verify-google-purchase/index.ts` |
| Rewarded ads | Nonce request, claim, and Google SSV callback grant credits safely | yes | yes | partial | yes | implemented | `supabase/functions/reward-ad/index.ts`, `supabase/functions/_shared/credit_logic.ts` |
| Admin templates | Admin auth gate, template CRUD, reorder, and dashboard shell | yes | partial | yes | no | implemented | `admin/test/*`, `admin/lib/features/templates/*`, `admin/lib/features/dashboard/*` |
| Environment bootstrap | Main app env loading, admin env fallback, and Supabase startup checks | yes | yes | no | yes | implemented | `lib/core/config/env_config.dart`, `admin/lib/main.dart`, `README.md` |
| Model contract sync | Client model list and server model config stay aligned | yes | yes | no | no | implemented | `lib/core/constants/ai_models.dart`, `supabase/functions/_shared/model_config.ts` |
| Harness proof map | Matrix, trace spec, backlog, and maturity docs describe the operating model | yes | partial | no | yes | implemented | `docs/TEST_MATRIX.md`, `docs/TRACE_SPEC.md`, `docs/HARNESS_BACKLOG.md`, `docs/HARNESS_MATURITY.md` |

## Evidence Rules

- Unit proof covers pure domain and application rules.
- Integration proof covers backend enforcement, data integrity, provider
  behavior, jobs, or service contracts.
- E2E proof covers user-visible browser or device flows.
- Platform proof covers shell, deployment, mobile, desktop, or runtime behavior
  that cannot be proven in lower layers.
- A story can be implemented without every proof column if the story packet
  explains why.

## Notes

- Add rows when new product behavior or harness behavior becomes a stable
  contract.
- Mark a row `changed` when the contract moves and old proof is no longer
  sufficient.
