# Riverpod State Management

## Riverpod Setup

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    required String email,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

// Simple provider
final userProvider = Provider<User>((ref) {
  return User(id: '1', name: 'John', email: 'john@example.com');
});

// Future provider
final userListProvider = FutureProvider<List<User>>((ref) async {
  final response = await dio.get('/users');
  return (response.data as List).map((e) => User.fromJson(e)).toList();
});

// StateNotifier provider for complex state
class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final Dio _dio;

  UserNotifier(this._dio) : super(const AsyncValue.data(null));

  Future<void> fetchUser(String id) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get('/users/$id');
      state = AsyncValue.data(User.fromJson(response.data));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateUser(User user) async {
    state = const AsyncValue.loading();
    try {
      await _dio.put('/users/${user.id}', data: user.toJson());
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
  return UserNotifier(ref.read(dioProvider));
});

// Dependency injection
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    headers: {'Authorization': 'Bearer ${ref.read(tokenProvider)}'},
  ));
  return dio;
});

final tokenProvider = StateProvider<String?>((ref) => null);
```

## Common Patterns

```dart
// Watching multiple providers
final combinedProvider = Provider<String>((ref) {
  final user = ref.watch(userProvider);
  final settings = ref.watch(settingsProvider);
  return '${user.name} - ${settings.theme}';
});

// Select for granular rebuilds
final userNameProvider = Provider<String>((ref) {
  // Only rebuilds when user.name changes, not when whole user object changes
  return ref.watch(userProvider.select((user) => user.name));
});

// Ref for one-time reads
void someFunction(WidgetRef ref) {
  final user = ref.read(userProvider);
  ref.read(analyticsProvider).trackEvent('view', { 'userId': user.id });
}

// Family providers for parameterized data
final userByIdProvider = FutureProvider.family<User, String>((ref, id) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/users/$id');
  return User.fromJson(response.data);
});

// Computed providers
final userCountProvider = Provider<int>((ref) {
  return ref.watch(userListProvider).whenOrNull(
    data: (users) => users.length,
  ) ?? 0;
});
```

## Best Practices

- Always use `ref.watch` for reactive state in widgets
- Use `ref.read` only in callbacks (onPressed, useEffect)
- Prefer `select` for specific fields to avoid unnecessary rebuilds
- Use `@freezed` for immutable data classes
- Keep providers focused and single-purpose
- Use `family` for parameterized providers
- Handle loading/error states explicitly