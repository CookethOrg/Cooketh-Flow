import 'package:flutter/material.dart';

class DraggableNode extends StatefulWidget {
  final Function(Offset) onDrag;
  final Function(int) onConnect;
  final int nodeIndex;

  const DraggableNode({
    super.key,
    required this.onDrag,
    required this.onConnect,
    required this.nodeIndex,
  });

  @override
  _DraggableNodeState createState() => _DraggableNodeState();
}

class _DraggableNodeState extends State<DraggableNode> {
  bool isHovered = false;
  bool isSelected = false; // Track if the node is selected
  TextEditingController textController = TextEditingController();
  double width = 100;
  double height = 50;

  @override
  void initState() {
    super.initState();
    textController.addListener(_updateSize);
  }

  @override
  void dispose() {
    textController.removeListener(_updateSize);
    textController.dispose();
    super.dispose();
  }

  void _updateSize() {
    final text = textController.text.isEmpty ? " " : textController.text;

    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      maxLines: null, // Allow multiple lines
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: 250); // Max width limit

    setState(() {
      width = textPainter.width.clamp(100, 250).toDouble();  // Dynamic width
      height = (textPainter.height + 20).clamp(50, double.infinity);  // Dynamic height
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: () {
          setState(() {
            isSelected = !isSelected; // Toggle selection on tap
          });
        },
        onPanUpdate: (details) {
          widget.onDrag(Offset(
            details.globalPosition.dx - (width / 2),
            details.globalPosition.dy - (height / 2),
          ));
        },
        onDoubleTap: () {
          widget.onConnect(widget.nodeIndex + 1);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(60),
              child: Container(
                width: width,
                height: height,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFFFD8A8), // Change color when selected
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.black, // Blue border when selected
                    width: isSelected? 2.0 : 1.0, // Border width
                  ),
                ),
                alignment: Alignment.center,
                child: TextField(
                  controller: textController,
                  maxLines: null, // Allows text to wrap
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
            if (isSelected) ..._buildSelectionBoxes(),
            if (isHovered) ..._buildConnectionPoints(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSelectionBoxes() {
    return [
      _selectionBox(Offset(-width / 2 - 10, -height / 2 - 10)), // Top-left corner
      _selectionBox(Offset(width / 2 + 10, -height / 2 - 10)), // Top-right corner
      _selectionBox(Offset(-width / 2 - 10, height / 2 + 10)), // Bottom-left corner
      _selectionBox(Offset(width / 2 + 10, height / 2 + 10)), // Bottom-right corner
    ];
  }

  Widget _selectionBox(Offset offset) {
    return Positioned(
      left: (width / 2) + offset.dx + 53,
      top: (height / 2) + offset.dy + 53,
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
      _connectionPoint(Offset(0, -height / 2 - 30)),  // Top
      _connectionPoint(Offset(0, height / 2 + 30)),   // Bottom
      _connectionPoint(Offset(-width / 2 - 30, 0)),   // Left
      _connectionPoint(Offset(width / 2 + 30, 0)),    // Right
    ];
  }

  Widget _connectionPoint(Offset offset) {
    return Positioned(
      left: (width / 2) + offset.dx + 53,
      top: (height / 2) + offset.dy + 53,
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
