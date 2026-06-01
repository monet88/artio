# Harness

Artio uses Harness to keep prompts, docs, proof, and durable records aligned
with the live codebase.

The app is what users touch. The harness is what agents touch.

## Mental Model

```text
Human intent
  -> feature intake
  -> story or maintenance packet
  -> agent work loop
  -> product delta
  -> validation proof
  -> harness delta
  -> next intent
```

Every task can produce two kinds of output:

1. Product delta: app code, tests, API shape, data model, or product docs.
2. Harness delta: docs, templates, validation expectations, backlog items, or
   decision records that make the next task safer.

## Surface Map

Artio has three active surfaces:

- Main app: `/` — Flutter app for Android, iOS, Web, and Windows.
- Admin app: `/admin` — Flutter Web admin dashboard.
- Backend: `/supabase` — Postgres schema, migrations, and Edge Functions.

## What To Read First

Before changing anything, read:

- `README.md`
- `docs/HARNESS.md`
- `docs/FEATURE_INTAKE.md`
- `docs/ARCHITECTURE.md`
- `docs/CONTEXT_RULES.md`
- `scripts/bin/harness-cli query matrix`

If the matrix query fails because `harness.db` has not been initialized yet,
run `scripts/bin/harness-cli init` first, then retry the query.

## Harness Scope

Harness currently covers:

- Intake classification and risk lanes.
- Story packets and candidate backlogs.
- Decisions and tradeoff records.
- Validation expectations and test matrix rows.
- Trace recording and friction capture.
- Harness backlog and maturity tracking.

## Source Of Truth Hierarchy

```text
docs/project-overview-pdr.md
  current product scope and constraints

docs/codebase-summary.md
  repo layout, surfaces, tests, and config snapshot

docs/system-architecture.md
  runtime and data-flow architecture

docs/code-standards.md
  code, security, and testing norms

docs/project-roadmap.md
  active priorities and sequencing

docs/design-guidelines.md
  design intent for main and admin surfaces

docs/deployment-guide.md
  local and release deployment notes

docs/project-changelog.md
  documentation milestones and notable updates

docs/decisions/*
  durable tradeoffs and why they were made

docs/stories/*
  story-sized work packets and backlog slices

docs/HARNESS_BACKLOG.md
  harness improvements that should not be lost

docs/TEST_MATRIX.md
  contract-to-proof mapping
```

## Intake Flow

```text
User prompt
  -> classify input type
  -> restate as work item
  -> find affected docs and stories
  -> run risk checklist
  -> choose lane: tiny, normal, or high-risk
```

## Input Types

| Type | Use when | Typical artifact |
| --- | --- | --- |
| New spec | Turning a user-provided spec into working docs | Product docs, candidate epics, decisions |
| Spec slice | Implementing a selected behavior from the spec | Story packet |
| Change request | Fixing or refining accepted behavior | Story packet or direct patch |
| New initiative | Adding a larger area that needs multiple stories | Initiative notes plus story packets |
| Maintenance request | Changing technical, operational, or dependency behavior | Story packet, validation report, or decision |
| Harness improvement | Improving how humans and agents collaborate | Direct docs update or backlog item |

Do not keep extending a monolithic spec after intake. Use product docs, story
packets, decisions, and initiative notes as the living surface.

## Lanes

### Tiny

Use for low-risk docs, copy, naming, or narrow edits.

Requirements:

- Patch directly.
- Keep affected docs current.
- Run available quick checks.
- Update the harness only if friction was found.

### Normal

Use for story-sized behavior with bounded blast radius.

Requirements:

- Create or update one story file from `docs/templates/story.md`.
- Link relevant product docs.
- Add or update validation expectations.
- Implement the smallest vertical slice when implementation exists.
- Record or update proof status with `scripts/bin/harness-cli story add` and
  `scripts/bin/harness-cli story update` when the durable layer is available.

### High-Risk

Use when the work can affect security, data, scope, contracts, or multiple
roles/platforms.

Requirements:

- Create a story folder using `docs/templates/high-risk-story/`.
- Fill in `execplan.md`, `overview.md`, `design.md`, and `validation.md`.
- Ask for human confirmation before implementation if direction is ambiguous.
- Record a decision when behavior or architecture changes meaningfully.

## Risk Checklist

Mark one flag for each item that applies:

| Risk flag | Applies when the work touches |
| --- | --- |
| Auth | login, logout, sessions, JWT, password, refresh token |
| Authorization | roles, permissions, tenant or company scope |
| Data model | schema, migrations, uniqueness, deletion, retention |
| Audit/security | audit logs, privacy, sensitive data, access logs |
| External systems | email, payments, cloud services, provider SDKs, queues, webhooks |
| Public contracts | API shape, response envelope, client-visible behavior |
| Cross-platform | desktop/mobile/browser split, native shell behavior, deep links |
| Existing behavior | already implemented or test-covered behavior changes |
| Weak proof | unclear or missing tests around the affected area |
| Multi-domain | more than one product domain changes at once |

## Classification

```text
0-1 flags:
  tiny or normal, based on code impact

2-3 flags:
  normal with stronger validation

4+ flags:
  high-risk

Any hard gate:
  high-risk unless the human explicitly narrows scope
```

Hard gates:

- Auth.
- Authorization.
- Data loss or migration.
- Audit/security.
- External provider behavior.
- Removing or weakening validation requirements.

## Output

At the end of intake, the agent should be able to say:

```text
Lane: normal
Reason: touches authorization, API contract, and audit behavior.
Docs: permissions, account-settings, audit-log.
Story: docs/stories/epics/E02-access-control/US-014-manager-updates-role.md.
Validation: unit, integration, E2E.
```
