# Suggested Commands

## Flutter Development

### Install & Setup
```bash
flutter pub get                    # Install dependencies
dart run build_runner build        # Generate code (Freezed, Riverpod, go_router)
```

### Run App
```bash
flutter run                        # Run on default device
flutter run -d chrome              # Run on Chrome
flutter run -d windows             # Run on Windows
flutter run -d emulator-5554       # Run on Android emulator
```

### Code Quality
```bash
flutter analyze                    # Static analysis
dart format .                      # Format code
```

### Testing
```bash
flutter test                      # Run all tests
flutter test --coverage           # Run with coverage
flutter test test/path/to/test.dart # Run specific test
```

### Build
```bash
flutter build apk                 # Build Android APK
flutter build web                 # Build Web
flutter build windows             # Build Windows
```

## Supabase (Backend)

### Local Development
```bash
supabase start                    # Start local Supabase
supabase db reset                 # Reset local database
supabase db push                  # Push migrations
```

### Edge Functions
```bash
supabase functions serve generate-image    # Serve function locally
supabase functions deploy generate-image   # Deploy function
```

## Git
```bash
git status                        # Check status
git add .                         # Stage all
git commit -m "feat: message"    # Commit with conventional message
git push                          # Push to remote
```

## Windows Specific
- Use `powershell` or `bash` (Git Bash / WSL)
- Paths use forward slashes `/` in commands
- Use `//F //IM` for taskkill flags
