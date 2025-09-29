import 'package:cookethflow/core/helpers/responsive_layout.helper.dart'
    as responsive_helper;
import 'package:flutter/material.dart';
import 'package:cookethflow/features/workspace/pages/desktop/workspace_desktop.dart';
import 'package:cookethflow/features/workspace/pages/tablet/workspace_tablet.dart';
import 'package:cookethflow/features/workspace/pages/mobile/workspace_mobile.dart';
import 'package:cookethflow/core/utils/enums.dart' as en;

class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    Widget workspaceScreen;

    switch (responsive_helper.ResponsiveLayoutHelper.getDeviceType(context)) {
      case en.DeviceType.desktop:
        workspaceScreen = const WorkspaceDesktop();
        break;
      case en.DeviceType.tab:
        workspaceScreen = const WorkspaceTablet();
        break;
      case en.DeviceType.mobile:
        workspaceScreen = const WorkspaceMobile();
        break;
    }

    return Scaffold(
      body: workspaceScreen,
    );
  }
}
