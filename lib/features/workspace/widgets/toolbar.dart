import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/node_picker.dart';
import 'package:cookethflow/features/workspace/widgets/vertical_divider.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/features/workspace/widgets/sticky_notes.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_color_picker.dart';
import 'package:cookethflow/core/utils/enums.dart' as en;

class ToolBar extends StatelessWidget {
  const ToolBar({super.key});

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Consumer3<WorkspaceProvider, SupabaseService, ShortcutManagerr>(
      builder: (context, provider, suprovider, shortcutManager, child) {
        // Get shortcut labels
        final pointerShortcut = shortcutManager.getShortcutLabel('pointer');
        final panShortcut = shortcutManager.getShortcutLabel('pan');
        final textShortcut = shortcutManager.getShortcutLabel('text');
        final stickyNoteShortcut = shortcutManager.getShortcutLabel(
          'stickyNote',
        );

        return Container(
          padding: EdgeInsets.symmetric(
            vertical:
                device == en.DeviceType.desktop
                    ? 20.h
                    : device == en.DeviceType.tab
                    ? 16.h
                    : 2.h,
            horizontal: 24.w,
          ),
          decoration: BoxDecoration(
            color:
                suprovider.isDark
                    ? const Color.fromRGBO(48, 48, 48, 1)
                    : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color:
                  suprovider.isDark
                      ? const Color.fromRGBO(75, 75, 75, 1)
                      : const Color(0xFFD9D9D9),
              width: 1.2,
            ),
          ),
          child:
              device == en.DeviceType.mobile
                  ? FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _toolIcon(
                          PhosphorIconsRegular.paintBucket,
                          'Select Workspace Color',
                          device,
                          onPressed: () {
                            _showColorPicker(
                              context,
                              provider,
                              device,
                              suprovider,
                            );
                          },
                          backgroundColor:
                              suprovider.isDark
                                  ? const Color.fromRGBO(48, 48, 48, 1)
                                  : Colors.white,
                          iconColor:
                              suprovider.isDark ? Colors.white : Colors.black87,
                        ),
                        VerticalCustomDivider(),
                        _toolIcon(
                          provider.getNodeIcon(),
                          'Add new node',
                          device,
                          onPressed: () {
                            _showNodePicker(
                              context,
                              device,
                              suprovider,
                              provider,
                            );
                          },
                          backgroundColor:
                              suprovider.isDark
                                  ? const Color.fromRGBO(48, 48, 48, 1)
                                  : Colors.white,
                          iconColor:
                              suprovider.isDark ? Colors.white : Colors.black87,
                        ),
                        VerticalCustomDivider(),
                        _toolIcon(
                          PhosphorIconsRegular.cursor,
                          'Pointer - Press $pointerShortcut',
                          device,
                          iconColor:
                              provider.currentMode == DrawMode.pointer
                                  ? Colors.blue
                                  : suprovider.isDark
                                  ? Colors.white
                                  : Colors.black,
                          onPressed: () {
                            provider.changeDrawMode(DrawMode.pointer);
                          },
                          backgroundColor:
                              suprovider.isDark
                                  ? const Color.fromRGBO(48, 48, 48, 1)
                                  : Colors.white,
                        ),
                        VerticalCustomDivider(),
                        _toolIcon(
                          PhosphorIconsRegular.handGrabbing,
                          'Pan - Press $panShortcut',
                          device,
                          iconColor:
                              provider.currentMode == DrawMode.hand
                                  ? Colors.blue
                                  : suprovider.isDark
                                  ? Colors.white
                                  : Colors.black,
                          onPressed: () {
                            provider.changeDrawMode(DrawMode.hand);
                          },
                          backgroundColor:
                              suprovider.isDark
                                  ? const Color.fromRGBO(48, 48, 48, 1)
                                  : Colors.white,
                        ),
                        VerticalCustomDivider(),
                        _toolIcon(
                          PhosphorIconsRegular.textT,
                          'Text box - Press $textShortcut',
                          device,
                          iconColor:
                              provider.currentMode == DrawMode.textBox
                                  ? Colors.blue
                                  : suprovider.isDark
                                  ? Colors.white
                                  : Colors.black,
                          onPressed: () {
                            provider.changeDrawMode(DrawMode.textBox);
                          },
                          backgroundColor:
                              suprovider.isDark
                                  ? const Color.fromRGBO(48, 48, 48, 1)
                                  : Colors.white,
                        ),
                        VerticalCustomDivider(),
                        _toolIcon(
                          PhosphorIconsRegular.image,
                          'Add Image/Media files - Coming soon',
                          device,
                          onPressed: () {},
                          backgroundColor:
                              suprovider.isDark
                                  ? const Color.fromRGBO(48, 48, 48, 1)
                                  : Colors.white,
                          iconColor:
                              suprovider.isDark ? Colors.white : Colors.black87,
                        ),
                        VerticalCustomDivider(),
                        _toolIcon(
                          PhosphorIconsFill.noteBlank,
                          'Add new sticky note - Press $stickyNoteShortcut',
                          device,
                          iconColor:
                              provider.currentMode == DrawMode.stickyNote
                                  ? Colors.blue
                                  : tertiaryColors[6],
                          onPressed:
                              () =>
                                  _showStickyNote(context, device, suprovider),
                          backgroundColor:
                              suprovider.isDark
                                  ? const Color.fromRGBO(48, 48, 48, 1)
                                  : Colors.white,
                        ),
                      ],
                    ),
                  )
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _toolIcon(
                        PhosphorIconsRegular.paintBucket,
                        'Select Workspace Color',
                        device,
                        onPressed: () {
                          _showColorPicker(
                            context,
                            provider,
                            device,
                            suprovider,
                          );
                        },
                        backgroundColor:
                            suprovider.isDark
                                ? const Color.fromRGBO(48, 48, 48, 1)
                                : Colors.white,
                        iconColor:
                            suprovider.isDark ? Colors.white : Colors.black87,
                      ),
                      _horizontalDivider(device),
                      _toolIcon(
                        provider.getNodeIcon(),
                        'Add new node',
                        device,
                        onPressed: () {
                          _showNodePicker(
                            context,
                            device,
                            suprovider,
                            provider,
                          );
                        },
                        backgroundColor:
                            suprovider.isDark
                                ? const Color.fromRGBO(48, 48, 48, 1)
                                : Colors.white,
                        iconColor:
                            suprovider.isDark ? Colors.white : Colors.black87,
                      ),
                      _horizontalDivider(device),
                      _toolIcon(
                        PhosphorIconsRegular.cursor,
                        'Pointer\nPress $pointerShortcut',
                        device,
                        iconColor:
                            provider.currentMode == DrawMode.pointer
                                ? Colors.blue
                                : suprovider.isDark
                                ? Colors.white
                                : Colors.black,
                        onPressed: () {
                          provider.changeDrawMode(DrawMode.pointer);
                        },
                        backgroundColor:
                            suprovider.isDark
                                ? const Color.fromRGBO(48, 48, 48, 1)
                                : Colors.white,
                      ),
                      _horizontalDivider(device),
                      _toolIcon(
                        PhosphorIconsRegular.handGrabbing,
                        'Pan\nPress $panShortcut',
                        device,
                        iconColor:
                            provider.currentMode == DrawMode.hand
                                ? Colors.blue
                                : suprovider.isDark
                                ? Colors.white
                                : Colors.black,
                        onPressed: () {
                          provider.changeDrawMode(DrawMode.hand);
                        },
                        backgroundColor:
                            suprovider.isDark
                                ? const Color.fromRGBO(48, 48, 48, 1)
                                : Colors.white,
                      ),
                      _horizontalDivider(device),
                      _toolIcon(
                        PhosphorIconsRegular.textT,
                        'Text box\nPress $textShortcut',
                        device,
                        iconColor:
                            provider.currentMode == DrawMode.textBox
                                ? Colors.blue
                                : suprovider.isDark
                                ? Colors.white
                                : Colors.black,
                        onPressed: () {
                          provider.changeDrawMode(DrawMode.textBox);
                        },
                        backgroundColor:
                            suprovider.isDark
                                ? const Color.fromRGBO(48, 48, 48, 1)
                                : Colors.white,
                      ),
                      _horizontalDivider(device),
                      _toolIcon(
                        PhosphorIconsRegular.image,
                        'Add Image/Media files - Coming soon',
                        device,
                        onPressed: () {},
                        backgroundColor:
                            suprovider.isDark
                                ? const Color.fromRGBO(48, 48, 48, 1)
                                : Colors.white,
                        iconColor:
                            suprovider.isDark ? Colors.white : Colors.black87,
                      ),
                      _horizontalDivider(device),
                      _toolIcon(
                        PhosphorIconsFill.noteBlank,
                        'Add new sticky note\nPress $stickyNoteShortcut',
                        device,
                        iconColor:
                            provider.currentMode == DrawMode.stickyNote
                                ? Colors.blue
                                : tertiaryColors[6],
                        onPressed:
                            () => _showStickyNote(context, device, suprovider),
                        backgroundColor:
                            suprovider.isDark
                                ? const Color.fromRGBO(48, 48, 48, 1)
                                : Colors.white,
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
    en.DeviceType device, {
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
          padding: EdgeInsets.all(2.w),
          child: IconButton(
            onPressed: onPressed,
            tooltip: tooltip,
            icon: Icon(
              iconData,
              size:
                  device == en.DeviceType.desktop
                      ? 36.sp
                      : device == en.DeviceType.tab
                      ? 60.sp
                      : 100.sp,
            ),
            color: iconColor,
          ),
        ),
      ),
    );
  }

  Widget _horizontalDivider(en.DeviceType device) {
    return Container(
      width: device == en.DeviceType.desktop ? 28.w : 45.w,
      height: 2.h,
      color: const Color(0xFFD9D9D9),
      margin: EdgeInsets.symmetric(vertical: 8.h),
    );
  }

  void _showNodePicker(
    BuildContext context,
    en.DeviceType device,
    SupabaseService su,
    WorkspaceProvider wp,
  ) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final nodePickerWidth =
        device == en.DeviceType.desktop
            ? 340
            : device == en.DeviceType.tab
            ? 340
            : 300;
    final padding = 20.w;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        double topPos;
        double leftPos;
        if (device == en.DeviceType.mobile) {
          topPos = position.dy - 500.h;
          leftPos = position.dx;
        } else {
          topPos = position.dy;
          leftPos = position.dx - nodePickerWidth - padding - 50.w;
        }
        return Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.transparent)),
            Positioned(
              top: topPos,
              left: leftPos,
              child: Material(
                color: Colors.transparent,
                child: NodePicker(su: su),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showColorPicker(
    BuildContext context,
    WorkspaceProvider provider,
    en.DeviceType device,
    SupabaseService su,
  ) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final pickerWidth = 350.w;
      final padding = 20.w;

      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (context) {
          double topPos;
          double leftPos;
          if (device == en.DeviceType.mobile) {
            topPos = position.dy - 390.h;
            leftPos = position.dx;
          } else {
            topPos = position.dy;
            leftPos = position.dx - pickerWidth - padding;
          }
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned(
                top: topPos,
                left: leftPos,
                child: Material(
                  color: Colors.transparent,
                  child: WorkspaceColorPicker(
                    initialColor: provider.currentWorkspaceColor,
                    onColorChanged: (color) {
                      provider.changeWorkspaceColor(color);
                    },
                    su: su,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _showStickyNote(
    BuildContext context,
    en.DeviceType device,
    SupabaseService su,
  ) {
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
                  right: device == en.DeviceType.mobile ? position.dx : 150.w,
                  top:
                      device == en.DeviceType.desktop
                          ? 500.h
                          : device == en.DeviceType.tab
                          ? 500.h
                          : position.dy - 390.h,
                  child: Material(
                    color: Colors.transparent,
                    child: StickyNotesWidget(su: su),
                  ),
                ),
              ],
            ),
      );
    }
  }
}
