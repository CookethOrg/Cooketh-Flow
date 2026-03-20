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
  final WorkspaceProvider wp;

  const ExportProjectButton({
    super.key,
    required this.su,
    required this.wp,
  });

  void _showExportPopup(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final buttonPosition = button.localToGlobal(Offset.zero);
    final buttonSize = button.size;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            // Dismiss on tap outside
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Position the popup right below the button
            Positioned(
              top: buttonPosition.dy + buttonSize.height + 8,
              left: buttonPosition.dx,
              child: ExportDialog(su: su, wp: wp),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return ElevatedButton(
      onPressed: () => _showExportPopup(context),
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
