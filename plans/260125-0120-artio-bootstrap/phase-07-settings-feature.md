---
title: "Phase 7: Settings Feature"
status: pending
effort: 3h
---

# Phase 7: Settings Feature

## Context Links

- [flutter_localizations](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
- [shared_preferences](https://pub.dev/packages/shared_preferences)

## Overview

**Priority**: P2 (Medium)
**Status**: pending
**Effort**: 3h

User settings including theme mode, language, notification preferences, account management, and app info.

## Key Insights

1. Settings persisted locally with `shared_preferences` - no backend storage needed
2. Theme mode changes require app-wide rebuild via `ThemeMode` state management
3. Account deletion requires email confirmation to prevent accidental data loss
4. Language switching requires MaterialApp rebuild with new `locale` parameter

## Requirements

### Functional
- Theme mode toggle (light/dark/system)
- Language selection (English only at launch)
- Notification preferences
- Account management (email, password)
- Delete account (Email confirmation required)
- App info and legal links
- Sign out

### Non-Functional
- Settings persisted locally
- Immediate UI update on change

## Architecture

### Feature Structure
```
lib/features/settings/
├── domain/
│   ├── entities/
│   │   └── app_settings.dart
│   └── repositories/
│       └── i_settings_repository.dart
├── data/
│   ├── data_sources/
│   │   └── settings_local_data_source.dart
│   └── repositories/
│       └── settings_repository_impl.dart
└── presentation/
    ├── providers/
    │   └── settings_provider.dart
    ├── pages/
    │   ├── settings_page.dart
    │   └── account_settings_page.dart
    └── widgets/
        ├── settings_tile.dart
        └── theme_selector.dart
```

## Related Code Files

### Files to Create
- `lib/features/settings/data/repositories/settings_repository.dart`
- `lib/features/settings/domain/settings_notifier.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/settings/presentation/pages/account_settings_page.dart`
- `lib/features/settings/presentation/widgets/settings_tile.dart`

### Files to Modify
- `lib/main.dart` - Apply theme mode from settings
- `lib/core/router/app_router.dart` - Add settings routes
- `pubspec.yaml` - Add dependencies (shared_preferences, package_info_plus, url_launcher)

### Files to Delete
- None

### Database Schema
N/A - Settings stored locally with SharedPreferences

## Implementation Steps

### 1. Settings Repository
```dart
// lib/features/settings/data/repositories/settings_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

part 'settings_repository.g.dart';

@riverpod
SettingsRepository settingsRepository(SettingsRepositoryRef ref) =>
    SettingsRepository();

class SettingsRepository {
  static const _themeKey = 'theme_mode';
  static const _localeKey = 'locale';
  static const _notificationsKey = 'notifications_enabled';

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<Locale?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_localeKey);
    return value != null ? Locale(value) : null;
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }
}
```

### 2. Settings Page
```dart
// lib/features/settings/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/domain/auth_notifier.dart';
import '../../../subscription/domain/subscription_notifier.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final subscription = ref.watch(subscriptionNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Account Section
          const _SectionHeader('Account'),
          SettingsTile(
            icon: Icons.person_outline,
            title: 'Account Settings',
            onTap: () => context.push('/settings/account'),
          ),
          SettingsTile(
            icon: Icons.star_outline,
            title: 'Subscription',
            subtitle: subscription.value?.isPro == true ? 'Pro' : 'Free',
            onTap: () => context.push('/subscription'),
          ),

          const Divider(),

          // Appearance Section
          const _SectionHeader('Appearance'),
          SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Theme',
            subtitle: _themeModeLabel(themeMode),
            onTap: () => _showThemeDialog(context, ref),
          ),
          SettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () => _showLanguageDialog(context, ref),
          ),

          const Divider(),

          // Notifications Section
          const _SectionHeader('Notifications'),
          SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            trailing: Switch(
              value: true, // TODO: from settings state
              onChanged: (value) {
                // TODO: update notifications
              },
            ),
          ),

          const Divider(),

          // About Section
          const _SectionHeader('About'),
          SettingsTile(
            icon: Icons.info_outline,
            title: 'About Artio',
            onTap: () => _showAboutDialog(context),
          ),
          SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () => _openUrl('https://artio.app/terms'),
          ),
          SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () => _openUrl('https://artio.app/privacy'),
          ),

          const Divider(),

          // Sign Out
          SettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            titleColor: Theme.of(context).colorScheme.error,
            onTap: () => _confirmSignOut(context, ref),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ThemeMode.values.map((mode) {
            return RadioListTile<ThemeMode>(
              title: Text(_themeModeLabel(mode)),
              value: mode,
              groupValue: ref.read(themeModeNotifierProvider),
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeNotifierProvider.notifier).setThemeMode(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final languages = [
      (const Locale('en'), 'English'),
      (const Locale('vi'), 'Tiếng Việt'),
      (const Locale('ja'), '日本語'),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return ListTile(
              title: Text(lang.$2),
              onTap: () {
                // TODO: set locale
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _showAboutDialog(BuildContext context) async {
    final info = await PackageInfo.fromPlatform();
    if (context.mounted) {
      showAboutDialog(
        context: context,
        applicationName: 'Artio',
        applicationVersion: '${info.version} (${info.buildNumber})',
        applicationLegalese: '© 2026 Artio. All rights reserved.',
      );
    }
  }

  void _openUrl(String url) {
    // TODO: launch URL
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
```

### 3. Account Settings Page
```dart
// lib/features/settings/presentation/pages/account_settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/domain/auth_notifier.dart';
import '../widgets/settings_tile.dart';

class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: [
          // Profile Info
          ListTile(
            leading: CircleAvatar(
              backgroundImage: user?.userMetadata?['avatar_url'] != null
                  ? NetworkImage(user!.userMetadata!['avatar_url'])
                  : null,
              child: user?.userMetadata?['avatar_url'] == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(user?.userMetadata?['name'] ?? 'User'),
            subtitle: Text(user?.email ?? ''),
          ),
          const Divider(),

          SettingsTile(
            icon: Icons.email_outlined,
            title: 'Change Email',
            onTap: () => _showChangeEmailDialog(context),
          ),
          SettingsTile(
            icon: Icons.lock_outlined,
            title: 'Change Password',
            onTap: () => _showChangePasswordDialog(context),
          ),

          const Divider(),

          SettingsTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            titleColor: Theme.of(context).colorScheme.error,
            onTap: () => _confirmDeleteAccount(context, ref),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'New Email',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.updateUser(
                  UserAttributes(email: controller.text.trim()),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Verification email sent')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New Password',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.updateUser(
                  UserAttributes(password: controller.text),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is permanent and cannot be undone. All your data will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () async {
              // TODO: Implement account deletion via Edge Function
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
```

### 4. Settings Tile Widget
```dart
// lib/features/settings/presentation/widgets/settings_tile.dart
import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: titleColor),
      title: Text(
        title,
        style: titleColor != null ? TextStyle(color: titleColor) : null,
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
```

## Todo List

- [ ] Create settings_repository.dart
- [ ] Create settings_page.dart
- [ ] Create account_settings_page.dart
- [ ] Create settings_tile.dart widget
- [ ] Implement theme mode persistence
- [ ] Add package_info_plus dependency
- [ ] Add url_launcher for external links
- [ ] Add routes for settings pages
- [ ] Implement locale switching (optional for MVP)
- [ ] Test all settings flows

## Success Criteria

- [ ] Theme mode changes immediately and persists
- [ ] Sign out clears session and redirects
- [ ] Account settings dialogs work
- [ ] About dialog shows correct version
- [ ] URL launcher opens external links (Terms, Privacy)

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| SharedPreferences data loss | Low | Low | Settings have sensible defaults |
| Theme mode sync delay | Medium | Low | Immediate UI update via state management |
| Account deletion without confirmation | Low | High | Require email confirmation dialog |
| Password change without verification | Medium | Medium | Supabase auth handles verification |

## Security Considerations

- Password changes require Supabase auth validation
- Email updates send verification link to new address
- Account deletion should cascade delete all user data (handled by Supabase RLS ON DELETE CASCADE)
- No sensitive data stored in SharedPreferences (only theme/locale preferences)
- Sign out clears all local session data

## Next Steps

→ Phase 8: Admin App
