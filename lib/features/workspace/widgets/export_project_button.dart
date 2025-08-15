import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/workspace/widgets/export_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ExportProjectButton extends StatelessWidget {
  const ExportProjectButton({super.key});

  @override
  Widget build(BuildContext context) {
      final device = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return ElevatedButton(
      onPressed: () {
        showDialog(context: context, builder: (context) => ExportDialog(),);
      },
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
            'Export Flowchart',
            style: TextStyle(
              fontFamily: 'Fredrik',
              fontSize:device == rh.DeviceType.desktop? 18.sp : 25.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16.w),
          Icon(PhosphorIconsRegular.export, color: Colors.white, size:device == rh.DeviceType.desktop? 24.sp : 40.sp),
        ],
      ),
    );
  }
}
