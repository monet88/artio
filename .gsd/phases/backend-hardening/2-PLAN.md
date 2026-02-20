---
phase: 1
plan: 2
wave: 1
---

# Plan 1.2: Storage Cleanup on Partial Upload Failure

## Objective
Fix orphaned storage files when `mirrorUrlsToStorage` or `mirrorBase64ToStorage` fails mid-sequence. Currently if upload #2 of 4 fails, upload #1 remains as an orphaned file in Supabase Storage. Add cleanup logic to delete successfully uploaded files when a subsequent upload fails.

## Context
- `plans/reports/review-260220-1533-edge-cases-verification.md` — Partial #13 (storage upload failure, orphaned files)
- `supabase/functions/generate-image/index.ts` — Lines 313-351 (`mirrorUrlsToStorage`, `mirrorBase64ToStorage`)
- `.gsd/ARCHITECTURE.md` — Storage bucket `generated-images`, path pattern `{userId}/{jobId}.{ext}`

## Tasks

<task type="auto">
  <name>Add cleanup to mirrorUrlsToStorage</name>
  <files>
    - supabase/functions/generate-image/index.ts
  </files>
  <action>
    1. Modify `mirrorUrlsToStorage` (L313-329) to wrap the upload loop in try/catch:
       ```typescript
       async function mirrorUrlsToStorage(
         supabase: ReturnType<typeof getSupabaseClient>,
         userId: string,
         jobId: string,
         imageUrls: string[],
         outputFormat: string = "jpg"
       ): Promise<string[]> {
         const storagePaths: string[] = [];

         for (let i = 0; i < imageUrls.length; i++) {
           try {
             const imageData = await downloadImage(imageUrls[i]);
             const storagePath = await uploadToStorage(supabase, userId, jobId, imageData, i, outputFormat);
             storagePaths.push(storagePath);
           } catch (error) {
             // Clean up already-uploaded files before re-throwing
             if (storagePaths.length > 0) {
               console.warn(`[${jobId}] Upload failed at index ${i}, cleaning up ${storagePaths.length} orphaned files`);
               await cleanupStorageFiles(supabase, storagePaths);
             }
             throw error;
           }
         }

         return storagePaths;
       }
       ```

    2. Apply the same pattern to `mirrorBase64ToStorage` (L331-352)

    3. Add helper function `cleanupStorageFiles` before the mirror functions:
       ```typescript
       async function cleanupStorageFiles(
         supabase: ReturnType<typeof getSupabaseClient>,
         paths: string[]
       ): Promise<void> {
         const { error } = await supabase.storage
           .from("generated-images")
           .remove(paths);

         if (error) {
           console.error(`Failed to cleanup orphaned files: ${error.message}`, paths);
           // Non-fatal: log but don't throw — the original error is more important
         }
       }
       ```

    What to AVOID:
    - Do NOT change the error handling flow in the main handler — the existing try/catch + refund pattern stays
    - Do NOT add retries to cleanup — it's best-effort (the main error matters more)
    - Do NOT change function signatures — cleanup is internal to the mirror functions
  </action>
  <verify>
    1. `deno check supabase/functions/generate-image/index.ts` passes
    2. Read the code to verify cleanup is called before re-throw in both mirror functions
    3. Existing Deno tests still pass
  </verify>
  <done>
    - `cleanupStorageFiles` helper function exists
    - `mirrorUrlsToStorage` cleans up on mid-sequence failure
    - `mirrorBase64ToStorage` cleans up on mid-sequence failure
    - Cleanup is best-effort (logs errors but doesn't throw)
    - Original error is preserved and re-thrown
  </done>
</task>

<task type="auto">
  <name>Update edge case review report</name>
  <files>
    - plans/reports/review-260220-1533-edge-cases-verification.md
  </files>
  <action>
    After implementing both plans (1.1 and 1.2), update the review report:
    1. Move "Rate limiting" from Unhandled → Fixed Since Report section
    2. Move "imageCount not validated server-side" from Unhandled → Fixed Since Report section
    3. Move "Storage upload failure (orphaned files)" from Partial → Fixed Since Report section
    4. Update summary counts accordingly
    5. Add changelog entry with date and milestone reference
  </action>
  <verify>
    Review updated report for accuracy — counts must match item lists
  </verify>
  <done>
    - Report summary counts updated
    - Fixed items moved to "Fixed Since Report" section
    - Changelog entry added
  </done>
</task>

## Success Criteria
- [ ] `cleanupStorageFiles` helper implemented
- [ ] Both `mirrorUrlsToStorage` and `mirrorBase64ToStorage` clean up on failure
- [ ] Cleanup is non-fatal (logs error, doesn't throw)
- [ ] Edge case review report updated with fixes
- [ ] `deno check` passes for the modified file
