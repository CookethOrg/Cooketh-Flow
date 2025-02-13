import 'dart:math';

import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:flutter/material.dart';

class WorkspaceProvider extends StateHandler {
  // New instance of flow manager (new file)
  FlowManager flowManager = FlowManager();
  Map<String, FlowNode> _nodeList = {};

  WorkspaceProvider([super.intialState]) {
    _nodeList = {
      "1": FlowNode(
          id: "1", type: NodeType.rectangular, position: Offset(300, 400)),
      "2": FlowNode(
          id: "2", type: NodeType.rectangular, position: Offset(500, 300))
    };
    updateList();
  }

  Map<String, FlowNode> get nodeList => _nodeList;
  void updateList() {
    flowManager.nodes.addAll(_nodeList);
    notifyListeners();
  }

  // new node
  void addNode({
    NodeType type = NodeType.rectangular,
  }) {
    FlowNode node = FlowNode(id: (_nodeList.length + 1).toString(), type: type, position: Offset(
                            Random().nextDouble() * 1500, // Random X position
                            Random().nextDouble() * 800, // Random Y position
                          ));
    flowManager.addNode(node);
    _nodeList.addAll({node.id: node});
    // print(flowManager.exportFlow());
    notifyListeners();
  }
}
