# Story Backlog

This backlog holds the current Artio maintenance and expansion epics.

Do not create every possible story packet up front. Create story packets when
the work is selected or when a product decision needs a durable place to land.

## Candidate Epics

| Epic | Description | Status | Next Artifact |
| --- | --- | --- | --- |
| Main app reliability | Keep auth, generation, gallery, credits, and subscription flows stable as the product evolves. | active | Story packet for the next user-visible change |
| Subscription and credit reconciliation | Keep RevenueCat, Google Play, and credit grants consistent across retries and webhooks. | active | High-risk story packet or decision record |
| Admin template operations | Keep template CRUD, reorder, and dashboard workflows fast and predictable for operators. | active | Story packet for admin workflow changes |
| Backend contract hardening | Keep `generate-image`, reward ads, and account deletion aligned with current security and idempotency rules. | active | High-risk story packet or validation report |
| Documentation and harness sync | Keep docs, backlog, matrix, and trace expectations aligned with the live repo. | active | Harness backlog item or docs update |

## Notes

- This backlog is intentionally small and maintenance-oriented.
- Add a story packet only when the epic is selected for implementation or when a
  durable decision is needed.
- If a new product area appears, add a scoped initiative note instead of turning
  this file into a second spec.
