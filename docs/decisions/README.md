# Decisions

Decision records explain why important product, architecture, or harness choices
were made.

Use `docs/templates/decision.md` when adding a new decision.

## Current Decision Set

| Decision | Status | Why it matters |
| --- | --- | --- |
| `0001-harness-first-development.md` | Accepted | The repo uses Harness as the operating model before product work. |
| `0002-post-spec-product-lifecycle.md` | Superseded | The initial spec is historical input, not the living product plan. |
| `0003-generic-spec-intake-harness.md` | Accepted | The harness should stay reusable for new specs and initiatives. |
| `0004-sqlite-durable-layer.md` | Accepted | Durable Harness state lives in SQLite plus `scripts/bin/harness-cli`. |
| `0005-prebuilt-rust-harness-cli.md` | Accepted, amended | The CLI is a prebuilt repository-local binary, not a shell wrapper. |

## Add A Decision When

- A locked technical choice changes.
- A product rule changes meaningfully.
- A validation requirement is added, removed, or weakened.
- A high-risk feature chooses one design over another.
- The source-of-truth hierarchy changes.

## Tradeoff Themes In This Repo

- Main app and admin app share Supabase but keep separate runtime entrypoints.
- Credits and subscription state are server-authoritative.
- Client model costs must stay aligned with server model config.
- Harness docs stay small and operational, while decisions capture the durable "why".

