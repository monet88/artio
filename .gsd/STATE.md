# STATE.md

## Current Position
- **Milestone**: Security — Reward Ad SSV
- **Phase**: reward-ad-ssv
- **Task**: Planning complete
- **Status**: Ready for execution

## Plans
| Plan | Name | Wave | Status |
|------|------|------|--------|
| 1 | Database — Nonce Table + RPC Functions | 1 | ⏳ Pending |
| 2 | Edge Function — Split reward-ad into 2 endpoints | 1 | ⏳ Pending |
| 3 | Flutter Client — 2-Step Ad Reward Flow + SSV Options | 2 | ⏳ Pending |

## Execution Order
Wave 1: Plans 1 + 2 (can run in parallel — DB and Edge Function are independent)
Wave 2: Plan 3 (depends on both Plan 1 and Plan 2)

## Next Steps
1. `/execute reward-ad-ssv` — Execute all plans
