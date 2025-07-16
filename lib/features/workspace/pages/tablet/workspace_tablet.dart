import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/features/workspace/pages/canvas_page.dart';
import 'package:cookethflow/features/workspace/widgets/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_drawer.dart';

class WorkspaceTablet extends StatelessWidget {
  const WorkspaceTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h), // Adjusted for tablet
        child: Stack(
          children: [

            CanvasPage(),
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back & Title
                Row(
                  children: [
                    const WorkspaceDrawer(),
                    SizedBox(width: 16.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: device == rh.DeviceType.tab ? 20.w : 24.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
                      ),
                      child: SizedBox(
                        height: 32.h,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(PhosphorIconsRegular.arrowArcLeft, size: 28.sp, color: Colors.black),
                            ),
                            _verticalDivider(),
                            IconButton(
                              onPressed: () {},
                              icon: Icon(PhosphorIconsRegular.arrowArcRight, size: 28.sp, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w), // Adjusted for tablet
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Export Flowchart', style: TextStyle(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w500)),
                      SizedBox(width: 12.w),
                      Icon(PhosphorIconsRegular.export, color: Colors.white, size: 20.sp),
                    ],
                  ),
                ),
              ],
            ),
            // Right Toolbar
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 10.w), // Slight padding for tablet alignment
                child: const ToolBar(),
              ),
            ),
            // Zoom Control
            Positioned(
              bottom: 0.h,
              right: 0.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h), // Adjusted for tablet
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("100%", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.w500)),
                    SizedBox(width: 6.w),
                    _verticalDivider(),
                    SizedBox(width: 6.w),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(PhosphorIconsRegular.plus, size: 20.sp),
                      visualDensity: VisualDensity.compact,
                    ),
                    SizedBox(width: 6.w),
                    _verticalDivider(),
                    SizedBox(width: 6.w),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(PhosphorIconsRegular.minus, size: 20.sp),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 20.h,
      width: 1.w,
      color: const Color(0xFFD9D9D9),
      margin: EdgeInsets.symmetric(horizontal: 6.w),
    );
  }
}