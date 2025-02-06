import 'package:flutter/material.dart';

class DraggableNode extends StatelessWidget {
  final Function(Offset) onDrag;
  final Function(int) onConnect;
  final int nodeIndex;

  const DraggableNode({super.key, required this.onDrag, required this.onConnect, required this.nodeIndex});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        onDrag(Offset(details.globalPosition.dx - 50, details.globalPosition.dy - 50));
      },
      onDoubleTap: () {
        // Double tap to create connection
        // For simplicity, I'm connecting to the next node in the list.
        if (nodeIndex < 1) {
          onConnect(nodeIndex + 1);
        }
      },
      child: Container(
        width: 100,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          "Node ${nodeIndex + 1}",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}