# Harness Components

This taxonomy maps the current Artio repository to the Harness responsibilities
used by the intake, trace, backlog, and maturity docs.

Status values:

- **Covered**: the repository has an explicit file, command, or record for this
  responsibility.
- **Partial**: the repository has some support, but the support is incomplete,
  manual, or not yet measured.
- **Missing**: no meaningful support exists yet.

## Responsibility Map

| Responsibility | Status | Current Evidence | Main Gap |
| --- | --- | --- | --- |
| Task specification | Covered | `AGENTS.md`, `docs/HARNESS.md`, `docs/FEATURE_INTAKE.md`, `docs/project-overview-pdr.md`, `docs/stories/backlog.md` | Keep story packets synchronized with future product docs. |
| Context selection | Covered | `AGENTS.md`, `docs/CONTEXT_RULES.md`, `docs/ARCHITECTURE.md`, `docs/HARNESS.md`, `docs/codebase-summary.md` | Future automation could measure over-reading. |
| Project memory | Covered | `docs/decisions/*`, `docs/project-changelog.md`, `docs/HARNESS_BACKLOG.md`, session memory logs | Add staleness checks and summaries for old traces. |
| Task state | Partial | `docs/TEST_MATRIX.md`, `docs/stories/backlog.md`, `scripts/bin/harness-cli query matrix` | Keep proof state and story state in sync after each change. |
| Observability | Partial | `docs/TRACE_SPEC.md`, `scripts/bin/harness-cli score-trace`, `scripts/bin/harness-cli query backlog` | No dashboard or benchmark ingestion yet. |
| Verification | Partial | `flutter test`, `flutter analyze`, `supabase functions`, `docs/TEST_MATRIX.md` | No generic verification runner or batch proof updater. |
| Permissions | Partial | `AGENTS.md`, `docs/HARNESS.md`, `docs/FEATURE_INTAKE.md`, `docs/ARCHITECTURE.md` | Permissions are instruction-level only, not enforced by tooling. |
| Entropy auditing | Partial | `docs/HARNESS_BACKLOG.md`, `docs/project-roadmap.md`, `docs/project-changelog.md` | No drift detector or entropy score exists yet. |
| Intervention recording | Partial | `docs/TRACE_SPEC.md`, session memory logs, `docs/decisions/*` | Human interventions are not separated from normal agent actions. |

## Notes

- The harness surface is real, but the durable database may still need to be
  initialized and imported from markdown state in a fresh clone.
- Treat this file as a quick coverage map, not a full benchmark report.
