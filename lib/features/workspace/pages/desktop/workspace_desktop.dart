import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/workspace/pages/canvas_page.dart';
import 'package:cookethflow/features/workspace/widgets/export_project_button.dart';
import 'package:cookethflow/features/workspace/widgets/toolbar.dart'; // Assuming this might be used later
import 'package:cookethflow/features/workspace/widgets/undo_redo_button.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_drawer.dart';
import 'package:cookethflow/features/workspace/widgets/zoom_control_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class WorkspaceDesktop extends StatelessWidget {
  const WorkspaceDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine device type for responsive adjustments
    bool isDesktop =
        rh.ResponsiveLayoutHelper.getDeviceType(context) ==
        rh.DeviceType.desktop;

    return Scaffold(
      backgroundColor: const Color(0xFFFF8F8F8),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
        child: Stack(
          children: [
            // 1. CanvasPage - This should be the base layer, filling the entire available space
            const CanvasPage(),

            const WorkspaceDrawer(),
            SizedBox(width: 20.w),
            // Undo/Redo Controls Container
            Positioned(top: 0,left: 0.21.sw,child: UndoRedoButton()),
            // Export project button
            Positioned(top: 0,right: 0.02.sw,child: ExportProjectButton()),

            // 3. Zoom Control - Positioned at the bottom right of the Stack
            Positioned(
              bottom: 0.h, // Aligns to the bottom edge of the Stack
              right: 0.w, // Aligns to the right edge of the Stack
              child: ZoomControlButton(),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function for the vertical divider
Widget _verticalDivider() {
  return Container(
    height: 24.h,
    width: 1.2.w,
    color: const Color(0xFFD9D9D9),
    margin: EdgeInsets.symmetric(horizontal: 8.w),
  );
}
