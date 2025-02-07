import 'dart:math';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/widgets/draggable_node.dart';
import 'package:cookethflow/core/widgets/line_painter.dart';
import 'package:cookethflow/core/widgets/drawer.dart';
import 'package:flutter/material.dart';

class FlowBuilderScreen extends StatefulWidget {
  const FlowBuilderScreen({super.key});

  @override
  State<FlowBuilderScreen> createState() => _FlowBuilderScreenState();
}

class _FlowBuilderScreenState extends State<FlowBuilderScreen> {
  List<Offset> nodePositions = [Offset(100, 100), Offset(200, 300)];
  List<List<int>> connections = []; // Stores connections between nodes
  double scale = 1.0; // Initial zoom scale
  double lastScale = 1.0; // Last scale factor for pinch-to-zoom

  void addNode() {
    setState(() {
      nodePositions.add(Offset(
        Random().nextDouble() * 300, // Random X position
        Random().nextDouble() * 600, // Random Y position
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                scale = scale.clamp(0.5, 3.0); // Limit zoom scale
              });
            },
            child: Stack(
              children: [
                // Draw connections between nodes
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
                    child: RectangularNode(
                      onDrag: (offset) {
                        setState(() {
                          nodePositions[i] = offset / scale; // Adjust for zoom
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
          FloatingDrawer(), // Updated floating drawer
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "addNodeBtn",
        onPressed: addNode,
        backgroundColor: Colors.white,
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}