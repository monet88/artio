# Artio Runbook

> Operational procedures for debugging, validation, and recovery in the Artio Flutter project.

---

## Quick Commands

### Flutter Project Health

**Check build status:**
```bash
# Static analysis
flutter analyze

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Code generation
dart run build_runner build --delete-conflicting-outputs
```

**Run app on different platforms:**
```bash
# iOS/Android (default device)
flutter run

# Web
flutter run -d chrome

# Windows
flutter run -d windows

# All platforms debug
flutter run -d all
```

### Git Status Check

```bash
# Current git status
git status

# Recent commits
git log --oneline -10

# Current branch
git branch --show-current

# View file at commit
git show <commit-hash>:path/to/file
```

---

## Build Verification

### Code Quality Checks

Before committing:

1. **Lint clean:**
   ```bash
   flutter analyze  # Must report 0 errors
   ```

2. **Tests pass:**
   ```bash
   flutter test                    # All unit/widget tests
   flutter test --coverage         # Coverage report
   ```

3. **Code gen up to date:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   git status  # Should show no .dart/.freezed/.g.dart changes
   ```

4. **Format code:**
   ```bash
   dart format .
   ```

### Pre-Commit Checklist

- [ ] `flutter analyze` reports 0 errors
- [ ] All tests pass (`flutter test`)
- [ ] Code generation run (`build_runner build`)
- [ ] No secrets committed (.env files excluded)
- [ ] Commit message follows conventional format
- [ ] No debug prints or TODOs left in code

---

## Debugging Procedures

### Common Issues

#### "Build failed: Unable to generate..."

**Cause:** `build_runner` needs to regenerate Freezed/Riverpod artifacts

**Fix:**
```bash
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
flutter pub get
flutter analyze
```

#### "Tests failing with 'Provider not found'"

**Cause:** Missing mock setup or provider dependency

**Fix:**
1. Check test fixtures in `test/fixtures/`
2. Verify mock setup in `setUp()` block
3. Ensure `ProviderContainer` initialized with mocks
4. Run: `flutter test <test_file> -v` for detailed output

#### "Supabase connection fails in tests"

**Cause:** Missing environment or mock Supabase client

**Fix:**
1. Verify `.env` file exists with test credentials
2. Check `MockSupabaseClient` in test setup
3. Use `supabaseProvider` override in tests:
   ```dart
   container.listen(supabaseProvider, (_, __) => mockSupabase);
   ```

#### "Hot reload not working"

**Cause:** Code changes require full rebuild (Freezed/Riverpod changes)

**Fix:**
```bash
flutter clean
flutter pub get
flutter run
```

### Navigation Debugging

**Check current route:**
```bash
# Add logging in AppRouter
print('Current location: ${router.routerDelegate.currentConfiguration.location}');
```

**Verify auth guards:**
```bash
# Check auth state manually
final user = supabase.auth.currentUser;
print('Authenticated: $user');
```

---

## Supabase Edge Function Testing

### Local Testing

```bash
# Install Supabase CLI
supabase start  # Run local Supabase

# Invoke function locally
supabase functions invoke generate-image --local
```

### Production Deployment

```bash
# Deploy Edge Function
supabase functions deploy generate-image

# Check logs
supabase functions logs generate-image
```

### Database Migrations

```bash
# Create new migration
supabase migration new <migration_name>

# Apply migrations
supabase db push

# Reset to clean state (dev only)
supabase db reset
```

---

## Performance Debugging

### Measure widget build time

```dart
// Wrap widget in performance monitor
Stopwatch sw = Stopwatch()..start();
// ... build code ...
print('Build time: ${sw.elapsedMilliseconds}ms');
```

### Check Riverpod state changes

```bash
# Add logging to providers
@riverpod
MyState myState(MyStateRef ref) {
  print('myState rebuilding');
  return MyState();
}
```

### Memory profiling

```bash
# Use Flutter DevTools
flutter pub global activate devtools
devtools

# Check memory in Android Studio Profiler
```

---

## Commit Guidelines

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Format
<type>: <description>

# Examples
git commit -m "feat: add text-to-image generation UI"
git commit -m "fix: resolve null pointer in gallery realtime stream"
git commit -m "refactor: extract button themes to design_system"
git commit -m "docs: update roadmap Phase 6 status"
git commit -m "test: add gallery repository tests"
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `test`, `chore`

---

## References

- **Development Roadmap**: `docs/development-roadmap.md`
- **Code Standards**: `docs/code-standards.md`
- **System Architecture**: `docs/system-architecture.md`
- **Flutter Docs**: https://docs.flutter.dev
- **Supabase Docs**: https://supabase.com/docs
- **Riverpod Docs**: https://riverpod.dev
