import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'animated_bloc.dart';

/// A generic widget for animated transitions between bloc states
class AnimatedBlocBuilder<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  const AnimatedBlocBuilder({
    this.bloc,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.transitionType = StateTransitionType.scale,
    this.buildWhen,
    this.customTransitionBuilder,
    super.key,
  }) : assert(
         transitionType != StateTransitionType.custom ||
             customTransitionBuilder != null,
         'customTransitionBuilder must be provided when using StateTransitionType.custom',
       );

  /// The bloc that manages the state
  final B? bloc;

  /// Builder for creating a widget based on the current state
  final Widget Function(BuildContext context, S state) builder;

  /// Animation duration
  final Duration duration;

  /// Type of animation to use for transitions
  final StateTransitionType transitionType;

  /// Optional function that determines when to rebuild the widget
  final bool Function(S previous, S current)? buildWhen;

  /// Optional custom transition builder
  ///
  /// Must be provided when [transitionType] is [StateTransitionType.custom]
  final Widget Function(Widget child, Animation<double> animation)?
  customTransitionBuilder;

  Widget _buildTransition(Widget child, Animation<double> animation) {
    if (transitionType == StateTransitionType.custom &&
        customTransitionBuilder != null) {
      return customTransitionBuilder!(child, animation);
    }

    final inAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

    return switch (transitionType) {
      StateTransitionType.scale => ScaleTransition(
        scale: inAnimation,
        child: FadeTransition(opacity: inAnimation, child: child),
      ),
      StateTransitionType.slide => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.3),
          end: Offset.zero,
        ).animate(inAnimation),
        child: FadeTransition(opacity: inAnimation, child: child),
      ),
      StateTransitionType.fade => FadeTransition(
        opacity: inAnimation,
        child: child,
      ),
      _ => child, // This should never happen due to the assert
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      bloc: bloc,
      buildWhen: buildWhen,
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: duration,
          transitionBuilder: _buildTransition,
          child: builder(context, state),
        );
      },
    );
  }
}
