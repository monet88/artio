# Documentation Map

This directory contains the project harness plus the current product docs that
reflect the live Artio codebase.

## Main Files

- `HARNESS.md`: how humans and agents collaborate.
- `FEATURE_INTAKE.md`: how prompts become tiny, normal, or high-risk work.
- `ARCHITECTURE.md`: architecture discovery and boundary rules.
- `TEST_MATRIX.md`: proof map for the current product contract.
- `TRACE_SPEC.md`: trace shape and scoring rules.
- `GLOSSARY.md`: shared terms.
- `project-overview-pdr.md`: product overview and current scope.
- `codebase-summary.md`: repo structure and current codebase summary.
- `code-standards.md`: repo-specific coding, testing, and security standards.
- `system-architecture.md`: runtime and data-flow architecture.
- `project-roadmap.md`: current roadmap and sequencing.
- `design-guidelines.md`: UI and design-system guidance.
- `deployment-guide.md`: local and release deployment notes.
- `project-changelog.md`: notable documentation and product changes.
- `HARNESS_BACKLOG.md`: harness improvement backlog.
- `HARNESS_COMPONENTS.md`: harness responsibility coverage map.
- `HARNESS_MATURITY.md`: maturity ladder for the harness surface.
- `stories/backlog.md`: candidate product epics.
- `decisions/`: durable tradeoff records.
- `product/`: product contract docs when present.

## Folders

- `product/`: current product truth and domain docs.
- `stories/`: feature packets and backlog.
- `decisions/`: durable decisions and tradeoffs.
- `demo/`: concrete walkthroughs that show how the harness transforms input
  into agent-ready work.
- `templates/`: reusable spec-intake, story, plan, decision, and validation
  formats.
- `admin-templates/`: admin-specific prompt and workflow templates.
- `kie-api/`: model/provider notes and integration references.

## Current State

Artio already has a live Flutter main app, a separate admin surface, and
Supabase Edge Functions. These docs describe the current implementation and the
harness workflow that keeps them aligned.
