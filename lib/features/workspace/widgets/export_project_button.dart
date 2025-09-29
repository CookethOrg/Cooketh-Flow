// lib/features/workspace/widgets/export_project_button.dart (Fully Modified)

import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/export_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/utils/enums.dart' as en;

class ExportProjectButton extends StatelessWidget {
  final SupabaseService su;
  final WorkspaceProvider wp; // MODIFIED: Added WorkspaceProvider

  const ExportProjectButton({
    super.key,
    required this.su,
    required this.wp, // MODIFIED: Added to constructor
  });

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return ElevatedButton(
      onPressed: () {
        showDialog(
          context: context,
          // MODIFIED: Pass both providers to the dialog
          builder: (context) => ExportDialog(su: su, wp: wp),
        );
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
              fontSize: device == en.DeviceType.desktop ? 18.sp : 25.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 16.w),
          Icon(
            PhosphorIconsRegular.export,
            color: Colors.white,
            size: device == en.DeviceType.desktop ? 24.sp : 40.sp,
          ),
        ],
      ),
    );
  }
}
