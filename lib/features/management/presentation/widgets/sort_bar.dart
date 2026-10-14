import 'package:flutter/material.dart';

enum ResumeSort {
  recentlyUpdated('Recently updated', 'Recent'),
  created('Date created', 'Created'),
  title('Title', 'Title');

  const ResumeSort(this.label, this.shortLabel);

  final String label;
  final String shortLabel;
}

class SortBar extends StatelessWidget {
  const SortBar({
    super.key,
    required this.count,
    required this.itemLabel,
    required this.sort,
    required this.ascending,
    required this.onSortChanged,
    required this.onDirectionToggled,
  });

  final int count;
  final String itemLabel; // 'resume' / 'resumes'
  final ResumeSort sort;
  final bool ascending;
  final ValueChanged<ResumeSort> onSortChanged;
  final VoidCallback onDirectionToggled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // ---- Count (calm, secondary) ----
          Text(
            '$count $itemLabel',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),

          const Spacer(),

          // ---- Sort dropdown (compact chip look) ----
          _SortChip(sort: sort, onChanged: onSortChanged),

          const SizedBox(width: 6),

          // ---- Direction toggle (grouped) ----
          _DirectionButton(ascending: ascending, onTap: onDirectionToggled),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SortChip extends StatelessWidget {
  const _SortChip({required this.sort, required this.onChanged});

  final ResumeSort sort;
  final ValueChanged<ResumeSort> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PopupMenuButton<ResumeSort>(
      tooltip: 'Sort by',
      initialValue: sort,
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        for (final option in ResumeSort.values)
          PopupMenuItem(
            value: option,
            child: Row(
              children: [
                Icon(
                  option == sort
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: option == sort ? cs.primary : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 10),
                Text(option.label),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sort_rounded, size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              sort.shortLabel,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _DirectionButton extends StatelessWidget {
  const _DirectionButton({required this.ascending, required this.onTap});

  final bool ascending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: ascending ? 'Ascending' : 'Descending',
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.12),
              ),
            ),
            child: AnimatedRotation(
              turns: ascending ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Icon(
                Icons.arrow_downward_rounded,
                size: 18,
                color: cs.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
