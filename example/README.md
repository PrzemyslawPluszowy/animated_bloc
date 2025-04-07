# Animated BLoC Example

This is an example application demonstrating the use of the `animated_bloc` package, which adds beautiful animations to BLoC state transitions.

## Features

This example showcases:

- A simple counter application using `CounterCubit`
- All available transition types:
  - Scale
  - Fade
  - Slide
  - Custom (rotation with scale)
- Interactive UI for testing different animations

## Screenshots

![Example App](https://github.com/PrzemyslawPluszowy/animated_bloc/raw/main/example/screenshots/example.gif)

## Running the Example

To run this example, execute the following commands:

```bash
cd example
flutter pub get
flutter run
```

## Usage

The main example shows how to use `AnimatedBlocBuilder` with a counter:

```dart
AnimatedBlocBuilder<CounterCubit, int>(
  bloc: counterCubit,
  transitionType: StateTransitionType.scale,
  duration: const Duration(milliseconds: 400),
  builder: (context, count) {
    return Text(
      '$count',
      style: const TextStyle(
        fontSize: 80,
        fontWeight: FontWeight.bold,
      ),
    );
  },
),
```

You can also see examples of different transition types by clicking the buttons at the bottom of the screen. 