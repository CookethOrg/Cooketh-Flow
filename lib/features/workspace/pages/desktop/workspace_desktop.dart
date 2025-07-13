import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/features/workspace/widgets/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_drawer.dart';
import 'package:cookethflow/features/workspace/widgets/toolbar.dart';
import 'package:cookethflow/features/workspace/widgets/colour_picker_bg.dart';
import 'package:cookethflow/features/workspace/widgets/sticky_notes.dart';
import 'package:cookethflow/features/workspace/widgets/node_colour.dart';

class WorkspaceDesktop extends StatelessWidget {
  const WorkspaceDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFF8F8F8),
      // body: NodeColourPicker()
      // body: ColorPickerWidget(
      //   onColorChanged: (Color primaryColor) {
      //     // handle color change here
      //   },}
      body: Stack(
        children: [
          // Top Bar
          Positioned(
            top: 40.h,
            left: 40.w,
            right: 40.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back & Title
                Row(
                  children: [
                    //workspace Drawer
                    const WorkspaceDrawer(),
                    SizedBox(width: 20.w),
                    //Undo/redo
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            device == rh.DeviceType.desktop ? 24.w : 32.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFFD9D9D9),
                          width: 1.2,
                        ),
                      ),
                      child: SizedBox(
                        height: 56.h,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                PhosphorIconsRegular.arrowArcLeft,
                                size: 32.sp,
                                color: Colors.black,
                              ),
                            ),
                            _verticalDivider(), // Use custom divider
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                PhosphorIconsRegular.arrowArcRight,
                                size: 32.sp,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: primaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: 32.h,
                          horizontal: 24.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Export Flowchart',
                            style: TextStyle(
                              fontFamily: 'Fredrik',
                              fontSize: 18.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Icon(
                            PhosphorIconsRegular.export,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right Toolbar
          Align(
            alignment: Alignment.centerRight,
              child: const ToolBar()
          ),
          

          // Zoom Control
          Positioned(
            bottom: 40.h,
            right: 40.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              decoration: BoxDecoration(
                border: Border.all(color: Color(0XFFD9D9D9), width: 1.2),
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "100%",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 24.sp,
                    ),
                  ),
                  SizedBox(width: 8.w,),
                  _verticalDivider(),
                  SizedBox(width: 8.w,),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(PhosphorIconsRegular.plus, size: 24.sp),
                    visualDensity: VisualDensity.compact,
                  ),
                  SizedBox(width: 8.w,),
                  _verticalDivider(),
                  SizedBox(width: 8.w,),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(PhosphorIconsRegular.minus, size: 24.sp),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 24.h,
      width: 1.2.w,
      color: const Color(0xFFD9D9D9),
      margin: EdgeInsets.symmetric(horizontal: 8.w),
    );
  }
}
