import 'package:flutter/material.dart';

class EmptyDashboard extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyDashboard({super.key, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;


    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg =
    (isDark ? cs.surfaceContainerHigh : Colors.white);

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
          color: bg,
        border: Border.all(color: Colors.grey.withValues(alpha: .12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withValues(alpha: isDark ? 0.35 : 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],

      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(Icons.auto_awesome, color: cs.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your workspace is ready',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create your first resume and it will appear here.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: onCreate, icon: const Icon(Icons.add)),
          ],
        ),
      ),
    );
  }
}
