# File Summary: src/auth/login.ts

**Purpose:** Handles user login via email/password
**Key functions:**
- handleLogin(req, res) → Validates credentials, returns JWT
- validateCredentials(email, password) → Checks against DB
**Dependencies:** bcrypt, jose, database
**Tokens saved:** ~400 (95 lines not reloaded)
```

**Use instead of:** Re-reading the full file

---

### Strategy 2: Outline Mode

**When:** You need to understand a file's structure but not implementation details.

**How:**
```markdown