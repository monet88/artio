---
phase: 1
plan: 1
wave: 1
---

# Plan 1.1: Backend Concurrency & Limits

## Objective
Fix concurrent generation requests (deduplication), make credit deductions atomic, and refine KIE timeout logic in Edge Functions to ensure safe multi-processing.

## Context
- `supabase/functions/generate-image/index.ts`
- `supabase/migrations/*_deduct_credits.sql` (or relevant RPC)
- `.gsd/ROADMAP.md`

## Tasks

<task type="auto">
  <name>Refine AI Provider Timeout</name>
  <files>supabase/functions/generate-image/index.ts</files>
  <action>
    - Review the KIE polling loop (currently ~60 attempts * 2s).
    - Ensure the timeout accurately reflects a 120s max limit without silently hanging.
    - Add explicit timeout logging.
  </action>
  <verify>grep_search `delay` or `timeout` in `generate-image/index.ts`</verify>
  <done>Timeout polling logic is explicitly constrained to 120 seconds with clear error throws.</done>
</task>

<task type="auto">
  <name>Concurrent Request Deduplication</name>
  <files>supabase/functions/generate-image/index.ts</files>
  <action>
    - Add a locking mechanism or deduplication check for `generate-image` requests to prevent the same job/prompt from being processed simultaneously by the same user.
    - E.g., check for a pending generation status in the DB before proceeding.
  </action>
  <verify>grep_search `status = 'pending'` or lock mechanic in `generate-image/index.ts`</verify>
  <done>Server-side check prevents concurrent duplicate job execution.</done>
</task>

<task type="auto">
  <name>Atomic Credit Deductions</name>
  <files>supabase/migrations/</files>
  <action>
    - Locate the `deduct_credits` RPC migration file or create a new one to replace it.
    - Ensure the deduction uses a strict atomic `UPDATE ... WHERE balance >= cost` rather than separated SELECT and UPDATE statements that can cause race conditions.
  </action>
  <verify>cat the relevant SQL migration file for `deduct_credits`</verify>
  <done>Credit deduction is a single atomic database operation.</done>
</task>

## Success Criteria
- [ ] AI timeout firmly enforced at 120s max.
- [ ] Attempting concurrent overlapping generation requests drops the duplicate.
- [ ] Spamming `deduct_credits` accurately prevents balance going negative.
