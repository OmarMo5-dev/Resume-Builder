import 'package:business_os/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

import '../controllers/theme_controller.dart';
import '../widgets/settings_row.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    return Scaffold(
      appBar: CustomAppBar(title: 'Settings', icon: Icons.settings_outlined),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                const SizedBox(height: 28),

                const _SectionLabel(icon: Icons.color_lens_outlined , 'Appearance'),

                AnimatedBuilder(
                  animation: ThemeController.instance,
                  builder: (context, _) {
                    final ctrl = ThemeController.instance;

                    return _Group(
                      children: [
                        SettingsRow(
                          icon: Icons.brightness_auto_outlined,
                          title: 'Follow system',
                          subtitle: platformBrightness == Brightness.dark
                              ? 'Currently matching device dark theme'
                              : 'Currently matching device light theme',
                          trailing: Switch.adaptive(
                            value: ctrl.followSystem,
                            onChanged: (v) => ctrl.setFollowSystem(
                              v,
                              platformBrightness: platformBrightness,
                            ),
                          ),
                          onTap: () => ctrl.setFollowSystem(
                            !ctrl.followSystem,
                            platformBrightness: platformBrightness,
                          ),
                        ),

                        SettingsRow(
                          icon: ctrl.isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          title: 'Dark mode',
                          subtitle: ctrl.followSystem
                              ? 'Disabled while following system'
                              : (ctrl.isDark
                                    ? 'Dark theme is on'
                                    : 'Light theme is on'),
                          enabled: !ctrl.followSystem,
                          trailing: Switch.adaptive(
                            value: ctrl.isDark,
                            onChanged: ctrl.followSystem ? null : ctrl.setDark,
                          ),
                          onTap: ctrl.followSystem
                              ? null
                              : () => ctrl.setDark(!ctrl.isDark),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Future sections slot in here, e.g.:
                // const _SectionLabel('Notifications'),
                // _Group(children: [...]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Private helpers
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.icon});
final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        spacing: 7,
        children: [
          Icon(icon),
          Text(
            text.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: 20,
            endIndent: 20,
            color: colors.outlineVariant.withValues(alpha: 0.12),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: rows),
      ),
    );
  }
}
