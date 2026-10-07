import 'package:flutter/widgets.dart';
import '../responsive/responsive.dart';

abstract final class AppSpacing {
  // Base design scale.
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double section = 48;

  // Responsive page horizontal padding.
  static double pageHorizontal(BuildContext context) {
    switch (Responsive.deviceType(context)) {
      case DeviceType.mobile:
        return 16;

      case DeviceType.tablet:
        return 24;

      case DeviceType.desktop:
        return 32;
    }
  }

  // Responsive page vertical padding.
  static double pageVertical(BuildContext context) {
    switch (Responsive.deviceType(context)) {
      case DeviceType.mobile:
        return 16;

      case DeviceType.tablet:
        return 24;

      case DeviceType.desktop:
        return 32;
    }
  }

  // Responsive section spacing.
  static double sectionSpacing(BuildContext context) {
    switch (Responsive.deviceType(context)) {
      case DeviceType.mobile:
        return 32;

      case DeviceType.tablet:
        return 40;

      case DeviceType.desktop:
        return 48;
    }
  }

  // Responsive screen/content gap.
  static double contentGap(BuildContext context) {
    switch (Responsive.deviceType(context)) {
      case DeviceType.mobile:
        return 16;

      case DeviceType.tablet:
        return 20;

      case DeviceType.desktop:
        return 24;
    }
  }
}