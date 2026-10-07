import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppPageTransition {
  const AppPageTransition._();

  static CustomTransitionPage<T> slide<T>({
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      child: child,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (
          context,
          animation,
          secondaryAnimation,
          child,
          ) {
        final animationCurve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final offsetAnimation = Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animationCurve);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}