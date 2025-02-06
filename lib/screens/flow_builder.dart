import 'dart:math';
import 'package:cookethflow/core/widgets/draggable_node.dart';
import 'package:cookethflow/core/widgets/line_painter.dart';
import 'package:cookethflow/core/widgets/drawer.dart';
import 'package:flutter/material.dart';

class FlowBuilderScreen extends StatefulWidget {
  const FlowBuilderScreen({super.key});

  @override
  _FlowBuilderScreenState createState() => _FlowBuilderScreenState();
}

class _FlowBuilderScreenState extends State<FlowBuilderScreen> {
  List<Offset> nodePositions = [Offset(100, 100), Offset(200, 300)];
  List<List<int>> connections = []; // Stores connections between nodes
  double scale = 1.0; // Initial zoom scale
  double lastScale = 1.0; // Last scale factor for pinch-to-zoom
  bool isDrawerOpen = false; // Track drawer visibility

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flow Builder"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                nodePositions.add(Offset(
                  Random().nextDouble() * 300, // Random X position
                  Random().nextDouble() * 600, // Random Y position
                ));
              });
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          GestureDetector(
            onScaleStart: (details) {
              lastScale = scale;
            },
            onScaleUpdate: (details) {
              setState(() {
                scale = lastScale * details.scale;
                // Limit the zoom scale
                scale = scale.clamp(0.5, 3.0);
              });
            },
            child: Stack(
              children: [
                // Draw lines between connected nodes
                for (var connection in connections)
                  CustomPaint(
                    size: Size.infinite,
                    painter: LinePainter(
                      start: nodePositions[connection[0]] * scale,
                      end: nodePositions[connection[1]] * scale,
                    ),
                  ),
                // Render nodes
                for (int i = 0; i < nodePositions.length; i++)
                  Positioned(
                    left: nodePositions[i].dx * scale,
                    top: nodePositions[i].dy * scale,
                    child: DraggableNode(
                      onDrag: (offset) {
                        setState(() {
                          nodePositions[i] = offset / scale; // Adjust drag position based on zoom
                        });
                      },
                      onConnect: (int targetIndex) {
                        setState(() {
                          connections.add([i, targetIndex]);
                        });
                      },
                      nodeIndex: i,
                    ),
                  ),
              ],
            ),
          ),
          // Floating Drawer
          if (isDrawerOpen) FloatingDrawer(onClose: toggleDrawer),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleDrawer,
        child: Icon(Icons.menu),
      ),
    );
  }
}
