import 'package:cookethflow/core/utils/utils.dart';
import 'package:cookethflow/core/widgets/nodes/selection_box.dart';
import 'package:flutter/material.dart';

class NodeProvider extends StateHandler {
  bool _isHovered = false;
  bool _isSelected = false; // Track if the node is selected
  double _width = 100;
  double _height = 50;
  List<Offset> nodePositions = [Offset(100, 100), Offset(200, 300)];
  double scale = 1.0; // Initial zoom scale
  double lastScale = 1.0; // Last scale factor for pinch-to-zoom
  TextEditingController textController = TextEditingController();

  // Constructor with an optional initial state
  NodeProvider([super.initialState]) {
    textController.addListener(_updateSize);
  }

  // Getters
  bool get isHovered => _isHovered;
  bool get isSelected => _isSelected;
  double get width => _width;
  double get height => _height;

  // Setters
  void setHover(bool val) {
    _isHovered = val;
    notifyListeners();
  }

  void changeSelected() {
    _isSelected = !_isSelected;
    setHover(false);
    notifyListeners();
  }

  void setWidth(double w) {
    _width = w;
    notifyListeners();
  }

  void startScale(ScaleStartDetails details) {
    lastScale = scale;
    notifyListeners();
  }

  void scaleUpdate(ScaleUpdateDetails details) {
    scale = lastScale * details.scale;
    scale = scale.clamp(0.5, 3.0); // Limit zoom scale
    notifyListeners();
  }

  // void onDragNode(Offset pos, int i) {
  //   nodePositions[i] = pos / scale;
  //   notifyListeners();
  // }

  void setHeight(double h) {
    _height = h;
    notifyListeners();
  }

  void addNode(Offset position) {
    nodePositions.add(position);
    notifyListeners();
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
    setWidth(textPainter.width.clamp(100, 250).toDouble()); // Dynamic width
    setHeight((textPainter.height + 20).clamp(50, double.infinity));
  }

  List<Widget> buildSelectionBoxes() {
    return [
      SelectionBox(
        height: _height,
        width: _width,
        offset: Offset(-_width / 2 + 13, -_height / 2 + 15),
      ), // Top-left
      SelectionBox(
        height: _height,
        width: _width,
        offset: Offset(_width / 2 + 17, -_height / 2 + 15),
      ), // Top-right
      SelectionBox(
        height: _height,
        width: _width,
        offset: Offset(-_width / 2 + 13, _height / 2 + 15),
      ), // bottom-left
      SelectionBox(
        height: _height,
        width: _width,
        offset: Offset(_width / 2 + 17, _height / 2 + 15),
      ), // bottom-right
    ];
  }

  // List<Widget> buildConnectionPoints() {
  //   return [
  //     // ConnectionBox(top: -_height / 2 - 30, bottom: _height / 2 + 30, left: -_width / 2 - 30, right: _width / 2 + 30),
  //     _connectionPoint(Offset(0, -_height / 2), Icons.arrow_drop_up_outlined), // Top
  //     _connectionPoint(Offset(0, _height / 2 + 3), Icons.arrow_drop_down_outlined), // Bottom
  //     _connectionPoint(Offset(-_width / 2 - 2, 0), Icons.arrow_left_outlined), // Left
  //     _connectionPoint(Offset(_width / 2+ 2, 0), Icons.arrow_right_outlined), // Right
  //   ];
  // }

  // Widget _connectionPoint(Offset offset, IconData icon) {
  //   return Positioned(
  //     // left: (_width / 2) + offset.dx + 40,
  //     // top: (_height / 2) + offset.dy + 38,
  //     child: Container(
  //       width: 8,
  //       height: 8,
  //       decoration: const BoxDecoration(
  //         // color: Color.fromARGB(255, 145, 145, 145),
  //         // shape: BoxShape.circle,
  //       ),
  //       child: Connector(icon: icon,),
  //     ),
  //   );
  // }
}
