# Anti-Patterns to Avoid

### ❌ Vague Tasks
```xml
<task type="auto">
  <name>Add authentication</name>
  <action>Implement auth</action>
  <verify>???</verify>
</task>
```

### ✅ Specific Tasks
```xml
<task type="auto">
  <name>Create login endpoint with JWT</name>
  <files>src/app/api/auth/login/route.ts</files>
  <action>
    POST endpoint accepting {email, password}.
    Query User by email, compare password with bcrypt.
    On match: create JWT with jose, set httpOnly cookie, return 200.
    On mismatch: return 401.
  </action>
  <verify>curl -X POST localhost:3000/api/auth/login returns 200 + Set-Cookie</verify>
  <done>Valid creds → 200 + cookie. Invalid → 401.</done>
</task>
```

### ❌ Reflexive Chaining
```yaml
# Bad: Every plan refs previous
context:
  - .gsd/phases/1/01-SUMMARY.md  # Plan 2 refs 1
  - .gsd/phases/1/02-SUMMARY.md  # Plan 3 refs 2
```

### ✅ Minimal Context
```yaml
# Good: Only ref when truly needed
context:
  - .gsd/SPEC.md
  - src/types.ts  # Actually needed
```

---
