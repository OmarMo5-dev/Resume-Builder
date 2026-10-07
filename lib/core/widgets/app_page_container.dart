import 'package:flutter/material.dart';

class AppPageContainer extends StatelessWidget {
  const AppPageContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 1200,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: child,
        ),
      ),
    );
  }
}