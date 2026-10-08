import 'package:flutter/material.dart';

class ResumesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onCreate;
  final List<Widget> extraActions;

  const ResumesAppBar({
    super.key,
    required this.onCreate,
    this.extraActions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AppBar(
      titleSpacing: 16,
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'My Resumes',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
      actions: [
        ...extraActions,
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 12),
          child: _CreateButton(onPressed: onCreate),
        ),
      ],
    );
  }
}

// ============================================================
//  Create button — responsive label
// ============================================================
class _CreateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _CreateButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = MediaQuery.of(context).size.width < 380;

        if (isCompact) {
          return FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              minimumSize: const Size(44, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: Icon(Icons.note_add_outlined, size: 20, color: cs.onPrimary),
          );
        }

        return FilledButton.icon(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
          ),
          icon: const Icon(Icons.note_add_outlined, size: 18),
          label: const Text(
            'New',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
              letterSpacing: 0.2,
            ),
          ),
        );
      },
    );
  }
}
