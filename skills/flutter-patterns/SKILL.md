---
name: flutter-patterns
description: Flutter best practices, widget architecture, state management with Riverpod/Bloc, and cross-platform mobile patterns. Use when building Flutter applications.
---

# Flutter Mobile Patterns

## Project Structure

```
lib/
├── core/                   # Common constants, themes, and base classes
│   ├── theme.dart
│   └── constants.dart
├── features/               # Feature-first architecture
│   ├── auth/
│   │   ├── domain/         # Entities and repositories interfaces
│   │   ├── data/           # Repository implementations and data sources
│   │   └── presentation/   # Widgets, pages, and controllers/blocs
│   └── feed/
├── main.dart               # App entrypoint
```

## Widget Composition

### Stateful vs Stateless

- Prefer `StatelessWidget` and manage state with providers/blocs.
- Use `StatefulWidget` only for local UI state (like animation controllers or form focus nodes).

```dart
// Prefer creating small, focused StatelessWidgets
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
```

## State Management (Riverpod)

```dart
// counter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider = StateProvider<int>((ref) => 0);
```

```dart
// counter_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounterPage extends ConsumerWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(child: Text('Count: $count')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).state++,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Async Data (FutureBuilder / Riverpod)

Using Riverpod's `FutureProvider` is often cleaner than `FutureBuilder`:

```dart
final userProvider = FutureProvider.family<User, String>((ref, userId) async {
  final repository = ref.read(userRepositoryProvider);
  return repository.fetchUser(userId);
});

// In Widget:
final asyncUser = ref.watch(userProvider('123'));

return asyncUser.when(
  data: (user) => Text('Hello ${user.name}'),
  loading: () => const CircularProgressIndicator(),
  error: (err, stack) => Text('Error: $err'),
);
```

## Navigation (go_router)

For deep linking and complex navigation, use `go_router`:

```dart
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailsScreen(id: id);
      },
    ),
  ],
);
```
