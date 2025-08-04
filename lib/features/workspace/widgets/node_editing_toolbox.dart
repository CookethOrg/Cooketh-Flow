import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
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
  Widget _buildIconButton(BuildContext context, {
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
    // This widget doesn't need to listen to the provider for its own build,
    // as its visibility is controlled by the parent. The onPressed callbacks
    // will use a read-only provider instance.
    final provider = context.read<WorkspaceProvider>();

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Node Type Alter
            _buildIconButton(
              context, 
              icon: PhosphorIcons.shapes(), 
              onPressed: () { /* Unimplemented */ }, 
              tooltip: 'Change Shape'
            ),
            _buildDivider(),

            // 2. Node Color Alter
            _buildIconButton(
              context, 
              icon: PhosphorIcons.paintBucket(), 
              onPressed: () { /* Unimplemented */ }, 
              tooltip: 'Change Color'
            ),
            _buildDivider(),

            // 3. Text Editing Feature
            _buildIconButton(
              context, 
              icon: PhosphorIcons.textT(), 
              onPressed: () { /* Unimplemented */ }, 
              tooltip: 'Edit Text'
            ),
            _buildDivider(),

            // 4. Link Adder
            _buildIconButton(
              context, 
              icon: PhosphorIcons.link(), 
              onPressed: () { /* Unimplemented */ }, 
              tooltip: 'Add Link'
            ),
            _buildDivider(),

            // 5. Delete Node
            _buildIconButton(
              context, 
              icon: PhosphorIcons.trash(), 
              onPressed: () {
                provider.deleteSelectedObject();
              }, 
              tooltip: 'Delete Object',
              color: Colors.redAccent,
            ),
          ],
        ),
      ),
    );
  }
}