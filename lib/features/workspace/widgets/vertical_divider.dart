import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerticalCustomDivider extends StatelessWidget {
  const VerticalCustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
    height: 24.h,
    width: 1.2.w,
    color: const Color(0xFFD9D9D9),
    margin: EdgeInsets.symmetric(horizontal: 8.w),
  );
  }
}