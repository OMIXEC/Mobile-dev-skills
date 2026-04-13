# REST API Integration

## HTTP Client Setup

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Dio provider with interceptors
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  // Auth interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final storage = ref.read(secureStorageProvider);
      final token = await storage.read(key: 'auth_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (error, handler) async {
      if (error.response?.statusCode == 401) {
        // Handle token refresh
        await refreshToken(ref);
      }
      return handler.next(error);
    },
  ));

  // Logging interceptor (dev only)
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));

  return dio;
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});
```

## API Service Pattern

```dart
class UserService {
  final Dio _dio;

  UserService(this._dio);

  Future<List<User>> getUsers() async {
    final response = await _dio.get('/users');
    return (response.data as List).map((e) => User.fromJson(e)).toList();
  }

  Future<User> getUser(String id) async {
    final response = await _dio.get('/users/$id');
    return User.fromJson(response.data);
  }

  Future<User> createUser(CreateUserRequest request) async {
    final response = await _dio.post('/users', data: request.toJson());
    return User.fromJson(response.data);
  }

  Future<User> updateUser(String id, UpdateUserRequest request) async {
    final response = await _dio.put('/users/$id', data: request.toJson());
    return User.fromJson(response.data);
  }

  Future<void> deleteUser(String id) async {
    await _dio.delete('/users/$id');
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.read(dioProvider));
});
```

## Error Handling

```dart
// Custom exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException(this.message, {this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

// Error handling in service
Future<User> getUser(String id) async {
  try {
    final response = await _dio.get('/users/$id');
    return User.fromJson(response.data);
  } on DioException catch (e) {
    throw ApiException(
      _getErrorMessage(e),
      statusCode: e.response?.statusCode,
      data: e.response?.data,
    );
  }
}

String _getErrorMessage(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      return 'Connection timeout';
    case DioExceptionType.receiveTimeout:
      return 'Server not responding';
    case DioExceptionType.badResponse:
      return e.response?.data?['message'] ?? 'Server error';
    case DioExceptionType.cancel:
      return 'Request cancelled';
    default:
      return 'Network error';
  }
}

// State wrapper for UI
sealed class ApiResult<T> {
  const ApiResult();
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiError<T> extends ApiResult<T> {
  final String message;
  const ApiError(this.message);
}
```

## Best Practices

- Use Dio for HTTP requests
- Store tokens in flutter_secure_storage
- Implement token refresh interceptor
- Handle all DioException types
- Use custom exception classes
- Create service classes for API calls
- Use freezed for request/response models
- Add connection check before requests
- Implement retry logic for transient errors