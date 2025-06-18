<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Animated BLoC

A Flutter package that provides widgets for animated transitions between BLoC states with various animation types. This is a simple wrapper around the `flutter_bloc` package that adds beautiful animations to state transitions.

## Features

- Easily add animations when your BLoC state changes
- Four transition types:
  - Scale with fade
  - Slide with fade
  - Fade
  - Custom animations
- Works with any BLoC that implements `StateStreamable<State>`
- Includes both `AnimatedBlocBuilder` and `AnimatedBlocConsumer` variants
- Smooth transitions between different states (loading, error, success, etc.)

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  animated_bloc: ^0.2.0
```

Then run:

```bash
flutter pub get
```

## Usage

### Basic Example with AnimatedBlocBuilder

```dart
import 'package:animated_bloc/animated_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Counter')),
      body: Center(
        child: AnimatedBlocBuilder<CounterCubit, int>(
          bloc: context.read<CounterCubit>(),
          transitionType: StateTransitionType.scale, // Choose animation type
          duration: const Duration(milliseconds: 400), // Customize duration
          builder: (context, count) {
            return Text(
              '$count',
              style: const TextStyle(fontSize: 64),
              key: ValueKey(count), // Important: Add key for proper animations
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterCubit>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

### Using AnimatedBlocConsumer

```dart
AnimatedBlocConsumer<CounterCubit, int>(
  bloc: context.read<CounterCubit>(),
  transitionType: StateTransitionType.slide,
  duration: const Duration(milliseconds: 300),
  listener: (context, state) {
    if (state == 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You reached 10!')),
      );
    }
  },
  builder: (context, count) {
    return Text(
      '$count',
      style: const TextStyle(fontSize: 64),
      key: ValueKey(count), // Important: Add key for proper animations
    );
  },
),
```

### Custom Animation

You can create your own custom animation:

```dart
AnimatedBlocBuilder<ThemeCubit, ThemeState>(
  bloc: context.read<ThemeCubit>(),
  transitionType: StateTransitionType.custom,
  customTransitionBuilder: (child, animation) {
    final rotateAnim = Tween(begin: 0.0, end: 2 * 3.14).animate(animation);
    return RotationTransition(
      turns: rotateAnim,
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  },
  builder: (context, themeState) {
    // Important: Add key based on theme state for proper animations
    return SomeWidget(
      key: ValueKey(themeState.hashCode),
      theme: themeState.theme,
    );
  },
),
```

### Handling Different States with Animations

This package is particularly useful when transitioning between different states of your application, such as loading, error, and success states:

```dart
AnimatedBlocBuilder<DataCubit, DataState>(
  bloc: dataCubit,
  transitionType: StateTransitionType.fade,
  duration: const Duration(milliseconds: 400),
  builder: (context, state) {
    return switch (state) {
      DataInitial() => const InitialMessageWidget(key: ValueKey('initial')),
      DataLoading() => const LoadingSpinnerWidget(key: ValueKey('loading')),
      DataError(message: final message) => ErrorWidget(
          key: ValueKey('error_$message'),
          message: message,
        ),
      DataLoaded(data: final items) => DataListView(
          key: ValueKey('loaded_${items.hashCode}'),
          items: items,
        ),
    };
  },
),
```

This creates smooth, animated transitions between your different screens or states, providing a more polished user experience.

### Important: Using Keys for Proper Animations

To ensure proper animations when transitioning between different widgets or the same widget with different data, you **must** provide unique keys to your widgets:

```dart
// For different states, use descriptive keys
switch (state) {
  case InitialState(): return Widget(key: ValueKey('initial'));
  case LoadingState(): return Widget(key: ValueKey('loading'));
  case ErrorState(): return Widget(key: ValueKey('error'));
}

// For states with data, include the data in the key
return ItemWidget(
  key: ValueKey('item_${item.id}'), // Use unique data in the key
  item: item,
);
```

**Why keys are important:**
- AnimatedBlocBuilder uses AnimatedSwitcher internally, which needs keys to identify when widgets change
- Without keys, widgets may not animate correctly or at all
- ValueKey is recommended for most cases, but UniqueKey can also be used if you want to force animations on every rebuild

## Available Transition Types

- `StateTransitionType.scale` - Scale animation with fade-in
- `StateTransitionType.slide` - Slide animation from bottom with fade-in
- `StateTransitionType.fade` - Simple fade-in transition
- `StateTransitionType.custom` - Create your own animation with `customTransitionBuilder`

## Additional Parameters

Both `AnimatedBlocBuilder` and `AnimatedBlocConsumer` support all the same parameters as the regular `BlocBuilder` and `BlocConsumer`, including:

- `buildWhen` - Controls when to rebuild the widget
- `listenWhen` - (For Consumer only) Controls when to trigger the listener callback

## Limitations

### Using with Slivers

When using `AnimatedBlocBuilder` or `AnimatedBlocConsumer` inside a `CustomScrollView` or other sliver context, you must wrap them in a `SliverToBoxAdapter`:

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      title: Text('My App'),
    ),
    SliverToBoxAdapter(
      child: AnimatedBlocBuilder<MyCubit, MyState>(
        bloc: myCubit,
        builder: (context, state) {
          return YourWidget();
        },
      ),
    ),
    // Other slivers...
  ],
),
```

This is because these widgets produce regular box widgets, not sliver widgets.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
