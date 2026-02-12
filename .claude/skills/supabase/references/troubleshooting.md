# Supabase Troubleshooting

## Quick Diagnosis

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Empty data returned | RLS blocking | Check policies: `SELECT * FROM pg_policies WHERE tablename='x'` |
| "Not authorized" | Missing/invalid token | Verify `Authorization` header, check token expiry |
| "JWT expired" | Token not refreshed | Call `supabase.auth.refreshSession()` |
| Slow queries | Missing indexes / RLS subqueries | Run `EXPLAIN ANALYZE`, wrap `auth.uid()` in `SELECT` |
| Connection refused | Wrong URL / service down | Verify `SUPABASE_URL`, check project status |
| "Duplicate key" | Unique constraint violation | Use `.upsert()` instead of `.insert()` |
| Function timeout | Cold start / heavy computation | Optimize code, check CPU limit (2s) |

## RLS Debugging

```sql
-- List all policies on a table
SELECT policyname, cmd, qual, with_check FROM pg_policies WHERE tablename = 'posts';

-- Test as specific user
SET request.jwt.claims = '{"sub":"user-uuid-here","role":"authenticated"}';
SELECT * FROM posts;  -- Should return only user's rows
RESET request.jwt.claims;

-- Check if RLS is enabled
SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';
```

### RLS Performance Fix

```sql
-- SLOW: auth.uid() re-evaluated per row
CREATE POLICY "slow" ON posts FOR SELECT USING (auth.uid() = user_id);

-- FAST: subselect evaluated once
CREATE POLICY "fast" ON posts FOR SELECT USING ((SELECT auth.uid()) = user_id);

-- Add index
CREATE INDEX idx_posts_user_id ON posts(user_id);
```

## Auth Debugging

```javascript
// Force token refresh
const { data, error } = await supabase.auth.refreshSession()

// Validate user server-side (don't trust getSession)
const { data: { user } } = await supabase.auth.getUser()

// Check auth logs via MCP
// get_logs(service="auth")
```

Common auth issues:
- Email not confirmed → `await supabase.auth.resend({ type: 'signup', email })`
- Case-sensitive email → normalize: `email.trim().toLowerCase()`
- Session lost on refresh → check `persistSession` config

## Database Debugging

```javascript
// Duplicate key → use upsert
const { data } = await supabase.from('users').upsert({ id: 1, name: 'Updated' }).select()

// Foreign key violation → verify parent record exists first
const { data: parent } = await supabase.from('users').select('id').eq('id', userId).single()
```

## Edge Function Debugging

```typescript
// Always wrap in try-catch
Deno.serve(async (req) => {
  try {
    // ... logic
  } catch (error) {
    console.error('Function error:', error)  // appears in logs
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})
```

- CPU limit: 2s, wall clock: 150s (Pro: 400s)
- Check secrets: `supabase secrets list`
- Check logs: `get_logs(service="edge-function")`

## Performance Optimization

```sql
-- Analyze query plan
EXPLAIN ANALYZE SELECT * FROM posts WHERE user_id = 'uuid-here';

-- Add missing indexes
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- Check cache hit ratio (should be >99%)
SELECT schemaname, relname,
  round(heap_blks_hit::numeric / NULLIF(heap_blks_hit + heap_blks_read, 0) * 100, 2) AS cache_hit_ratio
FROM pg_statio_user_tables ORDER BY cache_hit_ratio ASC;

-- Check unused indexes
SELECT indexrelid::regclass AS index, relid::regclass AS table, idx_scan
FROM pg_stat_user_indexes WHERE idx_scan = 0 AND indexrelid::regclass::text NOT LIKE '%pkey%';
```

## Error Code Reference

| Code | Meaning | Fix |
|------|---------|-----|
| PGRST301 | JWT expired | Refresh token |
| PGRST204 | Column not found | Check column name |
| 23505 | Unique violation | Use upsert |
| 23503 | Foreign key violation | Check parent exists |
| 42501 | Insufficient privilege | Check RLS policies |
| 42P01 | Table not found | Check schema + table name |
