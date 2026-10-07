import 'package:flutter/widgets.dart';

import 'responsive.dart';

class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final T mobile;
  final T? tablet;
  final T? desktop;

  T resolve(BuildContext context) {
    final deviceType = Responsive.deviceType(context);

    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;

      case DeviceType.tablet:
        return tablet ?? mobile;

      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}