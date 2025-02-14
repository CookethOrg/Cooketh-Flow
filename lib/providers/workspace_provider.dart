import 'dart:math';

import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/core/widgets/nodes/selection_box.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:flutter/material.dart';

class WorkspaceProvider extends StateHandler {
  // New instance of flow manager (new file)
  FlowManager flowManager = FlowManager();
  Map<String, FlowNode> _nodeList = {};
  bool _isHovered = false;
  // bool _isSelected = nodeList["1"]!.isSelected; // Track if the node is selected
  double _width = 150;
  double _height = 75;

  double getWidth(String id) => nodeList[id]!.size.width;
  double getHeight(String id) => nodeList[id]!.size.height;

  WorkspaceProvider([super.intialState]) {
    _nodeList = {
      "1": FlowNode(
          id: "1",
          // data: t1,
          type: NodeType.rectangular,
          position: Offset(
            Random().nextDouble() * 1500, // Random X position
            Random().nextDouble() * 800, // Random Y position
          )),
      "2": FlowNode(
          id: "2",
          // data: t2,
          type: NodeType.rectangular,
          position: Offset(
            Random().nextDouble() * 1500, // Random X position
            Random().nextDouble() * 800, // Random Y position
          ))
    };
    updateList();
  }

  // Getters
  bool get isHovered => _isHovered;
  // bool get isSelected => ;
  // double get width => nodeList[id]?.size.width ?? 200.0;
  // double get height => _height;

  // Setters
  void setHover(bool val) {
    _isHovered = val;
    notifyListeners();
  }

  void onResize(String id, Size newSize) {
    print(
        "Resizing node $id to height: ${newSize.height} and width: ${newSize.width}");
    if (nodeList.containsKey(id)) {
      // Apply minimum size constraints
      double width = newSize.width.clamp(100.0, double.infinity);
      double height = newSize.height.clamp(50.0, double.infinity);

      nodeList[id]!.size = Size(width, height);
      notifyListeners();
    }
  }

  void changeSelected(String nodeId) {
    flowManager.nodes[nodeId]!.isSelected =
        !flowManager.nodes[nodeId]!.isSelected;
    updateList();
    // setHover(false);
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

  Map<String, FlowNode> get nodeList => _nodeList;
  void updateList() {
    flowManager.nodes.addAll(_nodeList);
    print(flowManager.exportFlow());
    notifyListeners();
  }

  // new node
  void addNode({
    NodeType type = NodeType.rectangular,
  }) {
    // TextEditingController newController = TextEditingController();
    FlowNode node = FlowNode(
        id: (_nodeList.length + 1).toString(),
        // data: newController,
        type: type,
        position: Offset(
          Random().nextDouble() * 1500, // Random X position
          Random().nextDouble() * 800, // Random Y position
        ));
    flowManager.addNode(node);
    _nodeList.addAll({node.id: node});
    // print(flowManager.exportFlow());
    notifyListeners();
  }

  void dragNode(String id, Offset off) {
    flowManager.nodes[id]!.position = off;
    notifyListeners();
  }

  // Check if any node is currently selected
  bool get hasSelectedNode => nodeList.values.any((node) => node.isSelected);

  // Get currently selected node (if any)
  // FlowNode? get selectedNode => nodeList.values.firstWhere(
  //   (node) => node.isSelected,
  //   orElse: () => null,
  // );
}
