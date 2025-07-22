import 'package:cookethflow/core/router/app_route_const.dart';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:provider/provider.dart';

class WorkspaceDrawer extends StatelessWidget {
  const WorkspaceDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);

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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: provider.isDrawerOpen ? 1.sh : 0.08.sh,
            width: 0.2.sw,
            padding: EdgeInsets.symmetric(
              horizontal: device == rh.DeviceType.desktop ? 24.w : 32.w,
              vertical: 16.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: defaultBorderColor, width: 1.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Always visible header row
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        // Ensure exitWorkspace is called when navigating back
                        
                        context
                            .goNamed(
                              RouteName.dashboard,
                              pathParameters: {
                                'username':
                                    provider
                                        .supabaseService
                                        .currentUser!
                                        .name ??
                                    "Notfound",
                              },
                            );
                            provider.exitWorkspace();
                      },
                      icon: Icon(
                        PhosphorIconsRegular.arrowLeft,
                        size: 32.sp,
                        color: Colors.black,
                      ),
                      splashRadius: 24.r,
                      tooltip: 'Back',
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: TextField(
                        controller: provider.workspaceNameController,
                        style: TextStyle(
                          fontFamily: 'Fredrik',
                          fontSize:
                              device == rh.DeviceType.desktop ? 24.sp : 32.sp,
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
                    SizedBox(width: 80.w),
                    IconButton(
                      onPressed: () {
                        provider.toggleDrawer();
                      },
                      icon: Icon(
                        PhosphorIconsRegular.sidebarSimple,
                        size: 32.sp,
                        color: Colors.black,
                      ),
                      splashRadius: 24.r,
                      tooltip: 'Toggle Sidebar',
                    ),
                  ],
                ),
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
                                  SizedBox(height: 20.h),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 0.5,
                                  ),
                                  SizedBox(height: 10.h),
                                  Expanded(
                                    child: ListView.separated(
                                      padding: EdgeInsets.zero,
                                      itemCount:
                                          provider.canvasObjectsList.length,
                                      separatorBuilder:
                                          (context, index) =>
                                              SizedBox(height: 8.h),
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
  }) {
    Color iconTextColor = isSelected ? Colors.blue : Colors.black;

    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(iconData, size: 24.sp, color: iconTextColor),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Fredrik',
            fontSize: 18.sp,
            color: iconTextColor,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
