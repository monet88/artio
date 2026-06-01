# Harness Backlog

Use this file when an agent finds a missing Harness capability but should not
change the operating model immediately.

## Items

| Title | Discovered While | Current Pain | Suggested Improvement | Risk | Status | Predicted Impact | Outcome |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Auto-bootstrap durable records | Running `scripts/bin/harness-cli query matrix` in a fresh clone | The matrix query fails until `harness.db` is initialized, which creates first-run friction. | Make bootstrap and seed steps easier to discover or automate during repo setup. | normal | proposed | Fewer first-run failures and less setup confusion. | not yet measured |
| Harness doc freshness check | Updating the docs set from live code | Docs can drift from the current app, admin, and backend behavior if no one checks them after code changes. | Add a lightweight docs freshness checklist or command that compares docs against live surfaces. | normal | proposed | Fewer stale-doc regressions after implementation work. | not yet measured |
| Matrix-to-proof summary | Reviewing proof state across docs and tests | There is no single short summary of which product behaviors are proven, partial, or still planned. | Add a compact report that summarizes `TEST_MATRIX.md`, story status, and trace state together. | normal | proposed | Faster review of current proof coverage. | not yet measured |
| Component-level friction tagging | Reconciling Harness friction with long-running docs work | Friction is captured, but it is not yet grouped by Harness component in a way that makes trends obvious. | Tag friction with component names and surface it in a future report. | normal | proposed | Better root-cause grouping for repeated Harness pain. | not yet measured |

## Template

```md
## Missing Harness Capability

### Title

Short name.

### Discovered While

Task or story that exposed the gap.

### Current Pain

What was hard, repeated, ambiguous, or unsafe?

### Suggested Improvement

What should be added or changed?

### Risk

Tiny, normal, or high-risk.

### Status

proposed | accepted | implemented | rejected
```

## Notes

- Add a backlog item when the fix is out of scope for the current task.
- Keep items short enough to scan quickly.
- Close the loop by recording actual outcomes when a backlog item is implemented.
