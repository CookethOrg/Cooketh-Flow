import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/node_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/features/workspace/widgets/sticky_notes.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_color_picker.dart'; // Import the new picker

class ToolBar extends StatelessWidget {
  const ToolBar({super.key});

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Consumer<WorkspaceProvider>(
      builder: (context, provider, child) {
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
                'Select Workspace Color',
                device,
                onPressed: () {
                  _showColorPicker(context, provider); // Pass the provider
                },
              ),
              _horizontalDivider(),
              _toolIcon(
                PhosphorIconsRegular.circlesThreePlus,
                'Add new node',
                device,
                onPressed: () {
                  _showNodePicker(context);
                },
              ),
              _horizontalDivider(),
              _toolIcon(
                PhosphorIconsRegular.cursor,
                'Pointer',
                device,
                iconColor: provider.currentMode == DrawMode.pointer ? Colors.blue : Colors.black,
                onPressed: () {
                  provider.changeDrawMode(DrawMode.pointer);
                },
              ),
              _toolIcon(
                PhosphorIconsRegular.handGrabbing,
                'Pan',
                device,
                iconColor: provider.currentMode == DrawMode.hand ? Colors.blue : Colors.black,
                onPressed: () {
                  provider.changeDrawMode(DrawMode.hand);
                },
              ),
              _toolIcon(
                PhosphorIconsRegular.textT,
                'Text box',
                device,
                iconColor: provider.currentMode == DrawMode.textBox ? Colors.blue : Colors.black,
                onPressed: () {
                  provider.changeDrawMode(DrawMode.textBox);
                },
              ),
              _toolIcon(
                PhosphorIconsRegular.image,
                'Add Image/Media files - Coming soon',
                device,
                onPressed: () {},
              ),
              _toolIcon(
                PhosphorIconsFill.noteBlank,
                'Add new sticky note',
                device,
                iconColor: provider.currentMode == DrawMode.stickyNote ? Colors.blue : tertiaryColors[6],
                onPressed: () => _showStickyNote(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _toolIcon(
    IconData iconData,
    String tooltip,
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
        child: Container(
          padding: EdgeInsets.all(8.w),
          child: IconButton(
            onPressed: onPressed,
            tooltip: tooltip,
            icon: Icon(iconData, size: 36.sp),
            color: iconColor,
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

  void _showNodePicker(BuildContext context) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final nodePickerWidth = 340; // The width of the NodePicker widget
    final padding = 20.w; // Padding between the toolbar and the picker

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder:
          (context) => Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned(
                top: position.dy,
                left: position.dx - nodePickerWidth - padding,
                child: const Material(
                  color: Colors.transparent,
                  child: NodePicker(),
                ),
              ),
            ],
          ),
    );
  }

  void _showColorPicker(BuildContext context, WorkspaceProvider provider) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final pickerWidth = 350.w;
      final padding = 20.w;

      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (context) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: position.dy,
              left: position.dx - pickerWidth - padding,
              child: Material(
                color: Colors.transparent,
                child: WorkspaceColorPicker(
                  initialColor: provider.currentWorkspaceColor,
                  onColorChanged: (color) {
                    provider.changeWorkspaceColor(color);
                  },
                ),
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
        builder:
            (context) => Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Positioned(
                  right: 130.w,
                  top: 460.h,
                  child: Material(
                    color: Colors.transparent,
                    child: StickyNotesWidget(),
                  ),
                ),
              ],
            ),
      );
    }
  }
}