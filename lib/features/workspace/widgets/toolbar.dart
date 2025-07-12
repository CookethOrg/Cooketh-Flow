import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/features/workspace/widgets/colour_picker_bg.dart';

class ToolBar extends StatefulWidget {
  const ToolBar({super.key});

  @override
  State<ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends State<ToolBar> {
  bool showColorPicker = false;

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Container(
      margin: EdgeInsets.only(right: 20.w),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toolIcon(
            PhosphorIconsRegular.paintBucket,
            device,),
          _horizontaldivider(),
          _toolIcon(PhosphorIconsRegular.circlesThreePlus, device),
          _toolIcon(
            PhosphorIconsFill.circle,
            device,
            iconColor: tertiaryColors[3],
          ),
          _horizontaldivider(),
          _toolIcon(PhosphorIconsRegular.handGrabbing, device),
          _toolIcon(PhosphorIconsRegular.textT, device),
          _toolIcon(PhosphorIconsRegular.image, device),
          _toolIcon(
            PhosphorIconsFill.noteBlank,
            device,
            iconColor: tertiaryColors[6],
          ),
        ],
      ),
    );
  }

  Widget _toolIcon(
    IconData iconData,
    rh.DeviceType device, {
    Color iconColor = Colors.black87,
    Color backgroundColor = Colors.white,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: IconButton(
        onPressed: onTap ?? () {},
        icon: Icon(
          iconData,
          size: 32.sp,
          color: iconColor,
        ),
        splashRadius: 28.r,
      ),
    );
  }

  Widget _horizontaldivider() {
    return Container(
      width: 24.w,
      height: 1.2.h,
      color: const Color(0xFFD9D9D9),
      margin: EdgeInsets.symmetric(vertical: 8.h),
    );
  }
}
