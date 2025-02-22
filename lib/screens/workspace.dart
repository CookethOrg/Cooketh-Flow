import 'package:cookethflow/core/widgets/drawers/project_page_drawer.dart';
import 'package:cookethflow/core/widgets/line_painter.dart';
import 'package:cookethflow/core/widgets/nodes/node.dart';
import 'package:cookethflow/core/widgets/toolbar.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Workspace extends StatelessWidget {
  final String flowId;
  const Workspace({super.key, required this.flowId});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, workProvider, child) {
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: GestureDetector(
            onTapDown: (details) {
              // Check if tap is outside all nodes
              bool hitNode = false;
              for (var node in workProvider.nodeList.values) {
                if (node.bounds.contains(details.globalPosition)) {
                  hitNode = true;
                  // workProvider.changeSelected(node.id);
                  break;
                }
              }
              if (!hitNode) {
                for (var node in workProvider.nodeList.values) {
                  if (node.isSelected) {
                    workProvider.changeSelected(node.id);
                  }
                }
              }
            },
            child: Stack(
              children: [
                Stack(
                  children: [
                    for (var i = 0; i < workProvider.connections.length; i++)
                      CustomPaint(
                        size: Size.infinite,
                        painter: LinePainter(
                            start: workProvider
                                .nodeList[
                                    workProvider.connections[i].sourceNodeId]!
                                .position,
                            end: workProvider
                                .nodeList[
                                    workProvider.connections[i].targetNodeId]!
                                .position,
                            sourceNodeId:
                                workProvider.connections[i].sourceNodeId,
                            startPoint: workProvider.connections[i].sourcePoint,
                            targetNodeId:
                                workProvider.connections[i].targetNodeId,
                            endPoint: workProvider.connections[i].targetPoint),
                      ),
                    ...workProvider.nodeList.entries.map((entry) {
                      var str = entry.key;
                      var node = entry.value;
                      return Positioned(
                        left: workProvider.nodeList[str]!.position.dx,
                        top: workProvider.nodeList[str]!.position.dy,
                        child: Node(
                            id: str,
                            onResize: (Size newSize) =>
                                workProvider.onResize(str, newSize),
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
          ),
        );
      },
    );
  }
}
