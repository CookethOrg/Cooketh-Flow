import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/features/workspace/widgets/node_colour.dart';
import 'package:cookethflow/features/workspace/widgets/sticky_notes.dart';


class ToolBar extends StatelessWidget {
  const ToolBar({super.key});

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
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
            device,
            onPressed: () {
              // TODO: Add paint bucket functionality
              print('Paint bucket pressed');
            },
          ),
          _horizontalDivider(),
          _toolIcon(
            PhosphorIconsRegular.circlesThreePlus,
            device,
            onPressed: () {
              // TODO: Add circles three plus functionality
              print('Circles three plus pressed');
            },
          ),
          // _toolIcon(
          //   PhosphorIconsFill.circle,
          //   device,
          //   iconColor: tertiaryColors[3],
          //   onPressed: () => _showColorPicker(context),
          // ),
          _horizontalDivider(),
          _toolIcon(
            PhosphorIconsRegular.handGrabbing,
            device,
            onPressed: () {
              // TODO: Add hand grabbing functionality
              print('Hand grabbing pressed');
            },
          ),
          _toolIcon(
            PhosphorIconsRegular.textT,
            device,
            onPressed: () {
              // TODO: Add text functionality
              print('Text pressed');
            },
          ),
          _toolIcon(
            PhosphorIconsRegular.image,
            device,
            onPressed: () {
              // TODO: Add image functionality
              print('Image pressed');
            },
          ),
          _toolIcon(
            PhosphorIconsFill.noteBlank,
            device,
            iconColor: tertiaryColors[6],
            onPressed: () => _showStickyNote(context),
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
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(8.w),
            child: Icon(
              iconData,
              size: 36.sp,
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _horizontalDivider() {
    return Container(
      width: 28.w,
      height: 2.h,
      color: const Color(0xFFD9D9D9),
      margin: EdgeInsets.symmetric(vertical: 8.h),
    );
  }

  void _showColorPicker(BuildContext context) {
    // Get the render box of the toolbar to position the dialog
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (context) => Stack(
          children: [
            // Invisible barrier to close dialog when tapping outside
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            // Position the color picker next to the toolbar
            Positioned(
              right: 40.w,
              top: 40.h,
              child: Material(
                color: Colors.transparent,
                child: NodeColourPicker(),
              ),
            ),
          ],
        ),
      );
    }
  }
  void _showStickyNote(BuildContext context) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(onTap: () => Navigator.pop(context), child: Container(color: Colors.transparent)),
            ),
            Positioned(right: 40.w, top: 40.h, child: Material(color: Colors.transparent, child: StickyNotesWidget())),
          ],
        ),
      );
    }
  }
}
