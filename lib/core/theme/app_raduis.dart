import 'package:flutter/widgets.dart';

import '../responsive/responsive.dart';

abstract final class AppRadius {
  static const double sm = 6;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 18;
  static const double xxl = 24;
  static const double pill = 999;

  static double card(BuildContext context) {
    switch (Responsive.deviceType(context)) {
      case DeviceType.mobile:
        return 14;

      case DeviceType.tablet:
        return 16;

      case DeviceType.desktop:
        return 18;
    }
  }

  static double dialog(BuildContext context) {
    switch (Responsive.deviceType(context)) {
      case DeviceType.mobile:
        return 18;

      case DeviceType.tablet:
        return 20;

      case DeviceType.desktop:
        return 24;
    }
  }
}
