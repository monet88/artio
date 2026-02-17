# Testing Requirements

## Coverage Target: 80%+

## Test Types

1. **Unit Tests** — Individual functions, utilities, view models, repositories
2. **Widget Tests** — UI components with `mocktail` mocks
3. **Integration Tests** — E2E flows (require real Supabase via `.env.test`)

## TDD Workflow

1. Write test first (RED) — it should FAIL
2. Write minimal implementation (GREEN) — it should PASS
3. Refactor (IMPROVE)
4. Verify coverage

## Rules

- Test structure mirrors `lib/` → `test/`
- Use `mocktail` (primary) for mocking, `mockito` when codegen needed
- Test fixtures in `test/core/fixtures/`
- **DO NOT** use fake data or mocks just to pass the build
- **DO NOT** ignore failing tests — fix implementation, not tests (unless tests are wrong)
- Always fix failing tests before marking work complete
