import 'dart:math';

import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/core/widgets/buttons/connector.dart';
import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/screens/discarded/selection_box.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:flutter/material.dart';

class WorkspaceProvider extends StateHandler {
  // New instance of flow manager (new file)
  FlowManager flowManager = FlowManager();
  // Keep track of list of nodes
  Map<String, FlowNode> _nodeList = {};
  bool _isHovered = false;

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
  Map<String, FlowNode> get nodeList => _nodeList;
  bool get hasSelectedNode => nodeList.values.any(
      (node) => node.isSelected); // Check if any node is currently selected
  double getWidth(String id) => nodeList[id]!.size.width;
  double getHeight(String id) => nodeList[id]!.size.height;
  // Get currently selected node (if any)
  FlowNode? get selectedNode => nodeList.values.firstWhere(
        (node) => node.isSelected,
        // orElse: () => null,
      );

  // Functions ->
  void setHover(bool val) {
    _isHovered = val;
    notifyListeners();
  }

  void onResize(String id, Size newSize) {
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

  void updateList() {
    flowManager.nodes.addAll(_nodeList);
    // print(flowManager.exportFlow());
    notifyListeners();
  }

  // new node addition
  void addNode({
    NodeType type = NodeType.rectangular,
  }) {
    FlowNode node = FlowNode(
        id: (_nodeList.length + 1).toString(),
        type: type,
        position: Offset(
          Random().nextDouble() * 1500,
          Random().nextDouble() * 800,
        ));
    flowManager.addNode(node);
    _nodeList.addAll({node.id: node});
    notifyListeners();
  }

  void dragNode(String id, Offset off) {
    flowManager.nodes[id]!.position = off;
    notifyListeners();
  }

  Widget buildConnectionPoints(BuildContext context, ConnectionPoint con, String id) {
  final containerPadding = 20.0;
  final connectionSize = 16.0; // Size for the connection point
  final distanceFromEdge = 40.0; // Distance from the edge of the node
  
  // Total width and height including padding
  final totalWidth = getWidth(id) + (containerPadding * 2);
  final totalHeight = getHeight(id) + (containerPadding * 2);
  
  // Calculate center positions
  late double left, top;
  
  switch (con) {
    case ConnectionPoint.top:
      left = (totalWidth - connectionSize) / 2;
      top = -connectionSize / 2;
      break;
    case ConnectionPoint.right:
      left = totalWidth - connectionSize / 2;
      top = (totalHeight - connectionSize) / 2;
      break;
    case ConnectionPoint.bottom:
      left = (totalWidth - connectionSize) / 2;
      top = totalHeight - connectionSize / 2;
      break;
    case ConnectionPoint.left:
      left = -connectionSize / 2;
      top = (totalHeight - connectionSize) / 2;
      break;
  }

  return Positioned(
    left: left,
    top: top,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        print("Connection point ${con.toString()} tapped");
        // Your tap handling logic here
      },
      child: Container(
        width: connectionSize,
        height: connectionSize,
        alignment: Alignment.center,
        // Optional: Add this to see the touch area
        // color: Colors.red,
        child: Connector(),
      ),
    ),
  );
}
}
