import 'dart:math';

import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:flutter/material.dart';

class WorkspaceProvider extends StateHandler {
  // New instance of flow manager (new file)
  FlowmanageProvider fl = FlowmanageProvider();
  FlowManager flowManager = FlowManager();
  // Keep track of list of nodes
  Map<String, FlowNode> _nodeList = {};
  List<Connection> connections = [];
  ConnectionPointSelection? selectedConnection;
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
    flowManager.flowId = fl.newFlowId;
    print(flowManager.nodes);
    print(flowManager.connections);

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

  void selectConnection(String nodeId, ConnectionPoint connectionPoint) {
    if (selectedConnection == null) {
      // First selection
      selectedConnection = ConnectionPointSelection(nodeId, connectionPoint);
      print("First connection selected: Node $nodeId, Point $connectionPoint");
      notifyListeners();
    } else {
      // Prevent connecting to the same node
      if (selectedConnection!.nodeId != nodeId) {
        bool connected = flowManager.connectNodes(
          sourceNodeId: selectedConnection!.nodeId,
          targetNodeId: nodeId,
          sourcePoint: selectedConnection!.connectionPoint,
          targetPoint: connectionPoint,
        );

        if (connected) {
          print("Connection created between nodes");
          updateList();
        } else {
          print("Connection failed - points might be already in use");
        }
      }
      selectedConnection = null;
      notifyListeners();
    }
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
    connections = flowManager.connections.toList();
    // flowManager.connections.addAll(connections);
    // print("Updated Connections: ${flowManager.connections}");
    print(flowManager.exportFlow());
    notifyListeners();
  }

  // new node addition
  void addNode({
    NodeType type = NodeType.parallelogram,
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
}
