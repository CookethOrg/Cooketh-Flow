import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:cookethflow/features/workspace/pages/canvas_page.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/export_dialog.dart';
import 'package:cookethflow/features/workspace/widgets/export_project_button.dart';
import 'package:cookethflow/features/workspace/widgets/node_editing_toolbox.dart';
import 'package:cookethflow/features/workspace/widgets/toolbar.dart';
import 'package:cookethflow/features/workspace/widgets/undo_redo_button.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_drawer.dart';
import 'package:cookethflow/features/workspace/widgets/zoom_control_button.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cookethflow/features/workspace/widgets/object_text_editor.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

class WorkspaceMobile extends StatelessWidget {
  const WorkspaceMobile({super.key});

  @override
  Widget build(BuildContext context) {
    rh.DeviceType device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Consumer<WorkspaceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: provider.currentWorkspaceColor,
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const CanvasPage(),
                workspaceDrawerMob(device),
                Positioned(right: 10.h, top: 120.h, child: UndoRedoButton()),
                Positioned(bottom: 100.h, left: 100.h, child: ToolBar()),

                Positioned(
                  bottom: 0.h,
                  right: 230.h,
                  child: ZoomControlButton(),
                ),

                Consumer2<WorkspaceProvider, CanvasProvider>(
                  builder: (context, workspaceProvider, canvasProvider, child) {
                    // Listen for changes in the transformation to update position
                    return ListenableBuilder(
                      listenable: canvasProvider.transformationController,
                      builder: (context, child) {
                        if (workspaceProvider.shouldShowObjectToolbox) {
                          final selectedObject =
                              workspaceProvider.canvasObjects[workspaceProvider
                                  .currentlySelectedObjectId!]!;
                          final objectBounds = selectedObject.getBounds();
                          final matrix =
                              canvasProvider.transformationController.value;

                          // Use the matrix to find the object's top-center position on the screen
                          final transformedTopCenter = matrix.transform3(
                            vector_math.Vector3(
                              objectBounds.topCenter.dx,
                              objectBounds.topCenter.dy,
                              0,
                            ),
                          );

                          // Calculate the screen position
                          final screenPosition = Offset(
                            transformedTopCenter.x,
                            transformedTopCenter.y,
                          );

                          // Define an approximate size for the toolbox to help with centering.
                          const double toolboxWidth = 240;
                          const double toolboxHeight = 48;

                          return Positioned(
                            left: screenPosition.dx - (toolboxWidth / 2),
                            top:
                                screenPosition.dy -
                                toolboxHeight -
                                15, // 15px margin above object
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
      },
    );
  }
}

Widget workspaceDrawerMob(rh.DeviceType device) {
  return Consumer<WorkspaceProvider>(
    builder: (context, provider, child) {
      Color defaultBorderColor = const Color(0xFFD9D9D9);

      // Check if currentWorkspace is set before accessing its properties
      final String workspaceName =
          provider.currentWorkspace?.name ?? "Loading...";

      return GestureDetector(
        onTap: () {
          // Optional: Close drawer if tapping outside visible content
          // if (provider.isDrawerOpen) {
          //   provider.toggleDrawer();
          // }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Always visible header row
            Container(
              padding: EdgeInsets.only(bottom: 10, top: 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      provider.toggleDrawer();
                    },
                    icon: Icon(
                      PhosphorIconsRegular.sidebarSimple,
                      size: 80.sp,
                      color: Colors.black,
                    ),
                    splashRadius: 24.r,
                    tooltip: 'Toggle Sidebar',
                  ),
                  SizedBox(width: 30.w),
                  Expanded(
                    child: TextField(
                      controller: provider.workspaceNameController,
                      style: TextStyle(
                        fontFamily: 'Fredrik',
                        fontSize: 62.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: 0.6,
                      ),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),

                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ExportDialog(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: 25.h,
                          horizontal: 2.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Icon(
                        PhosphorIconsRegular.export,
                        color: Colors.white,
                        size: 80.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: AnimatedOpacity(
                opacity: provider.isDrawerOpen ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child:
                      provider.isDrawerOpen
                          ? Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              device == rh.DeviceType.desktop
                                  ? SizedBox(height: 20.h)
                                  : SizedBox(height: 10.h),
                              const Divider(color: Colors.grey, thickness: 0.5),
                              SizedBox(height: 10.h),
                              Expanded(
                                child: ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemCount: provider.canvasObjectsList.length,
                                  separatorBuilder:
                                      (context, index) =>
                                          device == rh.DeviceType.desktop
                                              ? SizedBox(height: 8.h)
                                              : SizedBox(height: 2.h),
                                  itemBuilder: (context, index) {
                                    CanvasObject item =
                                        provider.canvasObjectsList[index];
                                    return _buildSelectableListTile(
                                      context,
                                      provider: provider,
                                      title:
                                          item.toJson()['object_type']
                                              as String,
                                      iconData: provider.getIconForObjectType(
                                        item.toJson()['object_type'],
                                      ), // Use the helper
                                      index: index,
                                      isSelected:
                                          provider.currentlySelectedObjectId ==
                                          item.id,
                                      device: device,
                                      onTap: () {
                                        provider.changeCurrentlySelectedObj(
                                          item.id,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                          : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildSelectableListTile(
  BuildContext context, {
  required WorkspaceProvider provider,
  required String title,
  required IconData iconData,
  required int index,
  required bool isSelected,
  required VoidCallback onTap,
  required rh.DeviceType device,
}) {
  Color iconTextColor = isSelected ? Colors.blue : Colors.black;

  return Container(
    color: Colors.white,
    child: ListTile(
      leading: Icon(
        iconData,
        size: device == rh.DeviceType.desktop ? 24.sp : 35.sp,
        color: iconTextColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Fredrik',
          fontSize: device == rh.DeviceType.desktop ? 18.sp : 28.sp,
          color: iconTextColor,
        ),
      ),
      onTap: onTap,
    ),
  );
}
