import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/providers/supabase_provider.dart';
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

    return Consumer2<WorkspaceProvider, SupabaseService>(
      builder: (context, provider, suprovider, child) {
        return Scaffold(
          backgroundColor: provider.currentWorkspaceColor,
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.h),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const CanvasPage(),
                workspaceDrawerMob(device),
                Positioned(
                  top: 120.h,
                  right: 0.h,
                  child: UndoRedoButton(su: suprovider),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 40.h),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ToolBar(),
                  ),
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
  return Consumer2<WorkspaceProvider, SupabaseService>(
    builder: (context, provider, suprovider, child) {
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
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    provider.toggleDrawer();
                  },
                  icon:
                      !provider.isDrawerOpen
                          ? Icon(
                            PhosphorIconsRegular.sidebarSimple,
                            size: 100.sp,
                            color: Colors.black,
                          )
                          : Icon(
                            Icons.close,
                            size: 100.sp,
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
                      fontSize: 72.sp,
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

                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => ExportDialog(su: suprovider),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 0.1.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Icon(
                    PhosphorIconsRegular.export,
                    color: Colors.white,
                    size: 100.sp,
                  ),
                ),
              ],
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
                          ? Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: 350.h,
                              height: 780.h,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount:
                                          provider.canvasObjectsList.length,
                                      itemBuilder: (context, index) {
                                        CanvasObject item =
                                            provider.canvasObjectsList[index];
                                        return _buildSelectableListTile(
                                          context,
                                          provider: provider,
                                          title:
                                              item.toJson()['object_type']
                                                  as String,
                                          iconData: provider
                                              .getIconForObjectType(
                                                item.toJson()['object_type'],
                                              ), // Use the helper
                                          index: index,
                                          isSelected:
                                              provider
                                                  .currentlySelectedObjectId ==
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
                              ),
                            ),
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
      leading: Icon(iconData, size: 85.sp, color: iconTextColor),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Fredrik',
          fontSize: 60.sp,
          color: iconTextColor,
        ),
      ),
      onTap: onTap,
    ),
  );
}
