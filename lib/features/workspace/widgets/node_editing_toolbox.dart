import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/models/canvas_models/objects/connector_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/sticky_note_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/text_box_object.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/node_colour.dart';
import 'package:cookethflow/features/workspace/widgets/node_picker.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class NodeEditingToolbox extends StatelessWidget {
  const NodeEditingToolbox({super.key});

  // Helper widget for creating vertical dividers
  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  // Helper to build icon buttons consistently
  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? color,
  }) {
    return IconButton(
      icon: Icon(icon, size: 22),
      onPressed: onPressed,
      color: color ?? Colors.black87,
      splashRadius: 20,
      tooltip: tooltip,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkspaceProvider>();
    final object = provider.canvasObjects[provider.currentlySelectedObjectId];

    // Determine which buttons to show based on object type
    final showShapeChanger = object is! TextBoxObject &&
        object is! ConnectorObject &&
        object is! StickyNoteObject;
    final showColorChanger =
        object is! TextBoxObject && object is! ConnectorObject;
    final showDeleteButton = true; // Always show delete

    // Collect all visible buttons
    final buttons = <Widget>[];

    // 1. Node Type Alter
    if (showShapeChanger) {
      buttons.add(
        _buildIconButton(
          context,
          icon: PhosphorIcons.shapes(),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => NodePicker(
                onShapeSelected: (shapeType) {
                  provider.changeObjectShape(shapeType);
                },
              ),
            );
          },
          tooltip: 'Change Shape',
        ),
      );
      buttons.add(_buildDivider());
    }

    // 2. Node Color Alter
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
              builder: (context) => NodeColourPicker(
                initialColor: selectedObject?.color,
                onColorSelected: (color) {
                  provider.changeObjectColor(color);
                  Navigator.of(context).pop();
                },
              ),
            );
          },
          tooltip: 'Change Color',
        ),
      );
      buttons.add(_buildDivider());
    }

    // 5. Delete Node
    buttons.add(
      _buildIconButton(
        context,
        icon: PhosphorIcons.trash(),
        onPressed: () {
          provider.deleteSelectedObject();
        },
        tooltip: 'Delete Object',
        color: Colors.redAccent,
      ),
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
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