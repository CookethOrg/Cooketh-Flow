import 'package:cookethflow/core/helpers/responsive_layout.helper.dart';
import 'package:cookethflow/features/auth/pages/desktop/signup_desktop.dart';
import 'package:cookethflow/features/auth/pages/mobile/signup_mobile.dart';
import 'package:cookethflow/features/auth/pages/tablet/signup_tablet.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget signupWidget;
    switch (ResponsiveLayoutHelper.getDeviceType(context)) {
      case DeviceType.desktop:
        signupWidget = const SignupDesktop();
        break;
      case DeviceType.tab:
        signupWidget = const SignupTablet(); // Or a tablet-specific widget
        break;
      case DeviceType.mobile:
        signupWidget = const SignupMobile();
        break;
    }
    return Scaffold(backgroundColor: Color(0XFFF8F8F8), body: signupWidget);
  }
}
