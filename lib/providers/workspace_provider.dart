import 'dart:math';
import 'package:collection/collection.dart';
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
  // Reference to the FlowmanageProvider
  late final FlowmanageProvider fl;
  // Reference to the current FlowManager
  late FlowManager flowManager;
  Map<String, FlowNode> _nodeList = {};
  ConnectionPointSelection? selectedConnection;
  bool _isHovered = false;
  final List<Map<String, FlowNode>> _undoStack = [];
  List<Map<String, FlowNode>> _redoStack = [];
  TextEditingController flowNameController = TextEditingController();
  bool _isInitialized = false;
  String _currentFlowId = "";

  WorkspaceProvider(this.fl) : super() {
    print("WorkspaceProvider initialized with flow ID: ${fl.newFlowId}");
    if (fl.newFlowId.isNotEmpty) {
      initializeWorkspace(fl.newFlowId);
    }
  }

  // Initialize the workspace with a specific flow ID
  void initializeWorkspace(String flowId) {
    _currentFlowId = flowId;
    print("Initializing workspace for flow ID: $flowId");
    
    // Get the FlowManager for this flow ID
    if (fl.flowList.containsKey(flowId)) {
      flowManager = fl.flowList[flowId]!;
      
      // Copy nodes from FlowManager to local _nodeList
      _nodeList = {};
      flowManager.nodes.forEach((id, node) {
        _nodeList[id] = node.copy();
      });
      
      // Set the flow name in the controller
      flowNameController.text = flowManager.flowName;
      
      print("Initialized workspace for flow ID: $flowId");
      print("Flow has ${_nodeList.length} nodes and ${flowManager.connections.length} connections");
      
      _isInitialized = true;
      notifyListeners();
    } else {
      print("Error: Flow ID $flowId not found in flow list");
      // Create an empty flow if not found
      flowManager = FlowManager(flowId: flowId);
      _nodeList = {};
      flowNameController.text = "New Project";
      
      _isInitialized = false;
      notifyListeners();
    }
  }

  // Getters
  String get currentFlowId => _currentFlowId;
  bool get isHovered => _isHovered;
  Map<String, FlowNode> get nodeList => _nodeList;
  bool get hasSelectedNode => nodeList.values.any((node) => node.isSelected);
  double getWidth(String id) => nodeList[id]!.size.width;
  double getHeight(String id) => nodeList[id]!.size.height;
  List<Connection> get connections => flowManager.connections.toList();
  bool get isInitialized => _isInitialized;

  // Get currently selected node (if any)
  FlowNode? get selectedNode => nodeList.values.firstWhereOrNull(
        (node) => node.isSelected,
      );

  // Set currently selected node
  set selectedNode(FlowNode? node) {
    if (node != null) {
      nodeList.forEach((key, n) {
        n.isSelected = n.id == node.id;
      });
    } else {
      nodeList.forEach((key, n) {
        n.isSelected = false;
      });
    }
    notifyListeners();
  }

  // Functions ->
  void setHover(bool val) {
    _isHovered = val;
    notifyListeners();
  }

  void changeProjectName(String val) {
    flowNameController.text = val;
    flowManager.flowName = val;
    updateFlowManager();
    notifyListeners();
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
          updateFlowManager();
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
      updateFlowManager();
      notifyListeners();
    }
  }

  void changeSelected(String nodeId) {
    if (_nodeList.containsKey(nodeId)) {
      _nodeList.forEach((key, node) {
        node.isSelected = key == nodeId ? !node.isSelected : false;
      });
      notifyListeners();
    }
  }

  bool displayToolbox() {
    if (selectedNode != null && selectedNode!.isSelected) {
      notifyListeners();
      return true;
    }
    return false;
  }

  void _saveStateForUndo() {
    _undoStack.add(Map<String, FlowNode>.from(_nodeList.map(
      (key, node) => MapEntry(key, node.copy()),
    )));
  }

  // Sync local _nodeList to flowManager
  void updateFlowManager() {
    // Update nodes in the FlowManager
    flowManager.nodes.clear();
    _nodeList.forEach((id, node) {
      flowManager.nodes[id] = node.copy();
    });
    
    // Save to database
    saveChanges();
  }

  // Save changes to database via FlowmanageProvider
  Future<void> saveChanges() async {
    try {
      await fl.updateFlowList();
      print("Workspace changes saved to database");
    } catch (e) {
      print("Error saving workspace changes: $e");
    }
  }

  // Add a new node to the workspace
  void addNode({NodeType type = NodeType.rectangular}) {
    _saveStateForUndo();
    
    // Generate a new unique ID
    String newId = (_nodeList.length + 1).toString();
    while (_nodeList.containsKey(newId)) {
      newId = (int.parse(newId) + 1).toString();
    }
    
    // Create a new node
    FlowNode node = FlowNode(
      id: newId,
      type: type,
      position: Offset(
        Random().nextDouble() * 300 + 100, // More reasonable positioning
        Random().nextDouble() * 200 + 100,
      ),
    );
    
    // Add to local node list
    _nodeList[newId] = node;
    
    // Update the FlowManager and save changes
    updateFlowManager();
    
    notifyListeners();
  }

  void dragNode(String id, Offset off) {
    _saveStateForUndo();
    
    if (_nodeList.containsKey(id)) {
      _nodeList[id]!.position = off;
      updateFlowManager();
      notifyListeners();
    }
  }

  void removeSelectedNodes() {
    if (selectedNode == null) {
      print("Error: No node selected.");
      return;
    }

    String nodeId = selectedNode!.id;

    if (!_nodeList.containsKey(nodeId)) {
      print("Error: Node with ID $nodeId not found.");
      return;
    }

    print("Removing node: $nodeId");

    _saveStateForUndo(); // Save state before removal

    // Remove the node from the local node list
    _nodeList.remove(nodeId);
    
    // Remove the node from the FlowManager
    flowManager.removeNode(nodeId);

    // Clear selection after deletion
    selectedNode = null;
    
    // Update the database
    saveChanges();
    
    notifyListeners();

    print("Node removed successfully.");
  }

  void undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(Map<String, FlowNode>.from(_nodeList.map(
        (key, node) => MapEntry(key, node.copy()),
      ))); // Save current state before undoing

      _nodeList = _undoStack.removeLast();
      updateFlowManager();
      notifyListeners();
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      _undoStack.add(Map<String, FlowNode>.from(_nodeList.map(
        (key, node) => MapEntry(key, node.copy()),
      )));

      _nodeList = _redoStack.removeLast();
      updateFlowManager();
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