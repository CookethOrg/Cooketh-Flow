import 'package:cookethflow/core/utils/utils.dart';
import 'package:flutter/material.dart';

class NodeProvider extends StateHandler {
  bool _isHovered = false;
  bool _isSelected = false; // Track if the node is selected
  double _width = 100;
  double _height = 50;
  TextEditingController textController = TextEditingController();

  // Constructor with an optional initial state
  NodeProvider([ProviderState? initialState]) : super(initialState) {
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
    notifyListeners();
  }

  void setWidth(double w) {
    _width = w;
    notifyListeners();
  }

  void setHeight(double h) {
    _height = h;
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
  
}
