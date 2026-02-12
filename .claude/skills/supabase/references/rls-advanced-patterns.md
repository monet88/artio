# RLS Advanced Patterns

## Team/Organization Access

```sql
CREATE POLICY "Team access" ON projects FOR ALL TO authenticated
USING (team_id IN (SELECT team_id FROM team_members WHERE user_id = (SELECT auth.uid())));
```

## RBAC via roles table

```sql
CREATE TABLE user_roles (
  user_id uuid REFERENCES auth.users PRIMARY KEY,
  role text NOT NULL CHECK (role IN ('user', 'moderator', 'admin'))
);

CREATE POLICY "Admin all" ON posts FOR ALL TO authenticated
USING (EXISTS (SELECT 1 FROM user_roles WHERE user_id = (SELECT auth.uid()) AND role = 'admin'));
```

## RBAC via JWT app_metadata

```sql
CREATE POLICY "Admin via JWT" ON posts FOR ALL TO authenticated
USING (auth.jwt()->'app_metadata'->>'role' = 'admin');
```

## Status-Based Access

```sql
CREATE POLICY "Published or own" ON posts FOR SELECT
USING (status = 'published' OR (SELECT auth.uid()) = author_id);
```

## Time-Based Access

```sql
CREATE POLICY "Current events" ON events FOR SELECT
USING (start_date <= now() AND (end_date IS NULL OR end_date >= now()));
```

## Hierarchical (Manager sees subordinates)

```sql
CREATE POLICY "Manager access" ON employees FOR SELECT TO authenticated
USING (id = (SELECT auth.uid()) OR manager_id = (SELECT auth.uid()));
```

## Security Definer for Performance

```sql
-- Avoid expensive subqueries by wrapping in function
CREATE FUNCTION user_team_ids() RETURNS SETOF uuid
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT team_id FROM team_members WHERE user_id = auth.uid();
$$;

CREATE POLICY "Fast team" ON projects FOR ALL
USING (team_id IN (SELECT user_team_ids()));
```

## Store team_ids in JWT (fastest)

```sql
-- After: admin.updateUserById(userId, { app_metadata: { team_ids: [uuid1] } })
CREATE POLICY "Team via JWT" ON projects FOR ALL TO authenticated
USING (team_id::text = ANY(
  ARRAY(SELECT jsonb_array_elements_text(auth.jwt()->'app_metadata'->'team_ids'))
));
```

## RESTRICTIVE Policy (explicit deny)

```sql
CREATE POLICY "Block banned" ON posts FOR ALL AS RESTRICTIVE TO authenticated
USING (NOT EXISTS (SELECT 1 FROM banned_users WHERE user_id = (SELECT auth.uid())));
```

## MFA Requirement

```sql
CREATE POLICY "Require MFA" ON sensitive_table FOR UPDATE TO authenticated
USING (auth.jwt()->>'aal' = 'aal2');
```

## Email Verified Only

```sql
CREATE POLICY "Verified only" ON posts FOR INSERT
WITH CHECK (auth.jwt()->>'email_confirmed_at' IS NOT NULL);
```

## Block Anonymous

```sql
CREATE POLICY "No anon" ON premium_table FOR ALL
USING ((auth.jwt()->>'is_anonymous')::boolean = false);
```

## Testing Policies

```sql
SET request.jwt.claims = '{"sub":"user-uuid","role":"authenticated"}';
SELECT * FROM posts;  -- Should return user's rows only
RESET request.jwt.claims;

-- Test as admin
SET request.jwt.claims = '{"sub":"user-uuid","role":"authenticated","app_metadata":{"role":"admin"}}';
SELECT * FROM admin_table;
RESET request.jwt.claims;
```

## Security Rules

1. Always specify TO role (`TO authenticated`, not omit)
2. Separate policies by operation (SELECT/INSERT/UPDATE/DELETE vs ALL)
3. Use `app_metadata` not `user_metadata` for security decisions
4. Wrap `auth.uid()` in `(SELECT auth.uid())` for performance
5. Index all columns used in RLS policies
