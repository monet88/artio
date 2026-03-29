# Admin v2 — Session Summary

**Date:** 2026-03-29
**Branch:** feat/admin-v2
**PR:** #88 — feat(admin): Admin v2 — Users, Jobs, Templates, Analytics
**Status:** Ready to merge

---

## Mục tiêu

Xây dựng hoàn chỉnh admin web app (`/admin`) với 4 tính năng chính:
Users Management, Jobs Monitor, Templates Management, Analytics Dashboard.
Admin app là Flutter Web app riêng biệt, không dùng `data/` layer,
providers gọi Supabase trực tiếp.

---

## Việc đã làm

### Prerequisite — Supabase migrations

| Migration | Nội dung |
|-----------|----------|
| `20260329200000_admin_users_management.sql` | `is_banned` column, admin RLS policies cho `profiles` + `generation_jobs`, 3 RPCs: `admin_set_credits / admin_set_premium / admin_set_banned` với SECURITY DEFINER + SET search_path + REVOKE PUBLIC |
| `20260329210000_create_templates_storage_bucket.sql` | Bucket `templates` (public, 5MB, image/*), RLS: public SELECT, admin-only INSERT/UPDATE/DELETE |

Lý do cần migration trước: code thumbnail upload (`template_editor_page.dart`) và
analytics queries yêu cầu `is_banned` field và đúng RLS.

---

### Nhóm 1 — Users Management

**Files:**
- `admin/lib/features/users/domain/entities/admin_user_model.dart` — `@freezed` entity, `tierBadgeLabel` computed getter
- `admin/lib/features/users/presentation/pages/users_page.dart` — real-time stream, filter (All/Premium/Free/Banned), search
- `admin/lib/features/users/presentation/pages/user_detail_page.dart` — profile card, stats (credits/generations/joined), admin actions (set credits, toggle premium, ban), recent 10 jobs
- `admin/test/features/users/domain/entities/admin_user_model_test.dart` — 7 tests

**Key decisions:**
- Stream từ Supabase (real-time update) thay vì Future (one-shot)
- Client-side filter/search — đủ cho admin use case, tránh phức tạp RPC
- Admin actions dùng RPC trực tiếp, show SnackBar on success/error, refresh provider sau mỗi action

---

### Nhóm 2 — Jobs Monitor

**Files:**
- `admin/lib/features/jobs/domain/entities/admin_job_model.dart` — plain Dart class, computed status helpers
- `admin/lib/features/jobs/presentation/pages/jobs_page.dart` — stream 500 jobs mới nhất, filter theo status, search theo userId/modelId
- `admin/lib/features/jobs/presentation/pages/job_detail_page.dart` — debug view: status, prompt, image preview, error message
- `admin/test/features/jobs/domain/entities/admin_job_model_test.dart` — 8 tests

**Key decisions:**
- Limit 500 jobs — đủ visibility, tránh performance issue với bảng lớn
- Debug-only page, không có retry/action — read-only view

---

### Nhóm 3 — Templates Management (enhancements)

**Files modified:**
- `admin/lib/features/templates/presentation/pages/template_editor_page.dart` — thêm thumbnail upload via `file_picker` + Supabase Storage `templates` bucket
- `admin/lib/features/templates/presentation/pages/templates_page.dart` — thêm bulk activate/deactivate (multi-select mode)
- `admin/lib/features/templates/presentation/widgets/template_card.dart` — thêm checkbox overlay khi in selection mode, `onLongPress` để enter selection mode

**Key decisions:**
- Upload path: `templates/{id}/thumbnail.{ext}` với `upsert: true`
- Selection mode enter via **long press** (tránh circular dependency)
- Bulk action chỉ visible khi `_selectedIds.isNotEmpty`

---

### Nhóm 4 — Analytics Dashboard

**Files:**
- `admin/lib/features/analytics/domain/entities/analytics_stats.dart` — `AnalyticsStats`, `DailyCount`, `ModelCount` plain Dart classes
- `admin/lib/features/analytics/providers/analytics_stats_provider.dart` — `@riverpod Future<AnalyticsStats>`, 3 Supabase queries với `retry()`, client-side aggregation
- `admin/lib/features/analytics/presentation/pages/analytics_page.dart` — 4 KPI cards + 3 charts
- `admin/test/features/analytics/domain/entities/analytics_stats_test.dart` — 5 tests

**Architecture decision:** Revenue chart không khả thi (không có RC webhook events table trong DB).
Thay bằng Tier Distribution PieChart (Premium vs Free) — proxy hữu ích.

**Charts:**
| Chart | Type | Data |
|-------|------|------|
| Daily Jobs | `fl_chart` LineChart | 7 ngày gần nhất, zero-fill |
| Top Models | `fl_chart` BarChart | Top 5 models by usage (7 days) |
| Tier Distribution | `fl_chart` PieChart | premiumUsers vs freeUsers |

---

### Navigation

- `admin_shell.dart` — NavigationRail: Dashboard(0) / Users(1) / Jobs(2) / Templates(3) / Analytics(4)
- `app_router.dart` — Routes: `/users`, `/users/:id`, `/jobs`, `/jobs/:id`, `/analytics`

---

## Kết quả

| Metric | Value |
|--------|-------|
| `flutter analyze` | 0 issues |
| `flutter test` | 34/34 passed |
| Commits | 20 commits (feat + fix + style) |
| Files changed | 29 files, ~3,500 lines added |

---

## Code Review — PR #88

### Review 1 (manual, cuộc session này)

Tìm được 4 issues, fix 3:

| Issue | File | Quyết định |
|-------|------|------------|
| `dynamic inputFieldsJson` | `template_editor_page.dart:122` | **Fixed** → `Object?` |
| Missing `retry()` trên 3 providers | `user_detail_page.dart` | **Fixed** |
| Silent error state cho jobs | `user_detail_page.dart:240` | **Fixed** → `ErrorStateWidget` |
| `user_detail_page.dart` 594 dòng | — | Skip — cosmetic, follow-up |
| Tests cho `analyticsStatsProvider` | — | Skip — admin tool, low risk |

### Review 2 (cubic-dev-ai bot)

Tìm được 7 issues, fix 6:

| # | Priority | Issue | File | Quyết định |
|---|----------|-------|------|------------|
| 1 | P2 | DB-side count query | `user_detail_page.dart:29` | **Skip** — low traffic |
| 2 | **P1** | `substring(0,1)` RangeError trên empty string | `user_detail_page.dart:113` | **Fixed** → `_avatarLetter()` |
| 3 | P2 | `setState` trước `mounted` trong `_bulkAction` | `templates_page.dart:134` | **Fixed** |
| 4 | P2 | Selection mode không thể enter (circular dependency) | `templates_page.dart:361` | **Fixed** → `onLongPress` |
| 5 | P2 | `setState` trước `mounted` sau upload | `template_editor_page.dart:223` | **Fixed** |
| 6 | **P1** | Cùng RangeError trong UsersPage avatar | `users_page.dart:217` | **Fixed** → `_avatarLetter()` |
| 7 | P2 | `isAfter` exclusive → miss midnight jobs | `analytics_stats_provider.dart:47` | **Fixed** → `!isBefore` |

**Lý do skip #1 (DB count query):** Admin internal tool, traffic thấp, fetch-and-count đủ chính xác. Optimization có thể gây phức tạp không cần thiết (`.count()` API của Supabase Flutter khác syntax). Follow-up nếu cần.

---

## Gotchas & Decisions

- `docs/plans/` bị gitignore — design docs lưu ở đây không được commit vào repo
- `fl_chart 0.69.x` — `barWidth` và `dotData` là defaults, setting explicit sẽ trigger `avoid_redundant_argument_values` lint
- Selection mode trong TemplatesPage là **computed getter** (`_selectedIds.isNotEmpty`), không phải `bool` state — đây là nguyên nhân gốc của bug circular dependency
- `jobsToday` dùng `!isBefore(todayStart)` (inclusive) thay vì `isAfter(todayStart)` (exclusive) để include jobs tạo đúng midnight

---

## Follow-up Items

- [ ] Tách `user_detail_page.dart` (594 dòng) thành sub-files để comply CLAUDE.md 300-line limit
- [ ] Tests cho `analyticsStatsProvider` (7-day aggregation, zero-fill, top-models sort)
- [ ] DB-side count query cho `userGenerationCount` provider (perf optimization)
