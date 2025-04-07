import 'package:animated_bloc/animated_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

// Simple counter cubit for testing
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

void main() {
  group('AnimatedBlocBuilder', () {
    late CounterCubit counterCubit;

    setUp(() {
      counterCubit = CounterCubit();
    });

    tearDown(() {
      counterCubit.close();
    });

    testWidgets('should render initial state', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedBlocBuilder<CounterCubit, int>(
              bloc: counterCubit,
              builder: (context, state) {
                return Text('Count: $state');
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Count: 0'), findsOneWidget);
    });

    blocTest<CounterCubit, int>(
      'emits [1] when increment is called',
      build: () => counterCubit,
      act: (cubit) => cubit.increment(),
      expect: () => [1],
    );

    testWidgets('should animate when state changes', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedBlocBuilder<CounterCubit, int>(
              bloc: counterCubit,
              transitionType: StateTransitionType.scale,
              duration: const Duration(milliseconds: 100),
              builder: (context, state) {
                return Text('Count: $state', key: ValueKey(state));
              },
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('Count: 0'), findsOneWidget);

      // Act - trigger state change
      counterCubit.increment();

      // Pump half-way through animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Animation should be in progress
      final animationWidgets = find.byType(AnimatedSwitcher);
      expect(animationWidgets, findsOneWidget);

      // Finish animation
      await tester.pump(const Duration(milliseconds: 50));

      // Assert - final state is visible
      expect(find.text('Count: 1'), findsOneWidget);
    });

    testWidgets('should apply custom animation', (WidgetTester tester) async {
      // Arrange - Create a widget with custom animation
      final testKey = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedBlocBuilder<CounterCubit, int>(
              key: testKey,
              bloc: counterCubit,
              transitionType: StateTransitionType.custom,
              duration: const Duration(milliseconds: 100),
              customTransitionBuilder: (child, animation) {
                // Custom rotation animation
                return RotationTransition(
                  turns: Tween<double>(begin: 0.0, end: 0.5).animate(animation),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              builder: (context, state) {
                return Text('Count: $state', key: ValueKey(state));
              },
            ),
          ),
        ),
      );

      // Initial state
      expect(find.text('Count: 0'), findsOneWidget);

      // Act - trigger state change
      counterCubit.increment();

      // Verify animation is started
      await tester.pump();

      // Assert that AnimatedBlocBuilder is using a custom animation
      expect(find.byKey(testKey), findsOneWidget);
      expect(find.byType(AnimatedSwitcher), findsOneWidget);

      // Finish animation
      await tester.pump(const Duration(milliseconds: 100));

      // Assert - final state is visible
      expect(find.text('Count: 1'), findsOneWidget);
    });
  });

  group('AnimatedBlocConsumer', () {
    late CounterCubit counterCubit;

    setUp(() {
      counterCubit = CounterCubit();
    });

    tearDown(() {
      counterCubit.close();
    });

    testWidgets('should call listener when state changes', (
      WidgetTester tester,
    ) async {
      // Arrange
      int listenerCallCount = 0;
      int? lastState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedBlocConsumer<CounterCubit, int>(
              bloc: counterCubit,
              listener: (context, state) {
                listenerCallCount++;
                lastState = state;
              },
              builder: (context, state) {
                return Text('Count: $state');
              },
            ),
          ),
        ),
      );

      // Initial state doesn't trigger listener
      expect(listenerCallCount, 0);

      // Act - change state
      counterCubit.increment();
      await tester.pump();

      // Assert - listener was called with correct state
      expect(listenerCallCount, 1);
      expect(lastState, 1);

      // Act - change state again
      counterCubit.increment();
      await tester.pump();

      // Assert - listener was called again
      expect(listenerCallCount, 2);
      expect(lastState, 2);
    });
  });
}
