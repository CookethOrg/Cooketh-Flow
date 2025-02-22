import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, pv, child) {
        return PopupMenuButton<NodeType>(
          icon: Icon(PhosphorIconsRegular.plus),
          tooltip: "Add Node",
          onSelected: (NodeType type) {
            pv.addNode(type: type);
          },
          itemBuilder: (context) => [
            _buildMenuItem(NodeType.rectangular, PhosphorIconsRegular.square),
            _buildMenuItem(NodeType.parallelogram, PhosphorIconsRegular.parallelogram),
            _buildMenuItem(NodeType.diamond, PhosphorIconsRegular.diamond),
            _buildMenuItem(NodeType.database, PhosphorIconsRegular.database),
          ],
        );
      },
    );
  }

  PopupMenuItem<NodeType> _buildMenuItem(NodeType type, IconData icon) {
    return PopupMenuItem<NodeType>(
      value: type,
      child: Icon(icon, size: 24),
    );
  }
}