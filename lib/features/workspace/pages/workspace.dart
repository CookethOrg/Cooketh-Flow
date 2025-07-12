import 'package:cookethflow/core/helpers/responsive_layout.helper.dart'
    as responsive_helper;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:cookethflow/features/workspace/pages/desktop/workspace_desktop.dart';
import 'package:cookethflow/features/workspace/pages/tablet/workspace_tablet.dart';
import 'package:cookethflow/features/workspace/pages/mobile/workspace_mobile.dart';

class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget workspaceScreen;

    switch (responsive_helper.ResponsiveLayoutHelper.getDeviceType(context)) {
      case responsive_helper.DeviceType.desktop:
        workspaceScreen = const WorkspaceDesktop();
        break;
      case responsive_helper.DeviceType.tab:
        workspaceScreen = const WorkspaceTablet();
        break;
      case responsive_helper.DeviceType.mobile:
        workspaceScreen = const WorkspaceMobile();
        break;
    }

    return Scaffold(
      body: workspaceScreen,
    );
  }
}
