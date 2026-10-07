import 'package:flutter/material.dart';
import 'responsive.dart';

class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    final type = Responsive.deviceType(context);

    switch (type) {
      case DeviceType.mobile:
        return mobile;

      case DeviceType.tablet:
        return tablet ?? mobile;

      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}
