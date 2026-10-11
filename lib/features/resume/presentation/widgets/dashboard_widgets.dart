import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/resume.dart';

class DashboardWelcome extends StatelessWidget {
  final String? name;
  final VoidCallback onCreate;
  final int resumeCount;

  const DashboardWelcome({
    super.key,
    required this.name,
    required this.onCreate,
    this.resumeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final displayName = (name ?? '').trim();
    final firstName = displayName.isEmpty
        ? 'there'
        : displayName.split(RegExp(r'\s+')).first;

    final bg = isDark ? cs.surfaceContainerHigh : Colors.white;

    final ctaLabel = resumeCount == 0
        ? 'Create your first resume'
        : 'New resume';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: isDark ? 0.14 : 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.waving_hand_rounded,
                  size: 21,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Welcome back, $firstName',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Build, manage, and share your professional resumes from one place.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 46,
            child: FilledButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                onCreate();
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(
                ctaLabel,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stats
// ─────────────────────────────────────────────────────────────

class DashboardStats extends StatelessWidget {
  final List<Resume> resumes;

  /// When true, show skeleton placeholders instead of "0".
  final bool loading;

  /// Called when a stat card is tapped. Receives the stat key.
  final ValueChanged<String>? onStatTap;

  const DashboardStats({
    super.key,
    required this.resumes,
    this.loading = false,
    this.onStatTap,
  });

  @override
  Widget build(BuildContext context) {
    final completed = resumes.where((r) => !r.isDraft).length;
    final drafts = resumes.where((r) => r.isDraft).length;
    final publicCount = resumes.where((r) => r.isPublic).length;

    final items = [
      _StatData(
        key: 'resumes',
        label: 'Resumes',
        value: resumes.length,
        icon: Icons.description_outlined,
      ),
      _StatData(
        key: 'completed',
        label: 'Completed',
        value: completed,
        icon: Icons.check_circle_outline_rounded,
      ),
      _StatData(
        key: 'drafts',
        label: 'Drafts',
        value: drafts,
        icon: Icons.edit_note_rounded,
      ),
      _StatData(
        key: 'public',
        label: 'Public',
        value: publicCount,
        icon: Icons.public_outlined,
      ),
    ];

    // UX: if there are no resumes, don't show four zeros.
    if (!loading && resumes.isEmpty) {
      return _EmptyStatsCard(onCreate: () {});
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        const gap = 10.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: _StatCard(
                  data: item,
                  loading: loading,
                  onTap: onStatTap == null ? null : () => onStatTap!(item.key),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _StatData {
  final String key;
  final String label;
  final int value;
  final IconData icon;

  const _StatData({
    required this.key,
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  final bool loading;
  final VoidCallback? onTap;

  const _StatCard({required this.data, this.loading = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? cs.surfaceContainerHigh : Colors.white;

    // UI: zero values read as "muted" so the eye prioritizes real numbers.
    final isZero = !loading && data.value == 0;
    final valueColor = isZero
        ? cs.onSurfaceVariant.withValues(alpha: 0.55)
        : cs.onSurface;

    return Semantics(
      button: onTap != null,
      label: '${data.label}: ${data.value}',
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap!.call();
                },
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: cs.outlineVariant.withValues(
                  alpha: isDark ? 0.14 : 0.06,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(data.icon, size: 19, color: cs.primary),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (loading)
                        _SkeletonBar(width: 34, height: 18)
                      else
                        // UX: animate count-up, tabular figures to
                        // prevent digit jitter during animation.
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: data.value),
                          duration: const Duration(milliseconds: 420),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, _) => Text(
                            '$value',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1,
                              color: valueColor,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 5),
                      Text(
                        data.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // UX: chevron only when the card is tappable.
                if (onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty-state shown when there are no resumes at all.
class _EmptyStatsCard extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyStatsCard({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? cs.surfaceContainerHigh : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: isDark ? 0.14 : 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.insights_rounded, color: cs.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your resume stats will appear here once you create one.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small placeholder used while loading.
class _SkeletonBar extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonBar({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cs.onSurfaceVariant.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section header
// ─────────────────────────────────────────────────────────────

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 36),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Tip card
// ─────────────────────────────────────────────────────────────

class DashboardTipCard extends StatelessWidget {
  final Resume? resume;

  /// Optional inline action (e.g. "Finish draft").
  final String? actionLabel;
  final VoidCallback? onAction;

  const DashboardTipCard({
    super.key,
    this.resume,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? cs.surfaceContainerHigh : Colors.white;

    // UI: theme-aware amber — readable on both modes.
    final amber = isDark ? const Color(0xFFFFC94D) : const Color(0xFF9A6700);

    final text = resume == null
        ? 'Start with your strongest experience and projects. You can always refine the resume later.'
        : resume!.isDraft
        ? 'Your latest resume is still a draft. Finish the key sections before sharing it.'
        : 'Keep your resume fresh by adding new projects, courses, and experience as you grow.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: isDark ? 0.14 : 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: amber, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: amber,
                    height: 1.45,
                  ),
                ),
                // UX: optional inline action.
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: const Size(0, 30),
                      visualDensity: VisualDensity.compact,
                      foregroundColor: amber,
                    ),
                    child: Text(
                      actionLabel!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
