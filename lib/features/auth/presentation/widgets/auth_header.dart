import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFFDDF7FF),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withValues(alpha: 0.09),
                blurRadius: 6,
                offset: Offset(0, 2)
              )
            ],
          ),
          child: Image.asset(
            'assets/logos/Logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Icon(
              Icons.description_rounded,
              size: 42,
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
