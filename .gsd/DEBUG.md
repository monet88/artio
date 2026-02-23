---
status: resolved
trigger: "input_image_paths always NULL in generation_jobs despite images being uploaded and used successfully"
created: 2026-02-22T21:44:00+07:00
updated: 2026-02-22T21:55:00+07:00
---

## Symptom

expected: `input_image_paths` column in `generation_jobs` stores uploaded image storage paths
actual: All 17 generation jobs have `input_image_paths = null` despite images being uploaded to Storage and used successfully by Edge Function

## Evidence

- checked: All 17 generation_jobs from templates — 0 have `input_image_paths` set
  found: Column always null even for jobs that use image editing models (nano-banana-edit)
  implication: Data not persisting through PostgREST API

- checked: Supabase Storage `generated-images/{userId}/inputs/` folder
  found: 10+ uploaded images exist with timestamps matching job creation times
  implication: Upload succeeds, images are used, but paths not saved to DB

- checked: Column privileges for `authenticated` role
  found: INSERT/UPDATE/SELECT all granted, no triggers, column type `text[]` correct
  implication: DB-level permissions are fine

- checked: Direct SQL INSERT with array values
  found: Works perfectly — array persists
  implication: Issue is NOT at PostgreSQL level

- checked: PostgREST REST API insert (simulating Dart client)
  found: After schema reload, array persists correctly
  implication: PostgREST schema cache was stale

## Hypotheses

| # | Hypothesis | Likelihood | Status |
|---|------------|------------|--------|
| 1 | PostgREST schema cache stale after migration | 90% | CONFIRMED |
| 2 | Dart List<String> serialization issue | 5% | ELIMINATED |
| 3 | RLS policy blocking column | 3% | ELIMINATED |
| 4 | DB trigger nullifying column | 2% | ELIMINATED |

## Attempts

### Attempt 1
**Testing:** H3 — RLS policy blocking column write
**Action:** Queried column_privileges and RLS policies
**Result:** All privileges granted, RLS only checks `auth.uid() = user_id`
**Conclusion:** ELIMINATED

### Attempt 2
**Testing:** H4 — DB trigger nullifying column
**Action:** Queried information_schema.triggers
**Result:** No triggers on generation_jobs table
**Conclusion:** ELIMINATED

### Attempt 3
**Testing:** H1 — PostgREST schema cache stale
**Action:** Ran `NOTIFY pgrst, 'reload schema'`, then tested PostgREST REST API insert with JSON array
**Result:** `input_image_paths` now correctly saved as `["path/test1.jpg", "path/test2.jpg"]`
**Conclusion:** CONFIRMED

## Resolution

**Root Cause:** PostgREST schema cache was stale after migration `20260222073922` (add_input_image_paths) was applied. PostgREST didn't know about the new `input_image_paths TEXT[]` column and **silently dropped** it from INSERT payloads sent via the REST API.

**Fix:** Ran `NOTIFY pgrst, 'reload schema'` to force PostgREST to refresh its schema cache. No code changes needed.

**Verified:** PostgREST REST API insert now correctly persists `input_image_paths` array values.

**Prevention:** After applying migrations that add/alter columns, always run:
```sql
NOTIFY pgrst, 'reload schema';
```
Or use Supabase dashboard to restart PostgREST. The `apply_migration` MCP tool may handle this automatically, but direct SQL or `supabase db push` may not.

**Regression Check:** No regressions — this was a configuration issue, not a code issue.
