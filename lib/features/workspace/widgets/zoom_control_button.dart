import 'package:cookethflow/features/workspace/widgets/vertical_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ZoomControlButton extends StatelessWidget {
  const ZoomControlButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0XFFD9D9D9), width: 1.2),
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
          SizedBox(width: 8.w),
          VerticalCustomDivider(),
          SizedBox(width: 8.w),
          IconButton(
            onPressed: () {},
            icon: Icon(PhosphorIconsRegular.plus, size: 24.sp),
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(width: 8.w),
          VerticalCustomDivider(),
          SizedBox(width: 8.w),
          IconButton(
            onPressed: () {},
            icon: Icon(PhosphorIconsRegular.minus, size: 24.sp),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
