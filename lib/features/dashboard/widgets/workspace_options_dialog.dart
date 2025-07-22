import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/theme/app_theme.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/features/dashboard/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class WorkspaceOptionsDialog extends StatelessWidget {
  WorkspaceOptionsDialog({super.key, required this.onPressed});
  void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Consumer2<SupabaseService, DashboardProvider>(
      builder: (context, supa, dashboard, child) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.sp),
          ),
          backgroundColor:
              supa.isDark
                  ? AppTheme.dark().scaffoldBackgroundColor
                  : AppTheme.light().scaffoldBackgroundColor,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 30.h),
              decoration: BoxDecoration(
                border: Border.all(color: primaryColor),
                borderRadius: BorderRadius.circular(20.sp),
              ),
              height: 0.2.sh,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton.icon(
                    onPressed: onPressed,
                    icon: Icon(
                      PhosphorIcons.trashSimple(),
                      size: 25.sp,
                      color: Colors.red,
                    ),
                    label: Text(
                      'Delete Workspace',
                      style:
                          supa.isDark
                              ? AppTheme.dark().textTheme.headlineSmall
                              : AppTheme.light().textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
