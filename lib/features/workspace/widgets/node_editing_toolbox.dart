import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/models/canvas_models/objects/connector_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/sticky_note_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/text_box_object.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/connector_customizer.dart';
import 'package:cookethflow/features/workspace/widgets/node_colour.dart';
import 'package:cookethflow/features/workspace/widgets/node_picker.dart';
import 'package:flutter/material.dart';
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
      color: color ??(su.isDark?Colors.white: Colors.black87),
      splashRadius: 20,
      tooltip: tooltip,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkspaceProvider>();
    final provider2 = context.read<SupabaseService>();
    final object = provider.canvasObjects[provider.currentlySelectedObjectId!];

    final isConnector = object is ConnectorObject;
    final showShapeChanger =
        object is! TextBoxObject &&
        object is! ConnectorObject &&
        object is! StickyNoteObject;
    final showColorChanger =
        object is! TextBoxObject;

    final buttons = <Widget>[];

    if (isConnector) {
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIcons.database(),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => ConnectorCustomizer(
                initialColor: object.color,
                initialType: object.connectionType,
                initialThickness: object.thickness,
                onStyleSelected: (color, type, thickness) {
                  provider.changeConnectorStyle(color, type, thickness);
                },
                su: provider2,
              ),
            );
          },
          tooltip: 'Change Connector Style',
          su: provider2,
        ),
      );
      buttons.add(_buildDivider());
    }

    if (showShapeChanger) {
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIcons.shapes(),
          onPressed: () {
            showDialog(
              context: context,
              builder:
                  (context) => NodePicker(
                    onShapeSelected: (shapeType) {
                      provider.changeObjectShape(shapeType);
                    },
                    su: provider2,
                  ),
            );
          },
          tooltip: 'Change Shape',
          su: provider2
        ),
      );
      buttons.add(_buildDivider());
    }

    if (showColorChanger) {
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIcons.paintBucket(),
          onPressed: () {
            final selectedObject =
                provider.canvasObjects[provider.currentlySelectedObjectId!];
            showDialog(
              context: context,
              builder:
                  (context) => NodeColourPicker(
                    initialColor: selectedObject?.color,
                    onColorSelected: (color) {
                      if (isConnector) {
                        provider.changeConnectorStyle(color, object.connectionType, object.thickness);
                      } else {
                        provider.changeObjectColor(color);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
            );
          },
          tooltip: 'Change Color',
          su: provider2
        ),
      );
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
        su: provider2
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color:
              provider2.isDark ? const Color.fromRGBO(48, 48, 48, 1) : Colors.white,
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
}