# Task Anatomy

Every task has four required fields:

### `<files>`
Exact file paths created or modified.
- ✅ Good: `src/app/api/auth/login/route.ts`, `prisma/schema.prisma`
- ❌ Bad: "the auth files", "relevant components"

### `<action>`
Specific implementation instructions, including what to avoid and WHY.
- ✅ Good: "Create POST endpoint accepting {email, password}, validates using bcrypt against User table, returns JWT in httpOnly cookie with 15-min expiry. Use jose library (not jsonwebtoken - CommonJS issues with Edge runtime)."
- ❌ Bad: "Add authentication", "Make login work"

### `<verify>`
How to prove the task is complete.
- ✅ Good: `npm test` passes, `curl -X POST /api/auth/login` returns 200 with Set-Cookie header
- ❌ Bad: "It works", "Looks good"

### `<done>`
Acceptance criteria — measurable state of completion.
- ✅ Good: "Valid credentials return 200 + JWT cookie, invalid credentials return 401"
- ❌ Bad: "Authentication is complete"

---
