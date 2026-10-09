import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final String initial;
  final UserProfile profile;
  final ColorScheme colors;

  const ProfileHeader({
    super.key,
    required this.initial,
    required this.profile,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasName = profile.displayName.trim().isNotEmpty;

    return Column(
      children: [

        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Cover background
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade600, Colors.blue.shade900],
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -10,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // Top-right badge
                  Positioned(
                    top: 12,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 0.6,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_rounded,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Account',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w600,
                              fontSize: 10.5,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Avatar (overlapping)
            Positioned(
              bottom: -36,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? colors.surfaceContainerHigh
                      : colors.surfaceContainerLowest,
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primary,
                        colors.primary.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: isDark
                        ? colors.surfaceContainerHigh
                        : colors.surfaceContainerLowest,
                    child: Text(
                      initial,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        fontSize: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 46),

        // ════════════════════════════════════════════════════
        //  Info section
        // ════════════════════════════════════════════════════
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              // ── Name ──
              Text(
                hasName ? profile.displayName : 'Complete your profile',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  fontStyle: hasName ? FontStyle.normal : FontStyle.italic,
                  color: hasName ? colors.onSurface : colors.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 4),

              // ── Email ──
              Text(
                profile.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontSize: 12.5,
                ),
              ),

              const SizedBox(height: 18),

              // ── Stats row ──
              Row(
                children: [
                  _Stat(value: '—', label: 'Resumes', colors: colors),
                  _StatDivider(colors: colors),
                  _Stat(value: '—', label: 'Complete', colors: colors),
                  _StatDivider(colors: colors),
                  _Stat(value: '—', label: 'Public', colors: colors),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  Stat item
// ════════════════════════════════════════════════════════════════
class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final ColorScheme colors;

  const _Stat({required this.value, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontSize: 10.5,
              letterSpacing: 0.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final ColorScheme colors;

  const _StatDivider({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.8,
      height: 26,
      color: colors.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
