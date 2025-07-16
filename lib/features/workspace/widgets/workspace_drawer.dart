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
        return GestureDetector(
          onTap: () {
            // handle tap
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 500),
            height: provider.isDrawerOpen ? 1.sh : 0.1.sh,
            padding: EdgeInsets.symmetric(
              horizontal: device == rh.DeviceType.desktop ? 24.w : 32.w,
              vertical: 16.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Color(0XFFD9D9D9), width: 1.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
              mainAxisSize: MainAxisSize.min,
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
            )
              ],
            ),
          ),
        );
      },
    );
  }
}
