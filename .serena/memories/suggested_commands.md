# Suggested Commands

## Dependencies
```bash
flutter pub get
```

## Code Generation (after modifying Freezed/Riverpod annotations)
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Watch Mode (auto-regenerate)
```bash
dart run build_runner watch
```

## Run App
```bash
flutter run                # Default device
flutter run -d chrome      # Web
flutter run -d windows     # Windows
```

## Compile Check (run after modifying any .dart file)
```bash
flutter analyze
```

## Format
```bash
dart format .
```

## Testing
```bash
flutter test                           # All tests
flutter test test/path/to/test.dart    # Single file
flutter test --coverage                # With coverage
```

## Integration Tests
```bash
flutter test integration_test/template_e2e_test.dart
```

## Git (Windows)
```bash
git status
git add <files>
git commit -m "feat: description"
git push
git log --oneline -10
```

## System Utils (Windows)
```bash
dir              # list directory (or ls in Git Bash)
type <file>      # view file contents (or cat in Git Bash)
where <cmd>      # find executable (or which in Git Bash)
```
