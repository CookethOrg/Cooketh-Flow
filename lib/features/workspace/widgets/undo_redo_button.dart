import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/features/workspace/widgets/vertical_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UndoRedoButton extends StatelessWidget {
  const UndoRedoButton({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop =
        rh.ResponsiveLayoutHelper.getDeviceType(context) ==
        rh.DeviceType.desktop;
      
    bool isTab =
        rh.ResponsiveLayoutHelper.getDeviceType(context) ==
        rh.DeviceType.tab;
      
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 24.w :isTab? 20.w : 15.w,
        vertical:isDesktop? 17.h : isTab? 13.h : 10.h, 
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
      ),
      child: SizedBox(
        height:isDesktop?  56.h : isTab ? 56.h : 40.h, // Fixed height for consistency
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                PhosphorIconsRegular.arrowArcLeft,
                size:isDesktop ? 32.sp : isTab? 55.sp : 75.sp,
                color: Colors.black,
              ),
            ),
            VerticalCustomDivider(), // Custom divider
            IconButton(
              onPressed: () {},
              icon: Icon(
                PhosphorIconsRegular.arrowArcRight,
                size:isDesktop ? 32.sp : isTab? 55.sp : 75.sp,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}