import 'package:flutter/material.dart';

class RootNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const RootNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// Floating pill-style bottom nav.
///
/// Matches the design of [_buildFloatingNavBar] but as a reusable widget.
class RootBottomNavigation extends StatelessWidget {
  final List<RootNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  /// Optional tweaks (defaults match the original design)
  final double? horizontalPadding;
  final Color? backgroundColor;
  final Color? indicatorColor;

  const RootBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.horizontalPadding,
    this.backgroundColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final itemCount = items.length;

    final bg =
        backgroundColor ?? (isDark ? cs.surfaceContainerHigh : Colors.white);
    final indicator = indicatorColor ?? cs.primary;

    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(
        bottom: 10,
        left: horizontalPadding ?? 60,
        right: horizontalPadding ?? 60,
      ),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(29),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / itemCount;
            const indicatorSize = 42.0;

            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // ── Sliding indicator ──
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  left:
                      currentIndex * itemWidth +
                      (itemWidth - indicatorSize) / 2,
                  top: (58 - indicatorSize) / 2,
                  child: Container(
                    width: indicatorSize,
                    height: indicatorSize,
                    decoration: BoxDecoration(
                      color: indicator,
                      borderRadius: BorderRadius.circular(21),
                    ),
                  ),
                ),

                // ── Icons ──
                Row(
                  children: List.generate(itemCount, (index) {
                    final isSelected = currentIndex == index;
                    final item = items[index];

                    return Expanded(
                      child: Semantics(
                        button: true,
                        selected: isSelected,
                        label: item.label,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onChanged(index),
                          child: SizedBox(
                            height: 58,
                            child: Center(
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                scale: isSelected ? 1.0 : 0.9,
                                child: Icon(
                                  isSelected ? item.activeIcon : item.icon,
                                  size: 22,
                                  color: isSelected
                                      ? (isDark ? cs.onPrimary : Colors.white)
                                      : (isDark
                                            ? Colors.grey.shade500
                                            : Colors.grey.shade500),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
