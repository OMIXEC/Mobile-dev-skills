# Swift to Flutter Conversion Reference

## Complete Conversion Examples

### MVVM Architecture

```swift
// Swift - ViewModel
class UserViewModel: ObservableObject {
  @Published var users: [User] = []
  @Published var isLoading = false
  @Published var error: Error?

  private let userRepository: UserRepository

  init(userRepository: UserRepository) {
    self.userRepository = userRepository
  }

  func loadUsers() {
    isLoading = true
    Task {
      do {
        users = try await userRepository.getAll()
        isLoading = false
      } catch {
        self.error = error
        isLoading = false
      }
    }
  }
}
```

```dart
// Flutter - Notifier (Riverpod)
class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(UserState());

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true);
    try {
      final users = await _repository.getAll();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e, st) {
      state = state.copyWith(error: e, isLoading: false);
    }
  }
}

class UserState {
  final List<User> users;
  final bool isLoading;
  final Error? error;

  UserState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    List<User>? users,
    bool? isLoading,
    Error? error,
  }) {
    return UserState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref.read(userRepositoryProvider));
});
```

### SwiftUI to Flutter Widgets

```swift
// Swift - List View
struct UserListView: View {
  @ObservedObject var viewModel: UserViewModel
  
  var body: some View {
    NavigationView {
      List(viewModel.users) { user in
        NavigationLink(destination: UserDetailView(user: user)) {
          UserRowView(user: user)
        }
      }
      .navigationTitle("Users")
      .onAppear {
        viewModel.loadUsers()
      }
    }
  }
}
```

```dart
// Flutter - List View
class UserListView extends ConsumerWidget {
  const UserListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: userState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userState.users.length,
              itemBuilder: (context, index) {
                final user = userState.users[index];
                return ListTile(
                  title: Text(user.name),
                  onTap: () => context.push('/user/${user.id}'),
                );
              },
            ),
    );
  }
}
```

### Navigation

```swift
// Swift - NavigationStack (iOS 16+)
struct ContentView: View {
  var body: some View {
    NavigationStack {
      List {
        NavigationLink("Users", value: "users")
        NavigationLink("Settings", value: "settings")
      }
      .navigationDestination(for: String.self) { destination in
        switch destination {
        case "users": return UsersView()
        case "settings": return SettingsView()
        default: return Text("Unknown")
        }
      }
    }
  }
}
```

```dart
// Flutter - GoRouter
final router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/users',
          builder: (context, state) => const UsersView(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (context, state) => UserDetailView(
                id: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsView(),
        ),
      ],
    ),
  ],
);
```

### Async/Await

```swift
// Swift - async/await
func fetchUsers() async throws -> [User] {
  let url = URL(string: "https://api.example.com/users")!
  let (data, _) = try await URLSession.shared.data(from: url)
  return try JSONDecoder().decode([User].self, from: data)
}

// Usage
Task {
  do {
    let users = try await fetchUsers()
    print(users)
  } catch {
    print(error)
  }
}
```

```dart
// Dart - async/await
Future<List<User>> fetchUsers() async {
  final response = await dio.get('https://api.example.com/users');
  return (response.data as List).map((e) => User.fromJson(e)).toList();
}

// Usage
void loadUsers() async {
  try {
    final users = await fetchUsers();
    print(users);
  } catch (e) {
    print(e);
  }
}
```

### Dependency Injection

```swift
// Swift - Dependency Injection
protocol NetworkServiceProtocol {
  func fetch<T: Decodable>(_ type: T.Type, from: String) async throws -> T
}

class NetworkService: NetworkServiceProtocol {
  // ...
}

class UserViewModel {
  private let networkService: NetworkServiceProtocol
  
  init(networkService: NetworkServiceProtocol) {
    self.networkService = networkService
  }
}

// Usage
let viewModel = UserViewModel(networkService: NetworkService())
```

```dart
// Flutter - Riverpod DI
abstract class NetworkServiceProtocol {
  Future<T> fetch<T>(String endpoint);
}

class NetworkService implements NetworkServiceProtocol {
  final Dio _dio;
  
  NetworkService(this._dio);
  
  @override
  Future<T> fetch<T>(String endpoint) async {
    final response = await _dio.get(endpoint);
    return response.data as T;
  }
}

final networkServiceProvider = Provider<NetworkServiceProtocol>((ref) {
  return NetworkService(ref.read(dioProvider));
});

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref.read(networkServiceProvider));
});
```

### Error Handling

```swift
// Swift - Result type
enum NetworkError: Error {
  case invalidURL
  case noData
  case decodingError
  case serverError(Int)
}

func fetchUsers() async throws -> [User] {
  guard let url = URL(string: "https://api.example.com/users") else {
    throw NetworkError.invalidURL
  }
  
  let (data, response) = try await URLSession.shared.data(from: url)
  
  guard let httpResponse = response as? HTTPURLResponse else {
    throw NetworkError.noData
  }
  
  guard (200...299).contains(httpResponse.statusCode) else {
    throw NetworkError.serverError(httpResponse.statusCode)
  }
  
  do {
    return try JSONDecoder().decode([User].self, from: data)
  } catch {
    throw NetworkError.decodingError
  }
}
```

```dart
// Dart - Exception handling
class NetworkException implements Exception {
  final String message;
  final int? statusCode;

  NetworkException(this.message, {this.statusCode});

  @override
  String toString() => 'NetworkException: $message (status: $statusCode)';
}

Future<List<User>> fetchUsers() async {
  try {
    final response = await dio.get('https://api.example.com/users');
    
    if (response.statusCode != null && (response.statusCode! < 200 || response.statusCode! > 299)) {
      throw NetworkException('Server error', statusCode: response.statusCode);
    }
    
    return (response.data as List).map((e) => User.fromJson(e)).toList();
  } on DioException catch (e) {
    throw NetworkException(
      e.message ?? 'Network error',
      statusCode: e.response?.statusCode,
    );
  }
}
```

### Custom Widgets

```swift
// SwiftUI - Custom Button
struct PrimaryButton: View {
  let title: String
  let action: () -> Void
  
  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.blue)
        .cornerRadius(10)
    }
  }
}
```

```dart
// Flutter - Custom Button
class PrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}
```