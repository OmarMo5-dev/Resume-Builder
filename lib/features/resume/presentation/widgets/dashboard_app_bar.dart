import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppBar(
      titleSpacing: 20,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      title: Text(
        'Dashboard',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsetsDirectional.only(end: 16),
      //     child: Container(
      //       width: 34,
      //       height: 34,
      //       decoration: BoxDecoration(
      //         color: cs.surfaceContainerHighest,
      //         shape: BoxShape.circle,
      //         border: Border.all(
      //           color: cs.outlineVariant.withValues(alpha: 0.45),
      //         ),
      //       ),
      //       child: Icon(
      //         Icons.description_outlined,
      //         size: 18,
      //         color: cs.primary,
      //       ),
      //     ),
      //   ),
      // ],
    );
  }
}
