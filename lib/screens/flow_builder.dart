import 'package:cookethflow/providers/node_provider.dart';
import 'package:cookethflow/core/widgets/toolbar.dart'; // Your Undo/Redo toolbar
import 'package:cookethflow/core/widgets/nodes/rectangular_node.dart';
import 'package:cookethflow/core/widgets/line_painter.dart';
import 'package:cookethflow/core/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FlowBuilderScreen extends StatefulWidget {
  const FlowBuilderScreen({super.key});

  @override
  State<FlowBuilderScreen> createState() => _FlowBuilderScreenState();
}

class _FlowBuilderScreenState extends State<FlowBuilderScreen> {
  List<List<int>> connections = []; // Stores connections between nodes

  @override
  Widget build(BuildContext context) {
    return Consumer<NodeProvider>(
      builder: (context, provider, child) {
        return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Stack(
          children: [
            GestureDetector(
              onScaleStart: provider.startScale,
              onScaleUpdate: provider.scaleUpdate,
              child: Stack(
                children: [
                  // Draw connections between nodes
                  for (var connection in connections)
                    CustomPaint(
                      size: Size.infinite,
                      painter: LinePainter(
                        start: provider.nodePositions[connection[0]] * provider.scale,
                        end: provider.nodePositions[connection[1]] * provider.scale,
                      ),
                    ),
                  // Render nodes
                  for (int i = 0; i < provider.nodePositions.length; i++)
                    Positioned(
                      left: provider.nodePositions[i].dx * provider.scale,
                      top: provider.nodePositions[i].dy * provider.scale,
                      child: RectangularNode(
                        onDrag: (offset) {
                          setState(() {
                            provider.nodePositions[i] = offset / provider.scale; // Adjust for zoom
                          });
                        },
                        onConnect: (int targetIndex) {
                          setState(() {
                            if (!connections.any((c) => c.contains(i) && c.contains(targetIndex))) {
                              connections.add([i, targetIndex]);
                            }
                          });
                        },
                        nodeIndex: i,
                      ),
                    ),
                ],
              ),
            ),
            FloatingDrawer(), // Left-side floating drawer
      
            Toolbar(onAdd: provider.addNode),
          ],
        ),
      );
      },
    );
  }
}
