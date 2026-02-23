# Hướng Dẫn Setup Local Supabase Development

> **Mục tiêu:** Chuyển từ dev trực tiếp trên Supabase Cloud sang workflow Local → Test → Push to Cloud

---

## 1. Prerequisites

### Cài Docker Desktop

Tải và cài đặt: https://www.docker.com/products/docker-desktop/

- Windows: Bật WSL2 trong Docker Desktop settings
- macOS: Cài Docker Desktop thông thường
- Linux: Cài Docker Engine + Docker Compose

### Cài Supabase CLI

```bash
# macOS/Linux (Homebrew)
brew install supabase/tap/supabase

# Windows (Scoop)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# Hoặc dùng npm (đa nền tảng)
npm install -g supabase

# Verify cài đặt
supabase --version
```

---

## 2. Link Project với Supabase Cloud

```bash
# Đăng nhập vào Supabase (mở browser để xác thực)
supabase login

# Link project local với cloud project
# Lấy project ref từ: Supabase Dashboard > Settings > General > Reference ID
supabase link --project-ref abcdefghijklmnop

# Verify đã link thành công
supabase projects list
```

---

## 3. Pull Schema Hiện Tại từ Cloud

Vì bạn đang dev trực tiếp trên cloud, cần pull schema về local:

```bash
# Pull toàn bộ schema hiện tại từ cloud
# Tạo migration file mới chứa toàn bộ schema hiện tại
supabase db pull

# Kiểm tra file migration mới được tạo trong supabase/migrations/
ls supabase/migrations/
```

---

## 4. Khởi Động Local Supabase

```bash
# Khởi động toàn bộ stack (Postgres, Auth, Storage, Edge Functions, Studio)
# Lần đầu sẽ tải Docker images, mất vài phút
supabase start

# Output sẽ hiển thị các URL local:
# API URL:    http://127.0.0.1:54321
# Studio URL: http://127.0.0.1:54323  (UI giống Dashboard)
# DB URL:     postgresql://postgres:postgres@127.0.0.1:54322/postgres
```

Truy cập Studio: http://127.0.0.1:54323

---

## 5. Cấu Hình Flutter App cho Local Dev

### Tạo file `.env.development`

Tại root project (cùng cấp với `.env`):

```env
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...  # Anon Key từ supabase start
```

> **Lưu ý:** Copy Anon Key từ output của `supabase start`

### Chạy Flutter với Local Env

```bash
# Chạy với environment development
flutter run --dart-define=ENV=development

# Hoặc nếu dùng flutter_dotenv, sửa code load env:
# await dotenv.load(fileName: '.env.development');
```

### Test kết nối

1. Đăng ký tài khoản mới (local)
2. Tạo vài record test
3. Check trong Studio: http://127.0.0.1:54323

---

## 6. Workflow Hàng Ngày

### Khi làm việc với Database

```bash
# 1. Tạo migration mới
supabase migration new add_user_preferences

# 2. Viết SQL vào file vừa tạo
# File: supabase/migrations/20260223120000_add_user_preferences.sql

# 3. Test migration (reset DB và chạy lại tất cả migrations)
supabase db reset

# 4. Nếu OK → commit
# git add supabase/migrations/
# git commit -m "feat(db): add user preferences table"
```

### Khi làm việc với Edge Functions

```bash
# 1. Code trong supabase/functions/<function-name>/index.ts

# 2. Test function local
supabase functions serve generate-image

# Gọi test từ terminal khác:
curl -i --location --request POST 'http://127.0.0.1:54321/functions/v1/generate-image' \
  --header 'Authorization: Bearer <anon-key>' \
  --header 'Content-Type: application/json' \
  --data '{"prompt":"test"}'
```

### Khi đồng đội push migration mới

```bash
# 1. Pull code mới
git pull

# 2. Reset local DB để apply migrations mới
supabase db reset

# 3. Tiếp tục dev với schema mới
```

---

## 7. Deploy lên Supabase Cloud (Thủ Công)

Khi nào bạn thấy OK, chạy 2 lệnh:

```bash
# Deploy migrations lên cloud
supabase db push

# Deploy Edge Functions lên cloud
supabase functions deploy

# Set secrets cho Edge Functions (nếu có)
supabase secrets set GEMINI_API_KEY=xxx KIE_API_KEY=xxx
```

**Lưu ý:**
- `db push` chỉ chạy migrations chưa được apply trên cloud
- Nếu migration fail, fix lỗi rồi chạy lại

---

## 8. Stop / Restart Local Supabase

```bash
# Dừng local Supabase (giữ dữ liệu)
supabase stop

# Dừng và xoá toàn bộ dữ liệu local
supabase stop --no-backup

# Khởi động lại
supabase start

# Xem status
supabase status
```

---

## 9. Troubleshooting

### Docker không chạy được

```bash
# Kiểm tra Docker Desktop đã mở chưa
docker ps

# Nếu lỗi port bị chiếm:
supabase stop
supabase start
```

### Migration fail

```bash
# Kiểm tra migration nào đang lỗi
supabase migration list

# Repair nếu cần
supabase migration repair 20260223120000 --status reverted
```

### Flutter không kết nối được local

- Kiểm tra `SUPABASE_URL` có đúng là `http://127.0.0.1:54321`
- Kiểm tra Windows Firewall / macOS Security cho phép localhost
- Thử dùng `10.0.2.2` thay vì `127.0.0.1` nếu chạy trên Android Emulator

---

## 10. Team Workflow (2-3 ngườI)

```
Dev A                          Git                            Dev B
──────                         ───                            ─────
Tạo migration
  ↓
supabase db reset (test)
  ↓
git commit + push ───────────→ migrations/xxx.sql
                                  ↓
                                git pull
                                  ↓
                              supabase db reset
                                  ↓
                              Tiếp tục dev ✅
```

**Quy tắc:**
1. Luôn tạo migration mới, không sửa migration cũ
2. Test `db reset` trước khi push
3. Pull code → `db reset` khi đồng đội push migration mới
4. Không commit file `.env.development` (có thể khác nhau giữa các máy)

---

## Tóm Tắt Các Lệnh Thường Dùng

| Lệnh | Mục đích |
|------|----------|
| `supabase start` | Khởi động local stack |
| `supabase stop` | Dừng local stack |
| `supabase db reset` | Reset DB, chạy lại tất cả migrations |
| `supabase migration new <name>` | Tạo migration mới |
| `supabase db pull` | Pull schema từ cloud về local |
| `supabase db push` | Push migrations lên cloud |
| `supabase functions serve <name>` | Chạy function local để test |
| `supabase functions deploy` | Deploy functions lên cloud |
| `supabase status` | Xem trạng thái local stack |

---

## Next Steps

1. ✅ Cài Docker Desktop
2. ✅ Cài Supabase CLI
3. ✅ `supabase login` + `supabase link`
4. ✅ `supabase db pull` (pull schema hiện tại)
5. ✅ `supabase start`
6. ✅ Tạo `.env.development`
7. ✅ Chạy Flutter test local
8. ✅ Bắt đầu dev theo workflow mới

Sau khi setup xong, mỗi khi cần deploy lên cloud chỉ cần:

```bash
supabase db push
supabase functions deploy
```
