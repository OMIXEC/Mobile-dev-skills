---
name: refactor-swift-to-flutter
description: >
  Convert existing Swift/iOS code to Flutter/Dart. Transforms SwiftUI views,
  Combine publishers, URLSession APIs, and Core Data models to equivalent
  Flutter patterns (Riverpod, GoRouter, Dio, Hive/SQLite). Use when user
  has Swift code they want to port to Flutter, mentions "porting iOS to
  Android", "migrate Swift to Dart", or asks to "convert this Swift code".
---

# Refactor Swift to Flutter

## Overview

Transform Swift/iOS codebases into Flutter equivalents with equivalent functionality, architecture, and patterns.

## When to Use

- User wants to port an existing iOS app to Flutter
- User asks to "convert Swift to Flutter"
- User has Swift code and wants equivalent Dart
- User mentions "porting iOS to Android"
- User asks to "rewrite this in Flutter"

## Swift to Dart Mapping

### Data Types

| Swift | Dart |
|-------|------|
| `String` | `String` |
| `Int` | `int` |
| `Double` | `double` |
| `Bool` | `bool` |
| `[Type]` | `List<Type>` |
| `[Key: Value]` | `Map<Key, Value>` |
| `Optional<Type>?` | `Type?` |
| `enum` | `enum` (same) |
| `struct` | `class` (with final fields) |
| `class` | `class` |
| `protocol` | `abstract class` or `mixin` |

### Common Conversions

```swift
// Swift
struct User {
  let id: UUID
  var name: String
  var email: String?
}
```

```dart
// Dart
class User {
  final String id;
  final String name;
  final String? email;

  User({required this.id, required this.name, this.email});
}
```

### SwiftUI to Flutter Widgets

```swift
// SwiftUI
struct ContentView: View {
  @State private var count = 0
  
  var body: some View {
    VStack {
      Text("Count: \(count)")
      Button("Increment") {
        count += 1
      }
    }
  }
}
```

```dart
// Flutter
class ContentView extends StatefulWidget {
  const ContentView({super.key});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Count: $_count'),
        ElevatedButton(
          onPressed: () => setState(() => _count++),
          child: const Text('Increment'),
        ),
      ],
    );
  }
}
```

### Combine to Riverpod

```swift
// Swift Combine
class UserViewModel: ObservableObject {
  @Published var user: User?
  @Published var isLoading = false
  
  func fetchUser() {
    isLoading = true
    networkService.fetchUser()
      .receive(on: DispatchQueue.main)
      .sink { user in
        self.user = user
        self.isLoading = false
      }
  }
}
```

```dart
// Dart Riverpod
class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final NetworkService _networkService;

  UserNotifier(this._networkService) : super(const AsyncValue.data(null));

  Future<void> fetchUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _networkService.fetchUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
  return UserNotifier(ref.read(networkServiceProvider));
});
```

### URLSession to Dio

```swift
// Swift URLSession
class NetworkService {
  func fetch<T: Decodable>(_ type: T.Type, from endpoint: String) async throws -> T {
    let url = URL(string: "https://api.example.com\(endpoint)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(T.self, from: data)
  }
}
```

```dart
// Flutter Dio
class NetworkService {
  final Dio _dio;
  
  Future<T> fetch<T>(String endpoint) async {
    final response = await _dio.get('https://api.example.com$endpoint');
    return response.data as T;
  }
}

final networkServiceProvider = Provider<NetworkService>((ref) {
  return NetworkService(Dio());
});
```

### Core Data to Hive/SQLite

```swift
// Swift Core Data
@Entity
class UserEntity {
  @Attribute(.unique) var id: UUID
  var name: String
  var email: String
}
```

```dart
// Dart Hive
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  late String name;
  
  @HiveField(2)
  String? email;
}
```

## Conversion Process

1. **Analyze Swift code** - Identify architecture (MVVM, VIPER), patterns used
2. **Map dependencies** - Find Swift-only libraries and find Flutter equivalents
3. **Convert data models** - Transform Swift structs/classes to Dart
4. **Convert views** - SwiftUI -> Flutter widgets
5. **Convert state management** - Combine -> Riverpod
6. **Convert networking** - URLSession -> Dio
7. **Convert persistence** - Core Data -> Hive/SQLite
8. **Test equivalence** - Ensure same behavior

## Best Practices

- Preserve original logic and behavior
- Use Dart/Flutter idioms, don't just translate literally
- Use freezed for data classes
- Use Riverpod for state (not setState)
- Use GoRouter for navigation
- Handle async/await properly
- Preserve error handling patterns
- Test both implementations for parity