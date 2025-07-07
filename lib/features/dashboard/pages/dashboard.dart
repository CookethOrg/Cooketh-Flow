import 'package:cookethflow/core/helpers/responsive_layout.helper.dart'
    as responsive_helper;
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/features/dashboard/pages/desktop/dashboard_desktop.dart';
import 'package:cookethflow/features/dashboard/pages/mobile/dashboard_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget dashboardScreen;
    switch (responsive_helper.ResponsiveLayoutHelper.getDeviceType(context)) {
      case responsive_helper.DeviceType.desktop:
        dashboardScreen = DashboardDesktop();
        break;
      case responsive_helper.DeviceType.tab:
        dashboardScreen = DashboardDesktop();
        break;
      case responsive_helper.DeviceType.mobile:
        dashboardScreen = DashboardMobile();
        break;
    }
    return Consumer<SupabaseService>(
      builder: (context, supa, child) {
        return Scaffold(
          backgroundColor: Color.fromRGBO(248, 248, 248, 1),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: dashboardScreen,
          ),
        );
      },
    );
  }
}
