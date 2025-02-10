import 'package:cookethflow/core/utils/utils.dart';
import 'package:flutter/material.dart';

class DashboardProvider extends StateHandler {
  bool _isOpen = false;
  bool _isEditing = false;
  final TextEditingController _controller = TextEditingController();
  DashboardProvider([super.intialState]) {
    _controller.text = 'Cooketh Flow';
  }

  // Getters
  bool get isOpen => _isOpen;
  bool get isEditing => _isEditing;
  TextEditingController get controller => _controller;

  void toggleDrawer() {
    if (!_isOpen) _isEditing = false; // Prevent editing when closed
    _isOpen = !_isOpen;
    notifyListeners();
  }

  String getTruncatedTitle() {
    String text = _controller.text;
    return text.length > 12 ? text.substring(0, 12) + '...' : text;
  }
}
