# Git Workflow

## Commit Messages

Format: `<type>: <description>`

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`

Rules:
- Clean, professional messages — no AI references
- Keep commits focused on actual code changes
- **DO NOT** commit confidential info (`.env`, API keys, credentials)

## Pre-Commit / Pre-Push

- Run `flutter analyze` before commit
- Run `flutter test` before push — DO NOT ignore failing tests
- Verify no secrets in staged files

## Pull Requests

When creating PRs (use GitHub MCP tools):
1. Analyze full commit history (`git diff base...HEAD`)
2. Write comprehensive PR description
3. Include test coverage summary
4. Push with `-u` flag if new branch

## GitHub Operations — Tool Priority

For any GitHub task (comment, review, PR, issue), use tools in this order:

1. **GitHub MCP** (`github-mcp-server`) — preferred, fast, no auth issues
2. **`gh` CLI** — fallback when MCP lacks the specific tool (e.g., posting PR comments)
3. **Browser** — last resort only; never use if CLI or MCP can do the job

**Never open the browser for GitHub tasks without first trying MCP and `gh` CLI.**

## Feature Development

1. Create feature branch from `master`
2. Implement with surgical, focused changes
3. Test thoroughly
4. Commit with conventional format
5. Create PR via GitHub MCP tools
