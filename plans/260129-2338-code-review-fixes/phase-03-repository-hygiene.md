# Phase 03: Repository Hygiene

## Parallelization Info

| Property | Value |
|----------|-------|
| Group | B (Cleanup) |
| Can Run With | Phase 04 |
| Blocked By | Group A (Phases 01, 02) |
| Blocks | Group C (Phases 05-08) |

## File Ownership (Exclusive)

- `.gitignore` (add pattern)
- `repomix-output.xml` (DELETE)
- `supabase/migrations/20260128094706_create_admin_user.sql`

## Priority: HIGH

**Issues**:
1. `repomix-output.xml` - Large generated file shouldn't be in repo
2. SQL migration contains hardcoded password for admin user

## Implementation Steps

### Step 1: Delete `repomix-output.xml`

```bash
git rm repomix-output.xml
```

### Step 2: Add to `.gitignore`

Add after line 159 (`.osgrep`):
```gitignore
# Repomix output
repomix-output.xml
repomix-output.txt
repomix-output.md
```

### Step 3: Fix SQL migration password

**File**: `supabase/migrations/20260128094706_create_admin_user.sql`

**Current** (if contains hardcoded password):
```sql
-- Example of what might be there
INSERT INTO auth.users (email, encrypted_password, ...)
VALUES ('admin@example.com', 'hardcoded_hash', ...);
```

**Fix**: Remove password from migration comment:

Replace any password-containing INSERT with documentation comment:
```sql
-- Admin user created via Supabase Dashboard or CLI
-- Password set via: supabase auth admin update-user --password $ADMIN_PASSWORD
-- DO NOT hardcode passwords in migrations
```

This approach is simpler and follows Supabase best practices for user management.

### Step 4: Verify no other sensitive data

```bash
# Search for potential secrets
grep -r "password" supabase/migrations/ --include="*.sql"
grep -r "secret" supabase/migrations/ --include="*.sql"
grep -r "api_key" supabase/migrations/ --include="*.sql"
```

## Success Criteria

- [ ] `repomix-output.xml` deleted from repository
- [ ] `.gitignore` updated to prevent future repomix commits
- [ ] No hardcoded passwords in SQL migrations
- [ ] `git status` shows clean after changes committed

## Conflict Prevention

- Only this phase modifies `.gitignore`
- Only this phase touches migration files
- `repomix-output.xml` not used by any other phase

## Security Considerations

- Database credentials should NEVER be in migrations
- Use Supabase Dashboard or CLI for user management
- Consider adding pre-commit hook to scan for secrets
