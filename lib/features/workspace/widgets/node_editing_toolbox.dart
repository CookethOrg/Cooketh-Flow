import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/enums.dart' as en;
import 'package:cookethflow/features/models/canvas_models/objects/connector_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/sticky_note_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/text_box_object.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/connector_customizer.dart';
import 'package:cookethflow/features/workspace/widgets/node_colour.dart';
import 'package:cookethflow/features/workspace/widgets/node_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class NodeEditingToolbox extends StatelessWidget {
  const NodeEditingToolbox({super.key});

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? color,
    required SupabaseService su,
  }) {
    return IconButton(
      icon: Icon(icon, size: 22),
      onPressed: onPressed,
      color: color ?? (su.isDark ? Colors.white : Colors.black87),
      splashRadius: 20,
      tooltip: tooltip,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkspaceProvider>();
    final su = context.read<SupabaseService>();
    final selectedObjectId = provider.currentlySelectedObjectId;

    if (selectedObjectId == null) {
      return const SizedBox.shrink();
    }

    final object = provider.canvasObjects[selectedObjectId];
    if (object == null) {
      return const SizedBox.shrink();
    }

    final buttons = <Widget>[];

    final isConnector = object is ConnectorObject;
    final isShape =
        object is! TextBoxObject &&
        object is! ConnectorObject &&
        object is! StickyNoteObject;
    final canChangeColor =
        object is! TextBoxObject && object is! ConnectorObject;

    if (isConnector) {
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIcons.lineSegment(),
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => ConnectorCustomizer(
                    initialColor: object.color,
                    initialType: object.connectionType,
                    initialThickness: object.thickness,
                    onStyleSelected: (color, type, thickness) {
                      provider.changeConnectorStyle(color, type, thickness);
                    },
                    su: su,
                  ),
            );
          },
          tooltip: 'Change Connector Style',
          su: su,
        ),
      );
      if (canChangeColor) {
        buttons.add(_buildDivider());
        buttons.add(
          _buildIconButton(
            context,
            icon: PhosphorIcons.paintBucket(),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => NodeColourPicker(
                      initialColor: object.color,
                      onColorSelected: (color) {
                        provider.changeConnectorStyle(
                          color,
                          object.connectionType,
                          object.thickness,
                        );
                        Navigator.of(context).pop();
                      },
                    ),
              );
            },
            tooltip: 'Change Color',
            su: su,
          ),
        );
      }
      // } else if (isShape) {
      //   buttons.add(
      //     _buildIconButton(
      //       context,
      //       icon: PhosphorIcons.shapes(),
      //       onPressed: () {
      //         showDialog(
      //           context: context,
      //           builder: (context) => NodePicker(
      //             onShapeSelected: (shapeType) {
      //               provider.changeObjectShape(shapeType);
      //               Navigator.of(context).pop();
      //             },
      //             su: su,
      //           ),
      //         );
      //       },
      //       tooltip: 'Change Shape',
      //       su: su,
      //     ),
      //   );
      //   if (canChangeColor) {
      //     buttons.add(_buildDivider());
      //     buttons.add(
      //       _buildIconButton(
      //         context,
      //         icon: PhosphorIcons.paintBucket(),
      //         onPressed: () {
      //           showDialog(
      //             context: context,
      //             builder: (context) => NodeColourPicker(
      //               initialColor: object.color,
      //               onColorSelected: (color) {
      //                 provider.changeObjectColor(color);
      //                 Navigator.of(context).pop();
      //               },
      //             ),
      //           );
      //         },
      //         tooltip: 'Change Color',
      //         su: su,
      //       ),
      //     );
      //   }
    } else if (canChangeColor) {
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIconsRegular.circlesThreePlus,
          onPressed: () {
            final device = rh.ResponsiveLayoutHelper.getDeviceType(context);
            _showNodePicker(context, device, su, provider);
          },
          tooltip: "Node Types",
          su: su,
        ),
      );
      buttons.add(_buildDivider());
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIconsRegular.circle,
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => NodeColourPicker(
                    initialColor: object.color,
                    onColorSelected: (color) {
                      provider.changeObjectColor(color);
                      Navigator.of(context).pop();
                    },
                  ),
            );
          },
          tooltip: "Customize node colours",
          su: su,
          color: Color.fromRGBO(195, 177, 225, 1),
        ),
      );
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIconsRegular.textAlignCenter,
          onPressed: () {},
          tooltip: "Customize node outline",
          su: su,
        ),
      );
      buttons.add(_buildDivider());
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIcons.textAa(),
          onPressed: () {},
          tooltip: "Font style",
          su: su,
        ),
      );
      buttons.add(_buildDivider());
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIcons.textB(),
          onPressed: () {},
          tooltip: "Font add-ons",
          su: su,
        ),
      );
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIcons.textItalic(),
          onPressed: () {},
          tooltip: "Font add-ons",
          su: su,
        ),
      );
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIcons.textUnderline(),
          onPressed: () {},
          tooltip: "Font add-ons",
          su: su,
        ),
      );
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIcons.textStrikethrough(),
          onPressed: () {},
          tooltip: "Font add-ons",
          su: su,
        ),
      );
      buttons.add(_buildDivider());
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIcons.link(),
          onPressed: () {},
          tooltip: "Add links",
          su: su,
        ),
      );
    }

    // Always add the delete button if there's an object selected
    if (buttons.isNotEmpty) {
      buttons.add(_buildDivider());
    }

    buttons.add(
      _buildIconButton(
        context,
        icon: PhosphorIcons.trash(),
        onPressed: () {
          provider.deleteSelectedObject();
        },
        tooltip: 'Delete Object',
        color: Colors.redAccent,
        su: su,
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: su.isDark ? const Color.fromRGBO(48, 48, 48, 1) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: buttons),
      ),
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
          topPos = position.dy;
          leftPos = position.dx;
        } else {
          topPos = position.dy + 10.h;
          leftPos = position.dx;
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
}
