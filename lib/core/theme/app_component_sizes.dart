import 'package:flutter/widgets.dart';
import '../responsive/responsive.dart';

abstract final class AppComponentSizes {
  static double buttonHeight(BuildContext context) {
    switch (Responsive.deviceType(context)) {
      case DeviceType.mobile:
        return 48;

      case DeviceType.tablet:
        return 50;

      case DeviceType.desktop:
        return 52;
    }
  }

  static double textFieldHeight(BuildContext context) {
    switch (Responsive.deviceType(context)) {
      case DeviceType.mobile:
        return 52;

      case DeviceType.tablet:
        return 54;

      case DeviceType.desktop:
        return 56;
    }
  }

  static double avatarSmall(BuildContext context) {
    switch (Responsive.deviceType(context)) {
      case DeviceType.mobile:
        return 32;

      case DeviceType.tablet:
        return 36;

      case DeviceType.desktop:
        return 40;
    }
  }

  static double avatarMedium(BuildContext context) {
    switch (Responsive.deviceType(context)) {
      case DeviceType.mobile:
        return 40;

      case DeviceType.tablet:
        return 48;

      case DeviceType.desktop:
        return 56;
    }
  }
}