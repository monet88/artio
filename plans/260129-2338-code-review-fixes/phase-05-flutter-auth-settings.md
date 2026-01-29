# Phase 05: Flutter Code Quality - Auth & Settings

## Parallelization Info

| Property | Value |
|----------|-------|
| Group | C (Flutter) |
| Can Run With | Phases 06, 07, 08 |
| Blocked By | Group B (Phases 03, 04) |
| Blocks | Group E (Phases 10, 11) |

## File Ownership (Exclusive)

- `lib/features/auth/domain/entities/user_model.dart`
- `lib/features/settings/ui/settings_screen.dart`
- `lib/features/auth/presentation/view_models/auth_view_model.dart`

## Priority: MEDIUM

**Issues**:
1. `DateTime.parse()` can throw on malformed strings - needs try/catch
2. Settings screen calls Supabase auth directly instead of using AuthViewModel

## Implementation Steps

### Issue 1: DateTime Parse Safety in UserModel

**File**: `lib/features/auth/domain/entities/user_model.dart`

**Current** (lines 34-37):
```dart
premiumExpiresAt: profile?['premium_expires_at'] != null
    ? DateTime.parse(profile!['premium_expires_at'])
    : null,
createdAt: user.createdAt.isNotEmpty ? DateTime.parse(user.createdAt) : null,
```

**Fix**: Add safe parsing helper
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// Safely parse DateTime, returns null on failure
DateTime? _tryParseDateTime(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return DateTime.parse(value);
  } catch (_) {
    return null;
  }
}

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? displayName,
    String? avatarUrl,
    @Default(0) int credits,
    @Default(false) bool isPremium,
    DateTime? premiumExpiresAt,
    DateTime? createdAt,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromSupabaseUser(
    User user, {
    Map<String, dynamic>? profile,
  }) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      displayName: profile?['display_name'] ?? user.userMetadata?['name'],
      avatarUrl: profile?['avatar_url'] ?? user.userMetadata?['avatar_url'],
      credits: profile?['credits'] ?? 0,
      isPremium: profile?['is_premium'] ?? false,
      premiumExpiresAt: _tryParseDateTime(profile?['premium_expires_at']),
      createdAt: _tryParseDateTime(user.createdAt),
    );
  }
}
```

### Issue 2: Route Auth Through AuthViewModel

**File**: `lib/features/settings/ui/settings_screen.dart`

**Current** (line 35, 75):
```dart
await ref.read(supabaseClientProvider).auth.resetPasswordForEmail(email);
// ...
await ref.read(supabaseClientProvider).auth.signOut();
```

**Fix**: Use AuthViewModel instead

First, check if AuthViewModel has these methods. If not, add them:

```dart
// In auth_view_model.dart (if methods missing)
Future<void> resetPassword(String email) async {
  await _authRepository.resetPassword(email);
}

Future<void> signOut() async {
  await _authRepository.signOut();
  state = const AuthState.unauthenticated();
}
```

Then update settings_screen.dart:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:artio/features/auth/presentation/view_models/auth_view_model.dart';
import 'package:artio/features/settings/ui/widgets/theme_switcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String? _version;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    }
  }

  Future<void> _resetPassword(BuildContext context, String email) async {
    try {
      await ref.read(authViewModelProvider.notifier).resetPassword(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent to $email')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending reset email: $e')),
        );
      }
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await ref.read(authViewModelProvider.notifier).signOut();
        // Router will handle redirection via auth guard
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error signing out: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final email = authState.maybeMap(
      authenticated: (s) => s.user.email,
      orElse: () => 'Unknown',
    );

    // ... rest unchanged
  }

  // ... _buildSectionHeader unchanged
}
```

## Success Criteria

- [ ] `DateTime.parse` wrapped in try/catch, returns null on failure
- [ ] Settings screen uses `AuthViewModel` for auth operations
- [ ] No direct Supabase client access in presentation layer
- [ ] Code compiles without errors
- [ ] Run `flutter analyze` - no new warnings

## Conflict Prevention

- Only this phase modifies `user_model.dart` and `settings_screen.dart`
- May need to coordinate with AuthViewModel if adding new methods

## Post-Implementation

After modifying `user_model.dart`:
```bash
dart run build_runner build --delete-conflicting-outputs
```
