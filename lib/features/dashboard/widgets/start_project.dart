import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/dashboard/widgets/add_project_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;

class StartProject extends StatelessWidget {
  const StartProject({super.key});

  @override
  Widget build(BuildContext context) {
     rh.DeviceType deviceType = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return Consumer(
      builder: (context, value, child) {
        return ElevatedButton(
          onPressed: () {
            showDialog(context: context, builder: (context) => AddProject(),);
          },
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: primaryColor,
            padding: deviceType == rh.DeviceType.desktop ? EdgeInsets.symmetric(vertical: 35.h, horizontal: 24.w) : deviceType == rh.DeviceType.tab ?EdgeInsets.symmetric(vertical: 35.h, horizontal: 24.w) : EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w) ,
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
                  fontSize:deviceType == rh.DeviceType.desktop ? 18.sp : deviceType == rh.DeviceType.tab ?25.sp : 35.sp,
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
