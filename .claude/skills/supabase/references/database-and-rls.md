# Supabase Database & RLS

## CRUD Operations

```javascript
// Select with filters
const { data } = await supabase.from('posts').select('id, title, users(name)')
  .eq('status', 'published').order('created_at', { ascending: false }).limit(10)

// Insert
const { data } = await supabase.from('posts').insert({ title: 'New', user_id: uid }).select()

// Upsert
const { data } = await supabase.from('posts').upsert({ id: 1, title: 'Updated' }).select()

// Update
const { data } = await supabase.from('posts').update({ title: 'Updated' }).eq('id', 1).select()

// Delete
const { error } = await supabase.from('posts').delete().eq('id', 1)
```

## Filter Operators

| Operator | Usage | SQL Equivalent |
|----------|-------|----------------|
| `.eq()` | `.eq('col', 'val')` | `= 'val'` |
| `.neq()` | `.neq('col', 'val')` | `!= 'val'` |
| `.gt/.gte` | `.gt('col', 10)` | `> 10` |
| `.lt/.lte` | `.lt('col', 10)` | `< 10` |
| `.like` | `.like('name', '%John%')` | `LIKE '%John%'` |
| `.ilike` | `.ilike('name', '%john%')` | `ILIKE '%john%'` |
| `.in` | `.in('status', ['a','b'])` | `IN ('a','b')` |
| `.is` | `.is('deleted_at', null)` | `IS NULL` |
| `.or` | `.or('status.eq.a,status.eq.b')` | `OR` |
| `.contains` | `.contains('tags', ['x'])` | `@>` |

## Relations (Joins)

```javascript
// One-to-many
const { data } = await supabase.from('users').select('id, name, posts(id, title)')

// Inner join (only users WITH posts)
const { data } = await supabase.from('users').select('id, name, posts!inner(id, title)')

// Many-to-many (through junction)
const { data } = await supabase.from('posts').select('id, title, post_tags(tags(id, name))')
```

## RLS Policies

```sql
-- Enable RLS
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- SELECT: users read own data
CREATE POLICY "Users read own" ON public.posts FOR SELECT
TO authenticated USING ((SELECT auth.uid()) = user_id);

-- INSERT: users create own data
CREATE POLICY "Users insert own" ON public.posts FOR INSERT
TO authenticated WITH CHECK ((SELECT auth.uid()) = user_id);

-- UPDATE: users update own data
CREATE POLICY "Users update own" ON public.posts FOR UPDATE
TO authenticated
USING ((SELECT auth.uid()) = user_id)
WITH CHECK ((SELECT auth.uid()) = user_id);

-- DELETE: users delete own data
CREATE POLICY "Users delete own" ON public.posts FOR DELETE
TO authenticated USING ((SELECT auth.uid()) = user_id);

-- Public read (no auth required)
CREATE POLICY "Public read" ON public.posts FOR SELECT TO anon USING (true);

-- Admin access via app_metadata
CREATE POLICY "Admin all" ON public.posts FOR ALL
TO authenticated USING (auth.jwt()->'app_metadata'->>'role' = 'admin');
```

### RLS Performance Tips

- Wrap `auth.uid()` in subselect: `(SELECT auth.uid())` — avoids re-evaluation per row
- Add index on policy columns: `CREATE INDEX idx_posts_user_id ON posts(user_id);`
- Use security definer functions for complex logic

## RPC (Remote Procedure Call)

```sql
CREATE OR REPLACE FUNCTION search_posts(query text)
RETURNS TABLE(id uuid, title text) LANGUAGE sql STABLE AS $$
  SELECT id, title FROM posts WHERE title ILIKE '%' || query || '%' ORDER BY created_at DESC;
$$;
```

```javascript
const { data } = await supabase.rpc('search_posts', { query: 'flutter' })
```

## Auth Helper Functions

| Function | Returns |
|----------|---------|
| `auth.uid()` | Current user UUID |
| `auth.role()` | `anon`, `authenticated`, `service_role` |
| `auth.jwt()` | Full JWT as JSON |
| `auth.jwt()->>'email'` | User email from JWT |
