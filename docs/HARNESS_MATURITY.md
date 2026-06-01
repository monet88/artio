# Harness Maturity Ladder

This ladder describes how the Artio Harness surface progresses from static
policy docs to measurable self-improvement.

The levels are intentionally verifiable. A level is achieved only when its
criteria can be inspected in repository files, durable Harness records, or
benchmark output.

## Levels

### H0 - Bare Environment

The model operates with no repository harness. It receives a prompt and may
produce a patch, but the repo does not tell it how to classify, validate, or
record work.

Criteria:

- No `AGENTS.md` harness block exists.
- No feature intake policy exists.
- No story, decision, validation, or trace artifact exists.

Current status:

- Passed. Artio is beyond H0.

### H1 - Scaffolding And Policy

The repository contains static operating instructions, templates, risk lanes,
and source-of-truth rules. Agents can follow a documented workflow, but durable
state may still be manual or incomplete.

Criteria:

- `AGENTS.md` points agents to the Harness operating docs.
- `docs/HARNESS.md`, `docs/FEATURE_INTAKE.md`, and `docs/ARCHITECTURE.md`
  exist.
- Story, decision, and validation templates exist under `docs/templates/`.
- `docs/TEST_MATRIX.md` defines proof columns and status meanings.

Current status:

- Achieved. The policy layer exists and is used by current instructions.

### H2 - Durable State And Observability

The repository has structured operational records and explicit observation
rules. Agents can record what happened, connect work to stories, and write
traces with predictable depth.

Criteria:

- `scripts/bin/harness-cli` can record intake, story, decision, backlog, and
  trace data in `harness.db`.
- `scripts/schema/001-init.sql` defines durable tables for intake, story,
  decision, backlog, and trace records.
- `docs/HARNESS_COMPONENTS.md` maps files and responsibilities.
- `docs/HARNESS_MATURITY.md` defines H0-H5 with measurable criteria.
- `docs/TRACE_SPEC.md` defines trace fields, quality tiers, and friction
  capture.
- `docs/CONTEXT_RULES.md` defines phase-by-lane context rules.

Current status:

- Partial in a fresh clone until the local durable database is initialized and
  imported from markdown state.
- The repo has the docs, schema, and CLI entrypoint, but `query matrix` may need
  `scripts/bin/harness-cli init` followed by `scripts/bin/harness-cli import
  brownfield` before the first use.

### H3 - Active Observability And Evolution

The harness can evaluate its own operational data and turn repeated failures
into prioritized improvements.

Criteria:

- Trace quality can be scored by a repeatable command or benchmark step.
- Harness friction can be grouped by component from `docs/HARNESS_COMPONENTS.md`.
- Backlog items include predicted impact and actual outcome after completion.
- Benchmark comparison output identifies which harness responsibility moved or
  regressed.

Current status:

- Partially achieved. Trace scoring and the backlog outcome loop are documented,
  but the repo still lacks component-level benchmark comparison output.

### H4 - Automated Verification

The harness can run or orchestrate proof checks consistently and can reject or
flag incomplete work before the final response.

Criteria:

- A documented verification command or protocol runs the expected checks for a
  selected story and lane.
- Story proof columns are updated from command output or a repeatable report.
- Decision verification commands can be run in batch.
- Missing validation evidence is surfaced before a task is marked implemented.

Current status:

- Not achieved. Current verification is still manual through commands and docs.

### H5 - Self-Improving Harness

The harness can use traces, benchmark results, and backlog outcomes to propose
or apply safe improvements to itself.

Criteria:

- Repeated friction patterns are summarized into proposed harness changes.
- Proposed changes include predicted impact, risk, validation plan, and rollback
  criteria.
- Completed changes compare predicted impact with actual benchmark or trace
  outcomes.
- High-risk harness changes pause for human confirmation before changing source
  hierarchy, architecture direction, or validation requirements.

Current status:

- Not achieved. The repo has the policy surface, but not the automated evolution
  loop.

## Current Assessment

| Level | Status | Evidence |
| --- | --- | --- |
| H0 | Passed | Harness docs, templates, and durable record docs exist. |
| H1 | Achieved | `AGENTS.md`, `docs/HARNESS.md`, `docs/FEATURE_INTAKE.md`, `docs/ARCHITECTURE.md`, `docs/templates/*`, and `docs/TEST_MATRIX.md` exist. |
| H2 | Partial | `scripts/bin/harness-cli`, `scripts/schema/001-init.sql`, `scripts/bin/harness-cli import brownfield`, `docs/HARNESS_COMPONENTS.md`, `docs/TRACE_SPEC.md`, and `docs/CONTEXT_RULES.md` define the durable surface, but a fresh clone still needs init and import. |
| H3 | Partial | `scripts/bin/harness-cli score-trace`, `docs/HARNESS_BACKLOG.md`, and `docs/HARNESS_COMPONENTS.md` define the loop, but benchmark comparison output is still missing. |
| H4 | Not achieved | No generic verification runner or batch proof updater exists. |
| H5 | Not achieved | No self-improvement protocol or automated evolution loop exists. |

## Responsibility Activation

| Responsibility | H0 | H1 | H2 | H3 | H4 | H5 |
| --- | --- | --- | --- | --- | --- | --- |
| Task specification | Missing | Covered | Covered | Covered | Covered | Covered |
| Context selection | Missing | Partial | Covered | Covered | Covered | Covered |
| Tool access | Missing | Partial | Partial | Partial | Covered | Covered |
| Project memory | Missing | Covered | Covered | Covered | Covered | Covered |
| Task state | Missing | Partial | Covered | Covered | Covered | Covered |
| Observability | Missing | Missing | Partial | Covered | Covered | Covered |
| Failure attribution | Missing | Missing | Partial | Covered | Covered | Covered |
| Verification | Missing | Partial | Partial | Partial | Covered | Covered |
| Permissions | Missing | Partial | Partial | Partial | Covered | Covered |
| Entropy auditing | Missing | Missing | Partial | Covered | Covered | Covered |
| Intervention recording | Missing | Partial | Partial | Covered | Covered | Covered |

## Phase 3 Interpretation

Phase 3 starts the H2 to H3 transition. It claims active trace scoring and a
documented improvement feedback loop, but it does not claim full H3 because
benchmark comparison and component-level regression attribution are still
outside the repo's current surface.
