import 'dart:math';

import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/core/widgets/nodes/database_node.dart';
import 'package:cookethflow/core/widgets/nodes/diamond_node.dart';
import 'package:cookethflow/core/widgets/nodes/parallelogram_node.dart';
import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:flutter/material.dart';

class WorkspaceProvider extends StateHandler {
  // New instance of flow manager (new file)
  // FlowmanageProvider fl = FlowmanageProvider();
  FlowManager flowManager = FlowManager();
  // Keep track of list of nodes

  Map<String, FlowNode> _nodeList = {};
  Map<String, FlowNode> _nodeListCopy = {};
  List<Connection> connections = [];
  ConnectionPointSelection? selectedConnection;
  bool _isHovered = false;
  final List<Map<String, FlowNode>> _undoStack = [];
  List<Map<String, FlowNode>> _redoStack = [];
  TextEditingController flowNameController = TextEditingController();

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
    // flowManager.flowId = fl.newFlowId;
    flowNameController.text = flowManager.flowName;
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

  void changeProjectName(String val) {
    flowNameController.text = val;
    flowManager.flowName = val;
    notifyListeners();
  }

  void cloneNodeList() {
    _nodeListCopy = _nodeList.map((key, node) => MapEntry(key, node.copy()));
  }

  Widget buildNode(String id, NodeType type) {
    Widget nodeStruct;

    switch (type) {
      case NodeType.diamond:
        nodeStruct = DiamondNode(
          tcontroller: nodeList[id]!.data,
          height: getHeight(id),
          width: getWidth(id),
        );
        break;
      case NodeType.database:
        nodeStruct = DatabaseNode(
          controller: nodeList[id]!.data,
          height: getHeight(id),
          width: getWidth(id),
        );
        break;
      case NodeType.parallelogram:
        nodeStruct = ParallelogramNode(
          controller: nodeList[id]!.data,
          width: getWidth(id),
          height: getHeight(id),
        );
        break;
      default:
        nodeStruct = Container(
          width: getWidth(id),
          height: getHeight(id),
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 18),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD8A8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: nodeList[id]!.isSelected ? Colors.blue : Colors.black,
              width: nodeList[id]!.isSelected ? 2.5 : 1.0,
            ),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: nodeList[id]!.data,
            maxLines: null,
            style: const TextStyle(
              overflow: TextOverflow.ellipsis,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            cursorColor: Colors.white,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            textAlign: TextAlign.center,
          ),
        );
    }

    return nodeStruct;
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

  void _saveStateForUndo() {
    _undoStack.add(Map<String, FlowNode>.from(_nodeList.map(
      (key, node) => MapEntry(key, node.copy()),
    )));
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
    _saveStateForUndo();
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
    _saveStateForUndo();
    flowManager.nodes[id]!.position = off;
    notifyListeners();
  }

  void removeNode(String nodeId) {
    _saveStateForUndo();
    final node = _nodeList[nodeId];
    flowManager.removeNode(nodeId);
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(Map<String, FlowNode>.from(_nodeList.map(
        (key, node) => MapEntry(key, node.copy()),
      ))); // Save current state before undoing

      _nodeList = _undoStack.removeLast();
      notifyListeners();
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(Map<String, FlowNode>.from(_nodeList.map(
        (key, node) => MapEntry(key, node.copy()),
      )));

      _nodeList = _redoStack.removeLast();
      notifyListeners();
    }
  }

  bool isOpen = false;
  bool isEditing = false;

  void toggleDrawer() {
    if (!isOpen) isEditing = false; // Prevent editing when closed
    isOpen = !isOpen;
    notifyListeners();
  }

  String getTruncatedTitle() {
    String text = flowNameController.text;
    return text.length > 12 ? text.substring(0, 12) + '...' : text;
  }

  void onSubmit() {
    if (flowNameController.text.trim().isEmpty) {
      flowNameController.text = 'Untitled';
    }
    isEditing = false;
    changeProjectName(flowNameController.text);
    notifyListeners();
  }

  void setEdit() {
    isEditing = true;
    notifyListeners();
  }
}
