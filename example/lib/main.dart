import 'package:animated_bloc/animated_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A simple counter cubit for demonstration purposes
class CounterCubit extends Cubit<CounterState> {
  CounterCubit() : super(CounterInitial());

  Future<void> increment() async {
    final currentState = state;
    emit(CounterLoading());
    await Future.delayed(const Duration(milliseconds: 1000));
    if (currentState case CounterLoaded(count: final count)) {
      emit(CounterLoaded(count: count + 1));
    } else {
      emit(CounterLoaded(count: 1));
    }
  }
}

sealed class CounterState {}

final class CounterInitial extends CounterState {}

final class CounterLoading extends CounterState {}

final class CounterLoaded extends CounterState {
  CounterLoaded({required this.count});

  final int count;

  @override
  bool operator ==(Object other) {
    if (other is CounterLoaded) {
      return count == other.count;
    }
    return false;
  }

  @override
  int get hashCode => count.hashCode;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Bloc Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => CounterCubit(),
        child: const CounterPage(),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final counterCubit = context.read<CounterCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Counter'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: AnimatedBlocBuilder<CounterCubit, CounterState>(
        transitionType: StateTransitionType.slide,
        duration: const Duration(milliseconds: 300),
        builder: (context, state) {
          return switch (state) {
            CounterInitial() => Center(
              key: const ValueKey(
                'initial',
              ), // key is important you can use UniqueKey() but it will be a new widget every time
              child: Text(
                'Initial',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            CounterLoading() => const Center(
              key: ValueKey('loading'),
              child: CircularProgressIndicator(),
            ), // key is important
            CounterLoaded(count: final count) => Center(
              key: ValueKey('loaded_$count'), // key is important
              child: Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          counterCubit.increment();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
