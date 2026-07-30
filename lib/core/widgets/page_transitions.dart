import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transitions for better UX
class PageTransitions {
  /// Fade transition
  static CustomTransitionPage fade({
    required Widget child,
    Duration transitionDuration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: transitionDuration,
    );
  }

  /// Slide transition from right
  static CustomTransitionPage slideRight({
    required Widget child,
    Duration transitionDuration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: transitionDuration,
    );
  }

  /// Slide transition from bottom
  static CustomTransitionPage slideUp({
    required Widget child,
    Duration transitionDuration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: transitionDuration,
    );
  }

  /// Scale transition
  static CustomTransitionPage scale({
    required Widget child,
    Duration transitionDuration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation,
          child: child,
        );
      },
      transitionDuration: transitionDuration,
    );
  }
}

