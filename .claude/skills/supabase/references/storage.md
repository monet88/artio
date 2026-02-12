# Supabase Storage

File storage with buckets, RLS, signed URLs, and image transforms.

## Quick Reference

| Operation | Code |
|-----------|------|
| Upload | `storage.from('bucket').upload(path, file, { upsert: true })` |
| Download | `storage.from('bucket').download(path)` |
| Public URL | `storage.from('bucket').getPublicUrl(path)` |
| Signed URL | `storage.from('bucket').createSignedUrl(path, 3600)` |
| Delete | `storage.from('bucket').remove([path1, path2])` |
| List | `storage.from('bucket').list(folder, { limit: 100 })` |
| Move | `storage.from('bucket').move(from, to)` |
| Copy | `storage.from('bucket').copy(from, to)` |

## Bucket Setup

```sql
-- Create bucket via SQL
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('avatars', 'avatars', true, 5242880, ARRAY['image/jpeg','image/png','image/webp']);
```

```toml
# Or via config.toml
[storage.buckets.avatars]
public = true
file_size_limit = "5MiB"
allowed_mime_types = ["image/png", "image/jpeg", "image/webp"]
```

## Upload Patterns

```javascript
// Basic upload
const { data, error } = await supabase.storage
  .from('avatars').upload('user-123/avatar.png', file, {
    cacheControl: '3600', contentType: 'image/png', upsert: true
  })

// Base64 upload
const buffer = Uint8Array.from(atob(base64String), c => c.charCodeAt(0))
await supabase.storage.from('images').upload('photo.png', buffer, { contentType: 'image/png' })
```

## URL Generation

```javascript
// Public URL (public buckets only)
const { data } = supabase.storage.from('avatars').getPublicUrl('user-123/avatar.png')

// Signed URL (private buckets, 1 hour expiry)
const { data } = await supabase.storage.from('docs').createSignedUrl('report.pdf', 3600)

// Multiple signed URLs
const { data } = await supabase.storage.from('docs').createSignedUrls(['a.pdf', 'b.pdf'], 3600)
```

## Image Transforms (Pro plan+)

```javascript
const { data } = supabase.storage.from('images').getPublicUrl('photo.jpg', {
  transform: { width: 200, height: 200, resize: 'cover', quality: 75, format: 'webp' }
})
```

Resize modes: `cover` (crop), `contain` (fit), `fill` (stretch)

## Storage RLS Policies

```sql
-- Users view own files
CREATE POLICY "Users view own" ON storage.objects FOR SELECT
TO authenticated USING (bucket_id = 'uploads' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Users upload to own folder
CREATE POLICY "Users upload own" ON storage.objects FOR INSERT
TO authenticated WITH CHECK (bucket_id = 'uploads' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Users delete own files
CREATE POLICY "Users delete own" ON storage.objects FOR DELETE
TO authenticated USING (bucket_id = 'uploads' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Public read for public bucket
CREATE POLICY "Public read" ON storage.objects FOR SELECT TO public USING (bucket_id = 'public-images');
```

## Error Handling

```javascript
if (error) {
  if (error.message === 'The resource already exists') { /* duplicate */ }
  else if (error.message.includes('exceeded')) { /* file too large */ }
  else if (error.message.includes('mime type')) { /* invalid type */ }
}
```

## Limits

| Plan | Max File Size |
|------|---------------|
| Free | 50 MB |
| Pro+ | 500 GB |
