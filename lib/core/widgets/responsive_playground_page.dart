import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../responsive/responsive.dart';
import '../theme/app_component_sizes.dart';
import '../theme/app_icon_sizes.dart';
import '../theme/app_raduis.dart';
import '../theme/app_spacing.dart';

class ResponsivePlaygroundPage extends StatelessWidget {
 const  ResponsivePlaygroundPage({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        actions: [
          PopupMenuButton<Locale>(
            initialValue: currentLocale,
            onSelected: onLocaleChanged,
            tooltip: 'Language',
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: Locale('ar'),
                  child: Text('العربية'),
                ),
                PopupMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
              ];
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.language),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.pageHorizontal(context),
            vertical: AppSpacing.pageVertical(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDeviceInfo(context),

              SizedBox(
                height: AppSpacing.sectionSpacing(context),
              ),

              _buildTypographySection(context),

              SizedBox(
                height: AppSpacing.sectionSpacing(context),
              ),

              _buildSpacingSection(context),

              SizedBox(
                height: AppSpacing.sectionSpacing(context),
              ),

              _buildIconsSection(context),

              SizedBox(
                height: AppSpacing.sectionSpacing(context),
              ),

              _buildComponentsSection(context),

              SizedBox(
                height: AppSpacing.sectionSpacing(context),
              ),

              _buildCardsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(
          AppSpacing.contentGap(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dashboard,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Width: ${size.width.toStringAsFixed(0)}',
            ),
            Text(
              'Height: ${size.height.toStringAsFixed(0)}',
            ),
            Text(
              'Type: ${Responsive.deviceType(context).name}',
            ),
            const SizedBox(height: 8),
            Text(
              'Direction: '
                  '${Directionality.of(context) == TextDirection.rtl ? 'RTL' : 'LTR'}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypographySection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.customers,
          style: theme.textTheme.titleLarge,
        ),

        const SizedBox(height: 16),

        Text(
          l10n.products,
          style: theme.textTheme.displayLarge,
        ),

        Text(
          l10n.orders,
          style: theme.textTheme.headlineLarge,
        ),

        Text(
          l10n.inventory,
          style: theme.textTheme.titleLarge,
        ),

        Text(
          l10n.payments,
          style: theme.textTheme.bodyLarge,
        ),

        Text(
          l10n.analytics,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSpacingSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settings,
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            AppSpacing.contentGap(context),
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(
              AppRadius.card(context),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: AppSpacing.contentGap(context),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(
                    AppRadius.sm,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Content Gap: '
                    '${AppSpacing.contentGap(context)}',
              ),

              Text(
                'Page Horizontal: '
                    '${AppSpacing.pageHorizontal(context)}',
              ),

              Text(
                'Page Vertical: '
                    '${AppSpacing.pageVertical(context)}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.notifications,
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Icon(
              Icons.home_outlined,
              size: AppIconSizes.small(context),
            ),

            const SizedBox(width: 20),

            Icon(
              Icons.dashboard_outlined,
              size: AppIconSizes.medium(context),
            ),

            const SizedBox(width: 20),

            Icon(
              Icons.business_outlined,
              size: AppIconSizes.large(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComponentsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.services,
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: AppComponentSizes.buttonHeight(context),
          width: double.infinity,
          child: FilledButton(
            onPressed: () {},
            child: Text(l10n.add),
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          height: AppComponentSizes.textFieldHeight(context),
          child: TextField(
            textDirection: Directionality.of(context),
            decoration: InputDecoration(
              hintText: l10n.search,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reports,
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 16),

        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final columns = width >= 1024
                ? 4
                : width >= 600
                ? 2
                : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.contentGap(context),
                mainAxisSpacing: AppSpacing.contentGap(context),
                childAspectRatio: 1.5,
              ),
              itemBuilder: (context, index) {
                return Card(
                  child: Center(
                    child: Text(
                      '${l10n.orders} ${index + 1}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}