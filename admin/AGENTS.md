# Admin Dashboard

Separate Flutter project for template management. Web-focused. Shares Supabase backend with main app.

## Purpose

- Create/edit AI templates (presets, prompts, input fields)
- Manage template visibility and ordering
- Admin authentication (separate from user auth)

## Structure

```
admin/
├── lib/
│   ├── features/
│   │   ├── auth/              # Admin-only authentication
│   │   └── templates/         # Template CRUD
│   └── main.dart
├── web/                       # Web-specific config
└── pubspec.yaml               # Separate dependencies
```

## Where to Look

| Task | Location |
|------|----------|
| Template editor | `lib/features/templates/presentation/pages/template_editor_page.dart` |
| Admin auth | `lib/features/auth/providers/admin_auth_provider.dart` |
| Template list | `lib/features/templates/presentation/pages/template_list_page.dart` |

## Key Differences from Main App

| Aspect | Main App | Admin |
|--------|----------|-------|
| Target | Mobile + Web | Web only |
| Auth | User OAuth | Admin credentials |
| Features | Browse, generate | Create, edit |
| Dependencies | RevenueCat, AdMob | Minimal |

## Commands

```bash
cd admin
flutter run -d chrome          # Run admin dashboard
flutter build web              # Build for deployment
```

## Notes

- Runs on port 5000 by default (main app on 3000)
- Template changes reflect immediately in main app
- Large file: `template_editor_page.dart` (397 lines) - consider splitting
