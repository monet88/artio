# Research: Riverpod + Freezed + Code Generation

## Summary

Research on Flutter state management with Riverpod 2.x, riverpod_generator, and Freezed for immutable data classes.

## Key Findings

### Riverpod Generator (riverpod_annotation + riverpod_generator)

**Version**: riverpod_generator 2.6.x

**Benefits**:
- Automatic provider type inference based on return type
- Cleaner syntax with `@riverpod` annotation
- Family providers generated automatically from function parameters
- Better tree-shaking and compile-time safety

**Syntax**:
```dart
// Simple provider
@riverpod
String example(Ref ref) => 'foo';

// Async provider
@riverpod
Future<User> user(Ref ref, int userId) async {
  return await repository.fetchUser(userId);
}

// Notifier (stateful)
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
}
```

**Generated Code**:
- Creates `xxxProvider` variable
- Handles disposal and caching
- Family parameters typed correctly

### AsyncNotifier Pattern

**Best for**: Data that needs fetching + mutation

```dart
@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<User> build() async {
    return await _fetchUser();
  }

  Future<void> updateName(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _updateUser(name));
  }
}
```

**Lifecycle**:
1. Created → Building (ref.watch called) → Data/Error/Loading

### Freezed Integration

**Purpose**: Immutable data classes with:
- Value equality (==, hashCode)
- copyWith for immutable updates
- JSON serialization
- Union types (sealed classes)

**Syntax**:
```dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    String? avatarUrl,
    @Default(0) int credits,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

**Union Types**:
```dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthStateInitial;
  const factory AuthState.authenticated(User user) = AuthStateAuthenticated;
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;
}
```

### Build Configuration

**build.yaml**:
```yaml
targets:
  $default:
    builders:
      freezed:
        options:
          union_key: "type"
          union_value_case: pascal
```

**Commands**:
```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode
dart run build_runner watch --delete-conflicting-outputs
```

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

dev_dependencies:
  build_runner: ^2.4.14
  riverpod_generator: ^2.6.3
  freezed: ^2.5.8
  json_serializable: ^6.9.2
```

## Best Practices

1. Use `ref.watch` for reactive updates, `ref.read` for one-time reads
2. Use `ref.invalidateSelf()` to trigger rebuild
3. Use `AsyncValue.guard()` for error handling in async operations
4. Keep providers small and focused
5. Use Freezed for all data models
6. Define providers in same file as the class they provide

## References

- https://riverpod.dev/docs/concepts/about_code_generation
- https://pub.dev/packages/freezed
- https://zread.ai/rrousselGit/riverpod
