---
name: supabase
description: Supabase development patterns for database queries, RLS policies, Auth, Edge Functions, Storage. Use when writing Supabase SQL, Dart/JS client code, or debugging Supabase issues.
version: 1.1.0
---

# Supabase Development Skill

Practical patterns for Supabase development. Use Supabase MCP tools (`execute_sql`, `apply_migration`, `search_docs`, `get_logs`, `get_advisors`) alongside these references.

## Quick Reference

| Task | Reference | MCP Tool |
|------|-----------|----------|
| CRUD queries, filters, joins | [database-and-rls.md](references/database-and-rls.md) | `execute_sql` |
| Basic RLS policies | [database-and-rls.md](references/database-and-rls.md) | `apply_migration` |
| Advanced RLS (RBAC, team, MFA) | [rls-advanced-patterns.md](references/rls-advanced-patterns.md) | `apply_migration` |
| PostgreSQL functions (RPC) | [postgres-functions.md](references/postgres-functions.md) | `execute_sql` |
| Email/OAuth/admin ops | [auth.md](references/auth.md) | `get_logs(service="auth")` |
| MFA, sessions, identity linking | [auth-mfa-and-sessions.md](references/auth-mfa-and-sessions.md) | `get_logs(service="auth")` |
| Edge Functions basics | [edge-functions.md](references/edge-functions.md) | `deploy_edge_function` |
| Edge Functions advanced patterns | [edge-functions-advanced.md](references/edge-functions-advanced.md) | `deploy_edge_function` |
| Upload/download, signed URLs | [storage.md](references/storage.md) | `list_storage_buckets` |
| Debug RLS, perf, error codes | [troubleshooting.md](references/troubleshooting.md) | `get_advisors` |

## Core Patterns

### RLS Policy Template

```sql
CREATE POLICY "Users own data"
ON public.table_name FOR ALL
TO authenticated
USING ((SELECT auth.uid()) = user_id)
WITH CHECK ((SELECT auth.uid()) = user_id);
```

Wrap `auth.uid()` in `SELECT` for performance. Add index on `user_id`.

### Supabase Client (Dart)

```dart
// User context (respects RLS)
final response = await supabase.from('table').select().eq('id', id);

// Admin context (bypasses RLS) - server-side only
final admin = SupabaseClient(url, serviceRoleKey);
```

### Edge Function Structure

```typescript
import "jsr:@supabase/functions-js/edge-runtime.d.ts"
Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  const supabase = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_ANON_KEY')!, {
    global: { headers: { Authorization: req.headers.get('Authorization')! } }
  })
  return new Response(JSON.stringify({ data }), { headers: { 'Content-Type': 'application/json' } })
})
```

### Storage Upload Pattern

```dart
await supabase.storage.from('bucket').upload('$userId/$fileName', file);
final url = supabase.storage.from('bucket').getPublicUrl('$userId/$fileName');
```

## Security Checklist

- Enable RLS on ALL tables: `ALTER TABLE x ENABLE ROW LEVEL SECURITY;`
- Never expose `SERVICE_ROLE_KEY` client-side
- Use `getUser()` (server-validated) over `getSession()` (local only)
- Store roles in `app_metadata` (not `user_metadata` which is user-editable)
- Index columns used in RLS policies

## Debug Quick Start

1. Empty data? Check RLS: `SELECT * FROM pg_policies WHERE tablename = 'x';`
2. Auth error? Check logs: `get_logs(service="auth")`
3. Slow query? Run: `EXPLAIN ANALYZE SELECT ...`
4. Edge Function 500? Check: `get_logs(service="edge-function")`

See [troubleshooting.md](references/troubleshooting.md) for error codes and detailed patterns.
