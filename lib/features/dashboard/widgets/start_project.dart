import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class StartProject extends StatelessWidget {
  const StartProject({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, value, child) {
        return ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: primaryColor,
            padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Start a New Project',
                style: TextStyle(
                  fontFamily: 'Fredrik',
                  fontSize: 18.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 16.w),
              Icon(PhosphorIconsRegular.plus, color: Colors.white, size: 24.sp),
            ],
          ),
        );
      },
    );
  }
}
