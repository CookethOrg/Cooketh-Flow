import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/providers/node_provider.dart';
import 'package:flutter/material.dart';

class RectangularNode extends StatelessWidget {
  final Function(Offset) onDrag;
  final Function(int) onConnect;
  final int nodeIndex;

  RectangularNode({
    super.key,
    required this.onDrag,
    required this.onConnect,
    required this.nodeIndex,
  });

  final nodeProvider = NodeProvider(ProviderState.inital);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => nodeProvider.setHover(true),
      onExit: (_) => nodeProvider.setHover(false),
      child: GestureDetector(
        onTap: nodeProvider.changeSelected,
        onPanUpdate: (details) {
          onDrag(Offset(
            details.globalPosition.dx - (nodeProvider.width / 2),
            details.globalPosition.dy - (nodeProvider.height / 2),
          ));
        },
        onDoubleTap: () {
          onConnect(nodeIndex + 1);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(60),
              child: Container(
                width: nodeProvider.width,
                height: nodeProvider.height,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFFFD8A8), // Change color when selected
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: nodeProvider.isSelected
                        ? Colors.blue
                        : Colors.black, // Blue border when selected
                    width: nodeProvider.isSelected ? 2.0 : 1.0, // Border width
                  ),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: nodeProvider.textController,
                  maxLines: null, // Allows text to wrap
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (nodeProvider.isSelected) ..._buildSelectionBoxes(),
            if (nodeProvider.isHovered) ..._buildConnectionPoints(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSelectionBoxes() {
    return [
      _selectionBox(Offset(-nodeProvider.width / 2 - 10,
          -nodeProvider.height / 2 - 10)), // Top-left corner
      _selectionBox(Offset(nodeProvider.width / 2 + 10,
          -nodeProvider.height / 2 - 10)), // Top-right corner
      _selectionBox(Offset(-nodeProvider.width / 2 - 10,
          nodeProvider.height / 2 + 10)), // Bottom-left corner
      _selectionBox(Offset(nodeProvider.width / 2 + 10,
          nodeProvider.height / 2 + 10)), // Bottom-right corner
    ];
  }

  Widget _selectionBox(Offset offset) {
    return Positioned(
      left: (nodeProvider.width / 2) + offset.dx + 53,
      top: (nodeProvider.height / 2) + offset.dy + 53,
      child: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  List<Widget> _buildConnectionPoints() {
    return [
      _connectionPoint(Offset(0, -nodeProvider.height / 2 - 30)), // Top
      _connectionPoint(Offset(0, nodeProvider.height / 2 + 30)), // Bottom
      _connectionPoint(Offset(-nodeProvider.width / 2 - 30, 0)), // Left
      _connectionPoint(Offset(nodeProvider.width / 2 + 30, 0)), // Right
    ];
  }

  Widget _connectionPoint(Offset offset) {
    return Positioned(
      left: (nodeProvider.width / 2) + offset.dx + 53,
      top: (nodeProvider.height / 2) + offset.dy + 53,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 145, 145, 145),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
