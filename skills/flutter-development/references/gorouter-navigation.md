# GoRouter Navigation

## Basic Setup

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/users/:id',
        builder: (context, state) => UserScreen(
          id: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

// In main.dart
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
    );
  }
}
```

## Nested Routes

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
            routes: [
              GoRoute(
                path: 'stats',
                builder: (context, state) => const StatsScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
});
```

## Navigation Methods

```dart
// Push new route
context.push('/user/123');

// Push with data
context.push('/user/123', extra: {'from': 'dashboard'});

// Replace current route
context.go('/home');

// Go with query params
context.go('/search?query=flutter');

// Pop
context.pop();

// Can check if can pop
if (context.canPop()) context.pop();
```

## Deep Linking

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/users/:id',
        builder: (context, state) => UserScreen(
          id: state.pathParameters['id']!,
          // Access query params
          tab: state.uri.queryParameters['tab'],
        ),
      ),
    ],
    // Handle missing routes
    redirect: (context, state) {
      // Authentication check
      final isLoggedIn = ref.read(authProvider);
      if (!isLoggedIn && state.matchedLocation != '/login') {
        return '/login?redirect=${state.matchedLocation}';
      }
      return null;
    },
  );
});
```

## Route Guards

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isOnLoginPage = state.matchedLocation == '/login';
      
      if (!isLoggedIn && !isOnLoginPage) {
        return '/login?redirect=${state.matchedLocation}';
      }
      
      if (isLoggedIn && isOnLoginPage) {
        return '/dashboard';
      }
      
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
  );
});
```

## Best Practices

- Use GoRouter for declarative routing
- Define routes in a central provider
- Use path parameters for dynamic segments
- Handle auth redirects in `redirect` callback
- Use `extra` for passing complex data
- Prefer `go` over `push` for navigation changes
- Handle 404 with custom error route