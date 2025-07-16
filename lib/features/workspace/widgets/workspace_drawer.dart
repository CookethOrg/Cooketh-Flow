import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:provider/provider.dart';

// Assuming primaryColor is defined somewhere, e.g., core/theme/colors.dart
import 'package:cookethflow/core/theme/colors.dart';

class WorkspaceDrawer extends StatelessWidget {
  const WorkspaceDrawer({super.key});

  final List<Map<String, dynamic>> _drawerItems = const [
    {'title': 'Home', 'icon': PhosphorIconsRegular.house},
    {'title': 'My Projects', 'icon': PhosphorIconsRegular.folder},
    {'title': 'Settings', 'icon': PhosphorIconsRegular.gearSix},
    {'title': 'Help', 'icon': PhosphorIconsRegular.info},
  ];

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Consumer<WorkspaceProvider>(
      builder: (context, provider, child) {
        Color defaultBorderColor = const Color(0xFFD9D9D9);

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
              border: Border.all(
                color: defaultBorderColor,
                width: 1.2,
              ),
            ),
            child: Column( // This is the main Column within AnimatedContainer
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Always visible header row
                Row(
                  mainAxisSize: MainAxisSize.min, // Keep this for the header row
                  children: [
                    IconButton(
                      onPressed: () {
                        context.pop();
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
                    Text(
                      'Cooketh Flow',
                      style: TextStyle(
                        fontFamily: 'Fredrik',
                        fontSize: device == rh.DeviceType.desktop ? 24.sp : 32.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: 0.6,
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
                // Animated content below the header
                // This is now wrapped in an Expanded, giving it a flexible height
                // within the main Column, which has a bounded height from AnimatedContainer.
                Expanded( // <<<--- Changed this to Expanded
                  child: AnimatedOpacity(
                    opacity: provider.isDrawerOpen ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: provider.isDrawerOpen
                          ? Column(
                              // mainAxisSize should be max for this inner column
                              // because it's filling the Expanded space.
                              mainAxisSize: MainAxisSize.max, // <<<--- Ensure max here
                              children: [
                                SizedBox(height: 20.h),
                                const Divider(color: Colors.grey, thickness: 0.5),
                                SizedBox(height: 10.h),
                                // --- ListView.builder for dynamic tiles ---
                                // Now ListView is a direct Flexible child of a Column
                                // that fills its Expanded parent. This is the correct setup.
                                Expanded( // <<<--- Changed Flexible to Expanded for the ListView
                                  child: ListView.separated(
                                    padding: EdgeInsets.zero,
                                    itemCount: _drawerItems.length,
                                    separatorBuilder: (context, index) => SizedBox(height: 8.h),
                                    itemBuilder: (context, index) {
                                      final item = _drawerItems[index];
                                      return _buildSelectableListTile(
                                        context,
                                        provider: provider,
                                        title: item['title'] as String,
                                        iconData: item['icon'] as IconData,
                                        index: index,
                                        isSelected: provider.selectedTileIndex == index,
                                        onTap: () {
                                          provider.selectTile(index);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(), // Renders nothing when closed
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
    // BorderSide tileBorder = isSelected ? BorderSide(color: Colors.blue, width: 2.0) : BorderSide.none;

    return Container(
      color: Colors.white,
      child: ListTile(
        leading: Icon(
          iconData,
          size: 24.sp,
          color: iconTextColor,
        ),
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