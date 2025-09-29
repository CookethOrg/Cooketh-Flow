import 'package:flutter/material.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cookethflow/core/utils/enums.dart' as en;

class VerticalCustomDivider extends StatelessWidget {
  const VerticalCustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop =
        rh.ResponsiveLayoutHelper.getDeviceType(context) ==
        en.DeviceType.desktop;
    bool isTab =
        rh.ResponsiveLayoutHelper.getDeviceType(context) == en.DeviceType.tab;
    return Container(
      height: 24.h,
      width:
          isDesktop
              ? 1.5.w
              : isTab
              ? 1.5.w
              : 7.5.w,
      color: const Color(0xFFD9D9D9),
      margin: EdgeInsets.symmetric(horizontal: 8.w),
    );
  }
}
