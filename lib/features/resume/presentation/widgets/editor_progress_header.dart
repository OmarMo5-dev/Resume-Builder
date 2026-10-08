import 'package:flutter/material.dart';

class EditorStepInfo {
  final String label;
  final IconData icon;

  const EditorStepInfo({required this.label, required this.icon});
}

class EditorProgressHeader extends StatelessWidget {
  final List<EditorStepInfo> steps;
  final int currentIndex;
  final ValueChanged<int> onStepTap;

  const EditorProgressHeader({
    super.key,
    required this.steps,
    required this.currentIndex,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final progress = (currentIndex + 1) / steps.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          bottom: BorderSide(
            color: cs.outlineVariant.withValues( alpha : .4),
            width: .5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'STEP ${currentIndex + 1} OF ${steps.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutCubic,
              builder: (_, value, __) => LinearProgressIndicator(
                value: value,
                minHeight: 5,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: steps.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final active = index == currentIndex;
                final done = index < currentIndex;

                return _StepChip(
                  info: steps[index],
                  isActive: active,
                  isDone: done,
                  onTap: () => onStepTap(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  final EditorStepInfo info;
  final bool isActive;
  final bool isDone;
  final VoidCallback onTap;

  const _StepChip({
    required this.info,
    required this.isActive,
    required this.isDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bg = isActive
        ? cs.primary
        : isDone
        ? cs.primaryContainer.withValues( alpha : .75)
        : cs.surfaceContainerHighest.withValues( alpha : .65);

    final fg = isActive
        ? cs.onPrimary
        : isDone
        ? cs.onPrimaryContainer
        : cs.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: cs.primary.withValues( alpha : .22),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDone ? Icons.check_rounded : info.icon,
                size: 15,
                color: fg,
              ),
              const SizedBox(width: 6),
              Text(
                info.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
