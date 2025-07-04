import 'package:cookethflow/core/helpers/responsive_layout.helper.dart';
import 'package:cookethflow/features/auth/pages/desktop/login_desktop.dart';
import 'package:cookethflow/features/auth/pages/mobile/login_mobile.dart';
import 'package:cookethflow/features/auth/pages/tablet/login_tablet.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget loginWidget;
    switch (ResponsiveLayoutHelper.getDeviceType(context)) {
      case DeviceType.desktop:
        loginWidget = LoginDesktop();
        break;
      case DeviceType.tab:
        loginWidget = LoginTablet();
        break;
      case DeviceType.mobile:
        loginWidget = LoginMobile();
        break;
    }
    return Scaffold(backgroundColor: Color(0XFFF8F8F8), body: loginWidget);
  }
}
