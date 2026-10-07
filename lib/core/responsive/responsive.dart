import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

abstract final class Responsive {
  static DeviceType deviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < AppBreakpoints.tablet) {
      return DeviceType.mobile;
    }

    if (width < AppBreakpoints.desktop) {
      return DeviceType.tablet;
    }

    return DeviceType.desktop;
  }

  static bool isMobile(BuildContext context) {
    return deviceType(context) == DeviceType.mobile;
  }

  static bool isTablet(BuildContext context) {
    return deviceType(context) == DeviceType.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return deviceType(context) == DeviceType.desktop;
  }
}