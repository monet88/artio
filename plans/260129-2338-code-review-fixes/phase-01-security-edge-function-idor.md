# Phase 01: Security - Edge Function IDOR Fix

## Parallelization Info

| Property | Value |
|----------|-------|
| Group | A (Security) |
| Can Run With | Phase 02 |
| Blocked By | None |
| Blocks | Group B (Phases 03, 04) |

## File Ownership (Exclusive)

- `supabase/functions/generate-image/index.ts`

## Priority: CRITICAL

**Issue**: IDOR vulnerability - userId taken from request body instead of JWT token. Attacker can specify any userId to generate images on behalf of other users.

## Current State (Vulnerable)

```typescript
const body: GenerationRequest = await req.json();
const { jobId, userId, prompt, ... } = body;  // userId from untrusted input!
```

## Implementation Steps

### Step 1: Extract userId from JWT

```typescript
// Add at top of handler after CORS check
const authHeader = req.headers.get('Authorization');
if (!authHeader?.startsWith('Bearer ')) {
  return new Response(
    JSON.stringify({ error: 'Missing authorization header' }),
    { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

const token = authHeader.replace('Bearer ', '');
const supabase = getSupabaseClient();

const { data: { user }, error: authError } = await supabase.auth.getUser(token);
if (authError || !user) {
  return new Response(
    JSON.stringify({ error: 'Invalid or expired token' }),
    { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

const userId = user.id;  // Trusted source!
```

### Step 2: Update GenerationRequest interface

```typescript
interface GenerationRequest {
  jobId: string;
  // Remove userId - will be extracted from JWT
  prompt: string;
  model?: string;
  aspectRatio?: string;
  imageCount?: number;
  imageInputs?: string[];
}
```

### Step 3: Update body destructuring

```typescript
const body: GenerationRequest = await req.json();
const {
  jobId,
  prompt,
  model = "nano-banana-pro",
  aspectRatio = "1:1",
  imageInputs,
} = body;

// Validate required fields (userId now comes from JWT)
if (!jobId || !prompt) {
  return new Response(
    JSON.stringify({ error: "Missing required fields: jobId, prompt" }),
    { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
  );
}
```

### Step 4: Verify job ownership

```typescript
// After getting userId from JWT, verify the job belongs to this user
const { data: job, error: jobError } = await supabase
  .from('generation_jobs')
  .select('user_id')
  .eq('id', jobId)
  .single();

if (jobError || !job) {
  return new Response(
    JSON.stringify({ error: 'Job not found' }),
    { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

if (job.user_id !== userId) {
  return new Response(
    JSON.stringify({ error: 'Unauthorized: job belongs to another user' }),
    { status: 403, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}
```

## Success Criteria

- [ ] userId extracted from JWT Authorization header, not request body
- [ ] Returns 401 for missing/invalid token
- [ ] Returns 403 if job doesn't belong to authenticated user
- [ ] All existing generation flows still work
- [ ] Edge function deploys successfully

## Conflict Prevention

- This phase has exclusive ownership of `supabase/functions/generate-image/index.ts`
- No other phase modifies Supabase functions

## Security Considerations

- JWT validation uses Supabase's built-in `auth.getUser()` which verifies signature
- Service role key only used for database operations, not JWT validation
- Job ownership check prevents horizontal privilege escalation

## Deployment

### Deploy Edge Function

```bash
cd supabase
supabase functions deploy generate-image --project-ref $SUPABASE_PROJECT_REF
```

### Verify Deployment

```bash
# Test with valid token
curl -X POST "https://$PROJECT_REF.supabase.co/functions/v1/generate-image" \
  -H "Authorization: Bearer $USER_JWT" \
  -H "Content-Type: application/json" \
  -d '{"jobId": "test-job", "prompt": "test"}'

# Should return 401 without token
curl -X POST "https://$PROJECT_REF.supabase.co/functions/v1/generate-image" \
  -H "Content-Type: application/json" \
  -d '{"jobId": "test-job", "prompt": "test"}'
```

## Rollback Procedure

If issues occur after deployment:

```bash
# 1. Revert to previous version
git checkout HEAD~1 -- supabase/functions/generate-image/index.ts

# 2. Redeploy previous version
supabase functions deploy generate-image --project-ref $SUPABASE_PROJECT_REF

# 3. Verify rollback
curl -X POST "https://$PROJECT_REF.supabase.co/functions/v1/generate-image" \
  -H "Authorization: Bearer $USER_JWT" \
  -H "Content-Type: application/json" \
  -d '{"jobId": "test", "userId": "user-123", "prompt": "test"}'
```
