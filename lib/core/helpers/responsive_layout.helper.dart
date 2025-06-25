import 'package:flutter/material.dart';

enum DeviceType { mobile, tab, desktop }

class ResponsiveLayoutHelper {
  static const int mobileMaxWidth = 375;
  static const int tabletMaxWidth = 768;
  static const int desktopMaxWidth = 1024;

  static DeviceType getDeviceType(BuildContext context) {
    final deviceSize = MediaQuery.sizeOf(context);
    final deviceWidth = deviceSize.width;
    if (deviceWidth > ResponsiveLayoutHelper.desktopMaxWidth) {
      return DeviceType.desktop;
    }

    if (deviceWidth > ResponsiveLayoutHelper.tabletMaxWidth) {
      return DeviceType.tab;
    }

    return DeviceType.mobile;
  }
}
