---
name: flutter-development
description: >
  Develop cross-platform mobile apps with Flutter and Dart. Covers Riverpod
  state management, GoRouter navigation, REST APIs, and platform channels.
  Use when building iOS/Android apps with a single codebase, implementing
  smooth animations, or working with Firebase.
---

# Flutter Development

## Table of Contents

- [Overview](#overview)
- [When to Use](#when-to-use)
- [Quick Start](#quick-start)
- [Reference Guides](#reference-guides)
- [Best Practices](#best-practices)

## Overview

Build beautiful, natively compiled mobile applications from a single codebase using Flutter with Dart.

## When to Use

- Building cross-platform iOS and Android apps from a single codebase
- Creating apps with smooth 60fps animations
- Working with Firebase (Auth, Firestore, Cloud Functions)
- Implementing complex UI with custom designs
- Rapid prototyping with hot reload
- Using Riverpod for state management

## Quick Start

Minimal working example:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class User {
  final String id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});
}

class UserNotifier extends StateNotifier<AsyncValue<User?>> {
  final Ref ref;

  UserNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> fetchUser(String id) async {
    state = const AsyncValue.loading();
    try {
      // Fetch user from API
      state = AsyncValue.data(User(id: id, name: 'John', email: 'john@example.com'));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, AsyncValue<User?>>((ref) {
  return UserNotifier(ref);
});

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/user/:id', builder: (context, state) => UserScreen(id: state.pathParameters['id']!)),
  ],
);

// See reference guides for full implementation
```

## Reference Guides

Detailed implementations in the `references/` directory:

| Guide | Contents |
|---|---|
| [Riverpod State Management](references/riverpod-state-management.md) | Riverpod setup, providers, notifiers |
| [GoRouter Navigation](references/gorouter-navigation.md) | GoRouter configuration, deep linking |
| [REST API Integration](references/rest-api-integration.md) | HTTP client, error handling |

## Best Practices

### ✅ DO

- Use Riverpod for state management (not setState)
- Follow GoRouter for navigation
- Use const constructors where possible
- Implement proper error handling
- Use freezed for immutable data classes
- Store tokens securely (flutter_secure_storage)
- Test on multiple OS versions
- Use dependency injection
- Follow Dart style guidelines

### ❌ DON'T

- Use setState for global state
- Hardcode API URLs (use environment variables)
- Store tokens in SharedPreferences
- Ignore platform-specific differences
- Skip error handling
- Use deprecated APIs
- Store passwords in code
- Ignore accessibility
- Deploy untested code
- Use magic numbers