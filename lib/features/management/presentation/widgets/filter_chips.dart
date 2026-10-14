import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
    this.filters = JobFilter.values,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final JobFilter selected;
  final ValueChanged<JobFilter> onChanged;
  final List<JobFilter> filters;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: padding,
      child: Row(
        children: [
          for (final filter in filters) ...[
            _FilterChipItem(
              filter: filter,
              isSelected: selected == filter,
              colorScheme: cs,
              onTap: () => onChanged(filter),
            ),
            if (filter != filters.last) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.filter,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
  });

  final JobFilter filter;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = colorScheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${filter.label} filter',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: isSelected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            splashColor: isSelected
                ? cs.onPrimary.withValues(alpha: 0.12)
                : cs.primary.withValues(alpha: 0.08),
            highlightColor: Colors.transparent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : cs.outlineVariant.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: isSelected
                        ? Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: cs.onPrimary,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? cs.onPrimary : cs.onSurface,
                      letterSpacing: 0.1,
                    ),
                    child: Text(filter.label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum JobFilter {
  all('All'),
  drafts('Drafts'),
  completed('Completed'),
  public('Public');

  const JobFilter(this.label);

  final String label;
}
