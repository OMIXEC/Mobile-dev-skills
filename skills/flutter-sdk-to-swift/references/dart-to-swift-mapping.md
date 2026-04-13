# Dart to Swift Conversion Reference

## Complete Conversion Examples

### Riverpod to Combine - Complete

```dart
// Dart - StateNotifier
class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
  void decrement() => state--;
}

final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

// Usage in widget
class CounterView extends ConsumerWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Column(
      children: [
        Text('Count: $count'),
        Row(
          children: [
            IconButton(icon: Icon(Icons.add), onPressed: () => ref.read(counterProvider.notifier).increment()),
            IconButton(icon: Icon(Icons.remove), onPressed: () => ref.read(counterProvider.notifier).decrement()),
          ],
        ),
      ],
    );
  }
}
```

```swift
// Swift - Combine
class CounterViewModel: ObservableObject {
  @Published var count = 0

  func increment() {
    count += 1
  }

  func decrement() {
    count -= 1
  }
}

struct CounterView: View {
  @StateObject private var viewModel = CounterViewModel()

  var body: some View {
    VStack {
      Text("Count: \(viewModel.count)")
      HStack {
        Button(action: viewModel.increment) {
          Image(systemName: "plus")
        }
        Button(action: viewModel.decrement) {
          Image(systemName: "minus")
        }
      }
    }
  }
}
```

### GoRouter to SwiftUI Navigation

```dart
// Dart - GoRouter
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'user/:id',
          builder: (context, state) => UserScreen(
            id: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
  ],
);

// Usage
context.push('/user/123');
context.go('/');
```

```swift
// Swift - SwiftUI Navigation
struct ContentView: View {
  var body: some View {
    NavigationStack {
      NavigationLink(destination: UserScreen(id: "123")) {
        Text("Go to User")
      }
    }
  }
}

struct UserScreen: View {
  let id: String
  
  var body: some View {
    Text("User ID: \(id)")
  }
}
```

### Dio to URLSession - Complete

```dart
// Dart - Dio service
class ApiService {
  final Dio _dio;
  
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    headers: {'Authorization': 'Bearer token'},
  ));
  
  Future<List<User>> getUsers() async {
    final response = await _dio.get('/users');
    return (response.data as List).map((e) => User.fromJson(e)).toList();
  }
  
  Future<User> getUser(String id) async {
    final response = await _dio.get('/users/$id');
    return User.fromJson(response.data);
  }
  
  Future<User> createUser(CreateUserRequest req) async {
    final response = await _dio.post('/users', data: req.toJson());
    return User.fromJson(response.data);
  }
}
```

```swift
// Swift - URLSession service
class ApiService {
  static let shared = ApiService()
  
  private let baseURL = "https://api.example.com"
  private let session = URLSession.shared
  private let decoder = JSONDecoder()
  
  private func makeRequest<T: Decodable>(
    endpoint: String,
    method: String = "GET",
    body: Data? = nil
  ) async throws -> T {
    var request = URLRequest(url: URL(string: "\(baseURL)\(endpoint)")!)
    request.httpMethod = method
    request.setValue("Bearer token", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = body
    
    let (data, response) = try await session.data(for: request)
    
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
      throw ApiError.requestFailed
    }
    
    return try decoder.decode(T.self, from: data)
  }
  
  func getUsers() async throws -> [User] {
    try await makeRequest(endpoint: "/users")
  }
  
  func getUser(id: String) async throws -> User {
    try await makeRequest(endpoint: "/users/\(id)")
  }
  
  func createUser(_ request: CreateUserRequest) async throws -> User {
    let body = try JSONEncoder().encode(request)
    return try await makeRequest(endpoint: "/users", method: "POST", body: body)
  }
}

enum ApiError: Error {
  case requestFailed
  case invalidResponse
  case decodingFailed
}
```

### Hive to Core Data

