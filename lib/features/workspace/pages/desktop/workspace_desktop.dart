// lib/features/workspace/pages/workspace_desktop.dart (Fully Modified)

import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/features/workspace/pages/canvas_page.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/export_project_button.dart';
import 'package:cookethflow/features/workspace/widgets/node_editing_toolbox.dart';
import 'package:cookethflow/features/workspace/widgets/toolbar.dart';
import 'package:cookethflow/features/workspace/widgets/undo_redo_button.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_drawer.dart';
import 'package:cookethflow/features/workspace/widgets/zoom_control_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cookethflow/features/workspace/widgets/object_text_editor.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

class WorkspaceDesktop extends StatelessWidget {
  const WorkspaceDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop =
        rh.ResponsiveLayoutHelper.getDeviceType(context) ==
            rh.DeviceType.desktop;

    return Consumer2<WorkspaceProvider,SupabaseService>(builder: (context, provider,suprovider, child) {
      return Scaffold(
        backgroundColor: provider.currentWorkspaceColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const CanvasPage(),

              const WorkspaceDrawer(),
              SizedBox(width: 20.w),
              Positioned(top: 0, left: 0.21.sw, child: UndoRedoButton(su: suprovider,)),
              // MODIFIED: Pass the WorkspaceProvider instance to the button
              Positioned(top: 0, right: 0.001.sw, child: ExportProjectButton(su: suprovider, wp: provider)),

              Positioned(right: 0, top: 0.10.sh, child: ToolBar()),

              Positioned(
                bottom: 0.h,
                right: 0.w,
                child: ZoomControlButton(),
              ),

              Consumer2<WorkspaceProvider, CanvasProvider>(
                builder: (context, workspaceProvider, canvasProvider, child) {
                  return ListenableBuilder(
                    listenable: canvasProvider.transformationController,
                    builder: (context, child) {
                      if (workspaceProvider.shouldShowObjectToolbox) {
                        final selectedObject = workspaceProvider.canvasObjects[
                            workspaceProvider.currentlySelectedObjectId!]!;
                        final objectBounds = selectedObject.getBounds();
                        final matrix =
                            canvasProvider.transformationController.value;

                        final transformedTopCenter = matrix.transform3(
                            vector_math.Vector3(objectBounds.topCenter.dx,
                                objectBounds.topCenter.dy, 0));

                        final screenPosition = Offset(
                            transformedTopCenter.x, transformedTopCenter.y);

                        const double toolboxWidth = 240;
                        const double toolboxHeight = 48;

                        return Positioned(
                          left: screenPosition.dx - (toolboxWidth / 2),
                          top: screenPosition.dy - toolboxHeight - 15,
                          child: const NodeEditingToolbox(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),

              const ObjectTextEditor(),
            ],
          ),
        ),
      );
    });
  }
}