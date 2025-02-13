import 'package:cookethflow/core/widgets/drawers/project_page_drawer.dart';
import 'package:cookethflow/core/widgets/nodes/node.dart';
import 'package:cookethflow/core/widgets/toolbar.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Workspace extends StatelessWidget {
  const Workspace({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, workProvider, child) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: Stack(
            children: [
              Stack(
                children: [
                  ...workProvider.nodeList.entries.map((entry) {
                    var str = entry.key;
                    var node = entry.value;
                    return Positioned(
                      left: workProvider.nodeList[str]!.position.dx,
                      top: workProvider.nodeList[str]!.position.dy,
                      child: Node(
                          id: str,
                          onDrag: (offset) {
                            workProvider.dragNode(str, offset);
                          },
                          position: node.position),
                    ); // Replace with your actual widget
                  }),
                ],
              ),
              FloatingDrawer(), // Left-side floating drawer

              Toolbar(onAdd: workProvider.addNode),
            ],
          ),
        );
      },
    );
  }
}