```dart
// Dart - Hive model
@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  late String name;
  
  @HiveField(2)
  String? email;
  
  @HiveField(3)
  late DateTime createdAt;
}

// Repository
class UserRepository {
  final Box<UserModel> _box;
  
  UserRepository(this._box);
  
  List<UserModel> getAll() => _box.values.toList();
  
  UserModel? get(String id) => _box.get(id);
  
  Future<void> save(UserModel user) => _box.put(user.id, user);
  
  Future<void> delete(String id) => _box.delete(id);
}
```

```swift
// Swift - Core Data
@objc(UserEntity)
public class UserEntity: NSManagedObject {
  @NSManaged public var id: UUID
  @NSManaged public var name: String
  @NSManaged public var email: String?
  @NSManaged public var createdAt: Date
}

extension UserEntity {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEntity> {
    return NSFetchRequest<UserEntity>(entityName: "UserEntity")
  }
}

// Repository
class UserRepository {
  let context: NSManagedObjectContext
  
  init(context: NSManagedObjectContext) {
    self.context = context
  }
  
  func getAll() -> [UserEntity] {
    let request = UserEntity.fetchRequest()
    return (try? context.fetch(request)) ?? []
  }
  
  func get(id: UUID) -> UserEntity? {
    let request = UserEntity.fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
    return try? context.fetch(request).first
  }
  
  func save(_ entity: UserEntity) throws {
    try context.save()
  }
  
  func delete(id: UUID) throws {
    let entity = get(id: id)
    if let entity = entity {
      context.delete(entity)
      try context.save()
    }
  }
}
```

### Freezed to Codable

```dart
// Dart - Freezed
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
    String? email,
    @Default([]) List<String> roles,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

```swift
// Swift - Codable
struct User: Codable, Identifiable {
  let id: String
  var name: String
  var email: String?
  var roles: [String]

  init(id: String, name: String, email: String? = nil, roles: [String] = []) {
    self.id = id
    self.name = name
    self.email = email
    self.roles = roles
  }
}

// JSON encoding/decoding
extension User {
  func toJSON() -> [String: Any] {
    var json: [String: Any] = [
      "id": id,
      "name": name,
      "roles": roles
    ]
    if let email = email {
      json["email"] = email
    }
    return json
  }

  static func fromJSON(_ json: [String: Any]) -> User? {
    guard let id = json["id"] as? String,
          let name = json["name"] as? String else {
      return nil
    }
    return User(
      id: id,
      name: name,
      email: json["email"] as? String,
      roles: (json["roles"] as? [String]) ?? []
    )
  }
}
```

### Error Handling

```dart
// Dart - Result type
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Error? error;
  const Failure(this.message, {this.error});
}

// Usage
Future<Result<User>> fetchUser() async {
  try {
    final user = await api.getUser(id);
    return Success(user);
  } catch (e) {
    return Failure('Failed to fetch user', error: e);
  }
}
```

```swift
// Swift - Result type
enum Result<T> {
  case success(T)
  case failure(String, Error?)
}

// Usage
func fetchUser() async -> Result<User> {
  do {
    let user = try await api.getUser(id: id)
    return .success(user)
  } catch {
    return .failure("Failed to fetch user", error: error)
  }
}

// Or using async/await with throws
func fetchUser() async throws -> User {
  try await api.getUser(id: id)
}
```

### Custom Widget Conversion

```dart
// Flutter - Custom Card
class UserCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.name,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        onTap: onTap,
      ),
    );
  }
}
```

```swift
// SwiftUI - Custom Card
struct UserCard: View {
  let name: String
  var subtitle: String?
  var onTap: (() -> Void)?

  var body: some View {
    Card {
      VStack(alignment: .leading) {
        Text(name)
        if let subtitle = subtitle {
          Text(subtitle)
            .foregroundColor(.secondary)
        }
      }
    }
    .onTapGesture(perform: onTap)
  }
}
```