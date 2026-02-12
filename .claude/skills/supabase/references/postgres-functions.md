# PostgreSQL Functions (RPC)

## Function Languages

| Language | Use When |
|----------|----------|
| `sql` | Simple queries, single statement |
| `plpgsql` | Complex logic, variables, loops, error handling |

## Return Types

```sql
-- Single value
CREATE FUNCTION get_count() RETURNS integer LANGUAGE sql AS $$
  SELECT COUNT(*)::integer FROM users;
$$;

-- Single row
CREATE FUNCTION get_user(id_param uuid) RETURNS users LANGUAGE sql STABLE AS $$
  SELECT * FROM users WHERE id = id_param LIMIT 1;
$$;

-- Multiple rows (SETOF)
CREATE FUNCTION recent_posts(n integer DEFAULT 10) RETURNS SETOF posts LANGUAGE sql STABLE AS $$
  SELECT * FROM posts ORDER BY created_at DESC LIMIT n;
$$;

-- Custom table
CREATE FUNCTION search(q text) RETURNS TABLE(id uuid, title text, score real)
LANGUAGE sql STABLE AS $$
  SELECT id, title, similarity(title, q) AS score FROM posts
  WHERE title ILIKE '%' || q || '%' ORDER BY score DESC;
$$;

-- JSON
CREATE FUNCTION user_summary(uid uuid) RETURNS json LANGUAGE plpgsql AS $$
DECLARE result json;
BEGIN
  SELECT json_build_object(
    'user', row_to_json(u),
    'posts', (SELECT COUNT(*) FROM posts WHERE author_id = uid)
  ) INTO result FROM users u WHERE u.id = uid;
  RETURN result;
END; $$;
```

## Volatility

| Keyword | Meaning | Use For |
|---------|---------|---------|
| `STABLE` | Read-only, same result in same transaction | SELECT queries |
| `VOLATILE` | Has side effects (default) | INSERT/UPDATE/DELETE |
| `IMMUTABLE` | Always same output for same input | Pure calculations |

## Security

```sql
-- SECURITY INVOKER (default): runs with caller's permissions, respects RLS
CREATE FUNCTION my_posts() RETURNS SETOF posts LANGUAGE sql STABLE SECURITY INVOKER AS $$
  SELECT * FROM posts WHERE author_id = auth.uid();
$$;

-- SECURITY DEFINER: runs with owner's permissions, BYPASSES RLS
-- Always set search_path!
CREATE FUNCTION admin_all_users() RETURNS SETOF users
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public AS $$
  SELECT * FROM users;
$$;
```

## Common Patterns

### Pagination
```sql
CREATE FUNCTION paginated_posts(page_num int DEFAULT 1, page_size int DEFAULT 10)
RETURNS TABLE(id uuid, title text, created_at timestamptz, total bigint)
LANGUAGE sql STABLE AS $$
  SELECT id, title, created_at, COUNT(*) OVER() AS total
  FROM posts ORDER BY created_at DESC
  LIMIT page_size OFFSET (page_num - 1) * page_size;
$$;
```

### Full-Text Search
```sql
CREATE FUNCTION fts_posts(q text) RETURNS SETOF posts LANGUAGE sql STABLE AS $$
  SELECT * FROM posts
  WHERE to_tsvector('english', title || ' ' || content) @@ plainto_tsquery('english', q)
  ORDER BY ts_rank(to_tsvector('english', title || ' ' || content), plainto_tsquery('english', q)) DESC;
$$;
```

### Batch Operations
```sql
CREATE FUNCTION batch_update(ids uuid[], new_status text) RETURNS integer LANGUAGE plpgsql AS $$
DECLARE n integer;
BEGIN
  UPDATE posts SET status = new_status WHERE id = ANY(ids);
  GET DIAGNOSTICS n = ROW_COUNT;
  RETURN n;
END; $$;
```

### Soft Delete
```sql
CREATE FUNCTION soft_delete(post_id uuid) RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE posts SET deleted_at = now() WHERE id = post_id AND author_id = auth.uid();
  IF NOT FOUND THEN RAISE EXCEPTION 'Not found or not authorized'; END IF;
END; $$;
```

## Error Handling

```sql
CREATE FUNCTION safe_op(a numeric, b numeric) RETURNS numeric LANGUAGE plpgsql AS $$
BEGIN
  IF b = 0 THEN RAISE EXCEPTION 'Division by zero' USING ERRCODE = 'P0002'; END IF;
  RETURN a / b;
EXCEPTION WHEN OTHERS THEN RAISE EXCEPTION 'Error: %', SQLERRM;
END; $$;
```

## Call from JS

```javascript
const { data } = await supabase.rpc('search', { q: 'flutter' })
const { data, count } = await supabase.rpc('paginated_posts', { page_num: 1 }, { count: 'exact' })
```
