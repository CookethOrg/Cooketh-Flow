import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/widgets/vertical_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;

class ZoomControlButton extends StatelessWidget {
  const ZoomControlButton({super.key});

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return Consumer2<CanvasProvider, SupabaseService>(
      builder: (context, canvasProvider, suprovider, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  suprovider.isDark
                      ? Color.fromRGBO(75, 75, 75, 1)
                      : const Color(0XFFD9D9D9),
              width: 1.2,
            ),
            color:
                suprovider.isDark
                    ? Color.fromRGBO(48, 48, 48, 1)
                    : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Text(
              //   "${canvasProvider.currentZoomPercentage.toStringAsFixed(0)}%", // Display current zoom
              //   style: TextStyle(
              //     color: suprovider.isDark ? Colors.white : Colors.black,
              //     fontWeight: FontWeight.w500,
              //     fontSize:
              //         device == rh.DeviceType.desktop
              //             ? 24.sp
              //             : device == rh.DeviceType.tab
              //             ? 24.sp
              //             : 40.sp,
              //   ),
              // ),
              // SizedBox(
              //   width:
              //       device == rh.DeviceType.desktop
              //           ? 8.w
              //           : device == rh.DeviceType.tab
              //           ? 8.w
              //           : 12.w,
              // ),
              // VerticalCustomDivider(),
              SizedBox(width: 8.w),
              IconButton(
                tooltip: "Press CTRL + Z",
                onPressed: () {
                  canvasProvider.zoomIn(); // Call zoomIn method
                },
                icon: Icon(
                  PhosphorIconsRegular.plus,
                  size:
                      device == rh.DeviceType.desktop
                          ? 24.sp
                          : device == rh.DeviceType.tab
                          ? 24.sp
                          : 40.sp,
                ),
                visualDensity: VisualDensity.compact,
              ),
              SizedBox(width: 8.w),
              VerticalCustomDivider(),
              SizedBox(width: 8.w),
              IconButton(
                tooltip: 'Press CTRL + X',
                onPressed: () {
                  canvasProvider.zoomOut(); // Call zoomOut method
                },
                icon: Icon(
                  PhosphorIconsRegular.minus,
                  size:
                      device == rh.DeviceType.desktop
                          ? 24.sp
                          : device == rh.DeviceType.tab
                          ? 24.sp
                          : 40.sp,
                ),
                visualDensity: VisualDensity.compact,
              ),
              SizedBox(width: 8.w),
              VerticalCustomDivider(),
              SizedBox(width: 8.w),
              IconButton(
                onPressed: () {
                  canvasProvider.resetZoom(); // Call resetZoom method
                },
                icon: Icon(
                  PhosphorIconsRegular.resize,
                  size:
                      device == rh.DeviceType.desktop
                          ? 24.sp
                          : device == rh.DeviceType.tab
                          ? 24.sp
                          : 60.sp,
                ), // Icon for reset
                visualDensity: VisualDensity.compact,
                tooltip: 'Reset Zoom\nPress CTRL + R',
              ),
            ],
          ),
        );
      },
    );
  }
}
