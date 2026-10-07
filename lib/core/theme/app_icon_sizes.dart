import 'package:flutter/widgets.dart';
import '../responsive/responsive.dart';

abstract final class AppIconSizes {


  static double small(BuildContext context) {
    switch (Responsive.deviceType(context)) {
      case DeviceType.mobile:
        return 20;

      case DeviceType.tablet:
        return 22;

      case DeviceType.desktop:
        return 24;
    }
  }

  static double medium(BuildContext context) {
    switch (Responsive.deviceType(context)) {
      case DeviceType.mobile:
        return 24;

      case DeviceType.tablet:
        return 28;

      case DeviceType.desktop:
        return 32;
    }
  }

  static double large(BuildContext context) {
    switch (Responsive.deviceType(context)) {
      case DeviceType.mobile:
        return 32;

      case DeviceType.tablet:
        return 36;

      case DeviceType.desktop:
        return 40;
    }
  }
}
