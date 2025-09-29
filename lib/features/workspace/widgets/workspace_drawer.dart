import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/router/app_route_const.dart';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:provider/provider.dart';
import 'package:cookethflow/core/utils/enums.dart' as en;

class WorkspaceDrawer extends StatelessWidget {
  const WorkspaceDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Consumer2<WorkspaceProvider, SupabaseService>(
      builder: (context, provider, suprovider, child) {
        Color defaultBorderColor =
            suprovider.isDark
                ? Color.fromRGBO(75, 75, 75, 1)
                : const Color(0xFFD9D9D9);

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
            height:
                provider.isDrawerOpen
                    ? 1.sh
                    : device == en.DeviceType.desktop
                    ? 0.09.sh
                    : 0.08.sh,
            width: device == en.DeviceType.desktop ? 0.195.sw : 0.27.sw,
            padding: EdgeInsets.symmetric(
              horizontal: device == en.DeviceType.desktop ? 24.w : 15.w,
              vertical: device == en.DeviceType.desktop ? 16.h : 10.h,
            ),
            decoration: BoxDecoration(
              color:
                  suprovider.isDark
                      ? Color.fromRGBO(48, 48, 48, 1)
                      : Colors.white,
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

                        context.goNamed(RouteName.dashboard);
                        provider.exitWorkspace();
                      },
                      icon: Icon(
                        PhosphorIconsRegular.arrowLeft,
                        size: device == en.DeviceType.desktop ? 32.sp : 50.sp,
                        color: suprovider.isDark ? Colors.white : Colors.black,
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
                              device == en.DeviceType.desktop ? 24.sp : 42.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              suprovider.isDark ? Colors.white : Colors.black,
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
                    SizedBox(
                      width: device == en.DeviceType.desktop ? 50.w : 20.w,
                    ),
                    IconButton(
                      onPressed: () {
                        provider.toggleDrawer();
                      },
                      icon:
                          !provider.isDrawerOpen
                              ? Icon(
                                PhosphorIconsRegular.sidebarSimple,
                                size:
                                    device == en.DeviceType.desktop
                                        ? 32.sp
                                        : 50.sp,
                                color:
                                    suprovider.isDark
                                        ? Colors.white
                                        : Colors.black,
                              )
                              : Icon(
                                Icons.close,
                                size:
                                    device == en.DeviceType.desktop
                                        ? 32.sp
                                        : 50.sp,
                                color:
                                    suprovider.isDark
                                        ? Colors.white
                                        : Colors.black,
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
                                  device == en.DeviceType.desktop
                                      ? SizedBox(height: 20.h)
                                      : SizedBox(height: 10.h),
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
                                              device == en.DeviceType.desktop
                                                  ? SizedBox(height: 8.h)
                                                  : SizedBox(height: 2.h),
                                      itemBuilder: (context, index) {
                                        CanvasObject item =
                                            provider.canvasObjectsList[index];
                                        return _buildSelectableListTile(
                                          context,
                                          provider: provider,
                                          title:
                                              '${index + 1}  ${item.toJson()['object_type'] as String}',
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
                                          su: suprovider,
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
    required en.DeviceType device,
    required SupabaseService su,
  }) {
    Color iconTextColor =
        isSelected
            ? Colors.blue
            : su.isDark
            ? Colors.white
            : Colors.black;

    return Container(
      color: su.isDark ? Color.fromRGBO(48, 48, 48, 1) : Colors.white,
      child: ListTile(
        leading: Icon(
          iconData,
          size: device == en.DeviceType.desktop ? 24.sp : 35.sp,
          color: iconTextColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Fredrik',
            fontSize: device == en.DeviceType.desktop ? 18.sp : 28.sp,
            color: iconTextColor,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
