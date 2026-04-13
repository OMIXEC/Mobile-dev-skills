---
name: flutter-sdk-to-swift
description: >
  Convert Flutter/Dart code to Swift/iOS native code. Transforms Riverpod
  providers, GoRouter navigation, Dio HTTP calls, and Hive/SQLite persistence
  to Swift equivalents (Combine, SwiftUI navigation, URLSession, Core Data).
  Use when user has Flutter code they want to port to iOS, mentions "porting
  Android to iOS", "migrate Dart to Swift", or asks to "convert this Flutter
  code to Swift".
---

# Refactor Flutter to Swift

## Overview

Transform Flutter/Dart codebases into Swift/iOS equivalents with equivalent functionality, architecture, and patterns.

## When to Use

- User wants to port an existing Flutter app to iOS
- User asks to "convert Flutter to Swift"
- User has Dart code and wants equivalent Swift
- User mentions "porting Android to iOS"
- User asks to "rewrite this in Swift"

## Dart to Swift Mapping

### Data Types

| Dart | Swift |
|------|-------|
| `String` | `String` |
| `int` | `Int` |
| `double` | `Double` |
| `bool` | `Bool` |
| `List<Type>` | `[Type]` |
| `Map<Key, Value>` | `[Key: Value]` |
| `Type?` | `Type?` |
| `enum` | `enum` (same) |
| `class` | `class` or `struct` |
| `abstract class` | `protocol` |

### Common Conversions

```dart
// Dart
class User {
  final String id;
  final String name;
  final String? email;

  User({required this.id, required this.name, this.email});
}
```

```swift
// Swift
struct User: Codable, Identifiable {
  let id: String
  var name: String
  var email: String?
}
```

### Flutter Widget to SwiftUI

```dart
// Flutter
class ContentView extends StatelessWidget {
  const ContentView({super.key});

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

### Riverpod to Combine

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

```swift
// Swift Combine
class UserViewModel: ObservableObject {
  @Published var user: User?
  @Published var isLoading = false
  @Published var error: Error?

  private let networkService: NetworkService

  init(networkService: NetworkService) {
    self.networkService = networkService
  }

  @MainActor
  func fetchUser() async {
    isLoading = true
    error = nil

    do {
      user = try await networkService.fetchUser()
    } catch {
      self.error = error
    }

    isLoading = false
  }
}
```

### Dio to URLSession

```dart
// Dart Dio
class NetworkService {
  final Dio _dio;
  
  Future<User> fetchUser() async {
    final response = await _dio.get('/users/1');
    return User.fromJson(response.data);
  }
}
```

```swift
// Swift URLSession
class NetworkService {
  static let shared = NetworkService()
  
  func fetchUser() async throws -> User {
    let url = URL(string: "https://api.example.com/users/1")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(User.self, from: data)
  }
}
```

### Hive to Core Data

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

```swift
// Swift Core Data
@objc(UserEntity)
public class UserEntity: NSManagedObject {
  @NSManaged public var id: UUID
  @NSManaged public var name: String
  @NSManaged public var email: String?
}
```

## Conversion Process

1. **Analyze Dart code** - Identify architecture (Riverpod, BLoC), patterns used
2. **Map dependencies** - Find Flutter-only libraries and find Swift equivalents
3. **Convert data models** - Dart classes to Swift structs/classes
4. **Convert views** - Flutter widgets to SwiftUI views
5. **Convert state management** - Riverpod -> Combine
6. **Convert networking** - Dio -> URLSession
7. **Convert persistence** - Hive/SQLite -> Core Data
8. **Test equivalence** - Ensure same behavior

## Best Practices

- Preserve original logic and behavior
- Use Swift idioms, don't just translate literally
- Use Codable for data classes
- Use Combine for reactive state
- Use SwiftUI for views
- Handle async/await properly
- Preserve error handling patterns
- Test both implementations for parity