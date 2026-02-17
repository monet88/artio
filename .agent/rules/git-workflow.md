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

## Feature Development

1. Create feature branch from `master`
2. Implement with surgical, focused changes
3. Test thoroughly
4. Commit with conventional format
5. Create PR via GitHub MCP tools
