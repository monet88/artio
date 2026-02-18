---
description: Review a GitHub PR using the code-reviewer skill — fetch diff, analyze, report, optionally comment
---

# /review-pr — PR Review Workflow

Automated PR review using the `code-reviewer` skill with GitHub MCP integration.

## Usage

```
/review-pr <PR_NUMBER> [--comment] [--owner=monet88] [--repo=artio]
```

- `PR_NUMBER` — required, the PR number to review
- `--comment` — optional, if present: post the review report as a PR comment
- `--owner` / `--repo` — optional, defaults to `monet88/artio`

---

## Steps

### 1. Load the code-reviewer skill

Read the skill instructions:

```
view_file .agent/skills/code-reviewer/SKILL.md
```

Load references as needed:
- `.agent/skills/code-reviewer/references/review-checklist.md`
- `.agent/skills/code-reviewer/references/common-issues.md`
- `.agent/skills/code-reviewer/references/report-template.md`

### 2. Fetch PR context

Use **GitHub MCP tools** (not shell commands) to gather PR data:

```
# Get PR details (title, description, base/head branches)
mcp github-mcp-server pull_request_read method=get owner=<OWNER> repo=<REPO> pullNumber=<PR_NUMBER>

# Get the diff
mcp github-mcp-server pull_request_read method=get_diff owner=<OWNER> repo=<REPO> pullNumber=<PR_NUMBER>

# Get changed files list
mcp github-mcp-server pull_request_read method=get_files owner=<OWNER> repo=<REPO> pullNumber=<PR_NUMBER>

# Get existing review comments (to avoid duplicate feedback)
mcp github-mcp-server pull_request_read method=get_review_comments owner=<OWNER> repo=<REPO> pullNumber=<PR_NUMBER>

# Get CI/build status
mcp github-mcp-server pull_request_read method=get_status owner=<OWNER> repo=<REPO> pullNumber=<PR_NUMBER>
```

If GitHub MCP auth fails, fall back to reading PR via `read_url_content` on the PR URL.

### 3. Read changed files locally

For each file in the diff, read the **full current version** locally to understand complete context (not just the diff hunks). Use `view_file` or Serena tools as appropriate.

Priority order for review:
1. Source code files (`lib/`, `src/`)
2. Test files (`test/`)
3. Config files (`pubspec.yaml`, build configs)
4. Documentation (`README.md`, `docs/`)

### 4. Analyze using the review checklist

Walk through each category from the review checklist:

| Category | Key Questions |
|----------|---------------|
| **Design** | Does it fit existing patterns? Right abstraction level? |
| **Logic** | Edge cases handled? Race conditions? Null checks? |
| **Security** | Input validated? Auth checked? Secrets safe? |
| **Performance** | N+1 queries? Memory leaks? Caching needed? |
| **Tests** | Adequate coverage? Edge cases tested? Mocks appropriate? |
| **Naming** | Clear, consistent, intention-revealing? |
| **Error Handling** | Errors caught? Meaningful messages? Logged? |
| **Documentation** | Public APIs documented? Complex logic explained? |

Cross-reference with `references/common-issues.md` for known anti-patterns.

### 5. Generate the review report

Use the report template from `references/report-template.md`. Structure:

```markdown
# Code Review: [PR Title] (#PR_NUMBER)

## Summary
[1-2 sentence overview + overall assessment]

**Verdict**: Approve | Request Changes | Comment
**Files reviewed**: X files, Y lines changed

## Critical Issues (Must Fix)
### 1. [File:Line] Category: Description
- **Current**: what's wrong
- **Suggested**: how to fix
- **Impact**: why it matters

## Major Issues (Should Fix)
...

## Minor Issues (Nice to Have)
...

## Positive Feedback
- ...

## Questions for Author
- ...

## Test Coverage Assessment
- [ ] Happy path tested
- [ ] Error cases tested
- [ ] Edge cases tested
```

### 6. Present to user

Display the full report in the conversation. Ask:

> **Shall I post this review as a comment on PR #X?**

### 7. (Optional) Post comment to PR

If the user confirms (or `--comment` flag was used), post the report to GitHub:

```
mcp github-mcp-server add_issue_comment owner=<OWNER> repo=<REPO> issue_number=<PR_NUMBER> body=<REPORT>
```

---

## Severity Guide

| Severity | Definition | Action |
|----------|------------|--------|
| **Critical** | Security risk, data loss, crashes | Must fix before merge |
| **Major** | Significant perf, maintainability, logic bugs | Should fix before merge |
| **Minor** | Style, naming, small improvements | Nice to have |

## Verdict Guide

| Verdict | When |
|---------|------|
| **Approve** | No critical/major issues, minor suggestions only |
| **Request Changes** | Critical or major issues must be fixed |
| **Comment** | Questions need answers, no blocking issues |

---

## Notes

- Always understand context (PR description, linked issues) before reviewing code
- Don't duplicate feedback that existing review comments already cover
- Praise good patterns — at least one positive comment per review
- For large PRs (>500 lines), focus on critical path first, note that a full review may need follow-up
- If the PR branch exists locally, run `flutter analyze` and tests for empirical validation
