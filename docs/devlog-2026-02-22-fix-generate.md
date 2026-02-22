# Artio DEVLOG

## 2026-02-22 — Fix Generate Image Flow

### Context

User `minhthang421992@gmail.com` (premium) reported "Something went wrong" khi bấm Generate sau khi upload ảnh trong template flow.

---

### Bug #1: Missing `model_id` Column in `generation_jobs`

**Symptom:** "Something went wrong" ngay sau khi bấm Generate.

**Root Cause:**
- `generation_repository.dart` insert `model_id` field vào bảng `generation_jobs`
- Bảng DB không có column `model_id` (chưa có trong migration)
- → `PostgrestException("column generation_jobs.model_id does not exist")` → `AppException.unknown()` → "Something went wrong"

**Verified via:**
- Supabase REST API query: `?select=model_id` → trả về `"column generation_jobs.model_id does not exist"` (HTTP 400, error code `42703`)
- Không có `model_id` trong `generation_jobs` schema (`migrations/20260128115551_add_deleted_at_and_storage_bucket.sql`)

**Fix:**
```sql
-- supabase/migrations/20260222_add_model_id_to_generation_jobs.sql
ALTER TABLE generation_jobs
  ADD COLUMN IF NOT EXISTS model_id TEXT;
```

Applied trực tiếp lên Supabase remote database qua SQL Editor.

---

### Bug #2: `Image.network()` nhận storage path thay vì HTTPS URL

**Symptom:** Sau khi generate thành công (green checkmark), app hiển thị lỗi đỏ:
```
Invalid argument(s): No host specified in URI file:///07410caf.../uuid.jpg
```

**Root Cause:**
- `CompletedStatusSection` widget (`generation_progress_sections.dart`) gọi `Image.network(resultUrls!.first)` trực tiếp
- `resultUrls` chứa **Supabase storage paths** như `userId/filename.jpg`, không phải HTTPS URL
- Flutter `Image.network()` cố parse storage path → không có scheme → Dart tự thêm `file://` prefix → `Uri.host` trống → throw `Invalid argument(s): No host specified`

**Fix:**
1. Tạo `lib/core/services/storage_url_service.dart`:
   - `StorageUrlService.signedUrl(path)` → tạo signed HTTPS URL từ Supabase storage path
   - `signedStorageUrlProvider` (Riverpod `FutureProvider.family`) để dùng trong widget
2. Thay `Image.network(resultUrls!.first)` bằng `_SignedStorageImage(storagePath)`:
   - `_SignedStorageImage` là `ConsumerWidget`
   - Watch `signedStorageUrlProvider(storagePath)` → khi signed URL ready, render `Image.network(url)`

---

### Files Changed

| File | Type | Change |
|------|------|--------|
| `supabase/migrations/20260222_add_model_id_to_generation_jobs.sql` | NEW | Add `model_id TEXT` column to `generation_jobs` |
| `lib/core/services/storage_url_service.dart` | NEW | `StorageUrlService` + `signedStorageUrlProvider` |
| `lib/features/template_engine/presentation/widgets/generation_progress_sections.dart` | MODIFY | Replace `Image.network(storagePath)` with `_SignedStorageImage` widget |

---

### Verification

- ✅ Build: `flutter build apk --debug` → success
- ✅ Install: `adb install -r app-debug.apk` → success  
- ✅ Test: User `minhthang421992@gmail.com` confirmed generate hoạt động sau fix
- ✅ `dart analyze` → No issues found
