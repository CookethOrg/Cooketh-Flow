import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
// import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:cookethflow/core/services/file_services.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/core/widgets/nodes/database_node.dart';
import 'package:cookethflow/core/widgets/nodes/diamond_node.dart';
import 'package:cookethflow/core/widgets/nodes/parallelogram_node.dart';
import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

// Add this enum to the file
enum ExportType { json, png, svg }

class WorkspaceProvider extends StateHandler {
  // Reference to the FlowmanageProvider
  late final FlowmanageProvider fl;
  // Reference to the current FlowManager
  late FlowManager flowManager;
  Map<String, FlowNode> _nodeList = {};
  ConnectionPointSelection? selectedConnection;
  bool _isHovered = false;
  final List<Map<String, FlowNode>> _undoStack = [];
  final List<Map<String, FlowNode>> _redoStack = [];
  TextEditingController flowNameController = TextEditingController();
  bool _isInitialized = false;
  String _currentFlowId = "";
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  double _scale = 1.0; // scaling and zoom in out
  Offset _position = Offset.zero;
  double minScale = 0.1;
  double maxScale = 5.0;

  // Getters
  String get currentFlowId => _currentFlowId;
  bool get isHovered => _isHovered;
  Map<String, FlowNode> get nodeList => _nodeList;
  bool get hasSelectedNode => nodeList.values.any((node) => node.isSelected);
  double getWidth(String id) => nodeList[id]!.size.width;
  double getHeight(String id) => nodeList[id]!.size.height;
  List<Connection> get connections => flowManager.connections.toList();
  bool get isInitialized => _isInitialized;
  GlobalKey get repaintBoundaryKey => _repaintBoundaryKey;
  FlowNode? get selectedNode => nodeList.values.firstWhereOrNull(
        (node) => node.isSelected,
      );
  double get scale => _scale;
  Offset get position => _position;

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

      // load the scale and position from flowmanager
      _scale = flowManager.scale ?? 1.0;
      _position = flowManager.position ?? Offset.zero;

      print("Initialized workspace for flow ID: $flowId");
      print(
          "Flow has ${_nodeList.length} nodes and ${flowManager.connections.length} connections");

      _isInitialized = true;
      notifyListeners();
    } else {
      print("Error: Flow ID $flowId not found in flow list");
      // Create an empty flow if not found
      flowManager = FlowManager(flowId: flowId);
      _nodeList = {};
      flowNameController.text = "New Project";
      _scale = 1.0;
      _position = Offset.zero;

      _isInitialized = false;
      notifyListeners();
    }
  }

  void updatePosition(Offset newPos) {
    _position = newPos;
    notifyListeners();
  }

  void updateScale(double newScale) {
    _scale = newScale;
    notifyListeners();
  }

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

    flowManager.scale = _scale;
    flowManager.position = _position;

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
    // Store the position in the workspace's coordinate space
    _nodeList[id]!.position = off;
    updateFlowManager();
    notifyListeners();
  }
}

  void removeSelectedNodes() {
  if (selectedNode == null) {
    print("No node selected for removal.");
    return;
  }

  String nodeId = selectedNode!.id;

  if (!_nodeList.containsKey(nodeId)) {
    print("Error: Node with ID $nodeId not found.");
    return;
  }

  _saveStateForUndo(); // Save state before removal

  // Get all connections involving this node
  List<Connection> connectionsToRemove = [];
  for (var connection in flowManager.connections) {
    if (connection.sourceNodeId == nodeId || connection.targetNodeId == nodeId) {
      connectionsToRemove.add(connection);
    }
  }

  // Remove each connection
  for (var connection in connectionsToRemove) {
    flowManager.connections.remove(connection);
    
    // Clean up connection from the other node too
    String otherNodeId = connection.sourceNodeId == nodeId 
      ? connection.targetNodeId 
      : connection.sourceNodeId;
    
    if (_nodeList.containsKey(otherNodeId)) {
      _nodeList[otherNodeId]!.removeConnection(connection);
    }
  }

  // Remove the node from local list
  _nodeList.remove(nodeId);
  
  // Remove the node from FlowManager
  flowManager.removeNode(nodeId);

  // Clear selection
  selectedNode = null;

  // Update the database
  saveChanges();
  notifyListeners();
  
  print("Node and its connections removed successfully.");
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
    return text.length > 12 ? '${text.substring(0, 12)}...' : text;
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

  Future<void> exportWorkspace({required ExportType exportType}) async {
    try {
      String safeName = flowManager.flowName
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_');

      if (safeName.isEmpty) safeName = "workspace";
      String fileName = "${safeName}_${DateTime.now().millisecondsSinceEpoch}";

      String res = "";

      switch (exportType) {
        case ExportType.json:
          final Map<String, dynamic> workspaceData = flowManager.exportFlow();
          final String jsonString =
              JsonEncoder.withIndent('  ').convert(workspaceData);
          res = await FileServices()
              .exportFile(fileName: fileName, jsonString: jsonString);
          break;

        case ExportType.png:
          final boundary = _repaintBoundaryKey.currentContext!
              .findRenderObject() as RenderRepaintBoundary;
          final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
          final ByteData? byteData =
              await image.toByteData(format: ui.ImageByteFormat.png);

          if (byteData != null) {
            final Uint8List pngBytes = byteData.buffer.asUint8List();
            res = await FileServices()
                .exportPNG(fileName: fileName, pngBytes: pngBytes);
          } else {
            throw Exception("Failed to generate PNG data");
          }
          break;

        case ExportType.svg:
          final svgString = _generateSVG();
          res = await FileServices()
              .exportSVG(fileName: fileName, svgString: svgString);
          break;
      }

      print("$res $fileName exported as ${exportType.toString()}");
    } catch (e) {
      print("Error exporting workspace: $e");
      rethrow;
    }
  }

// SVG generation method
  String _generateSVG() {
    // Canvas dimensions
    int width = 1000;
    int height = 800;

    // SVG Header
    String svg = '''
  <svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height" viewBox="0 0 $width $height">
  <rect width="$width" height="$height" fill="white"/>
  ''';

    // Add nodes to SVG
    for (var entry in nodeList.entries) {
      final node = entry.value;
      final x = node.position.dx;
      final y = node.position.dy;
      final w = node.size.width;
      final h = node.size.height;
      final text = node.data.text;

      String nodeShape;
      String fill;

      switch (node.type) {
        case NodeType.rectangular:
          nodeShape =
              '<rect x="$x" y="$y" width="$w" height="$h" rx="8" ry="8" stroke="black" stroke-width="1" fill="#FFD8A8"/>';
          fill = '#FFD8A8';
          break;
        case NodeType.diamond:
          // Calculate diamond points
          final centerX = x + w / 2;
          final centerY = y + h / 2;
          final points =
              '$centerX,$y ${x + w},$centerY $centerX,${y + h} $x,$centerY';
          nodeShape =
              '<polygon points="$points" stroke="black" stroke-width="1" fill="#C8E6C9"/>';
          fill = '#C8E6C9';
          break;
        case NodeType.parallelogram:
          final offset = 20.0;
          final points =
              '${x + offset},$y ${x + w},$y ${x + w - offset},${y + h} $x,${y + h}';
          nodeShape =
              '<polygon points="$points" stroke="black" stroke-width="1" fill="#BBDEFB"/>';
          fill = '#BBDEFB';
          break;
        case NodeType.database:
          nodeShape = '''
        <ellipse cx="${x + w / 2}" cy="$y" rx="${w / 2}" ry="${h * 0.2}" stroke="black" stroke-width="1" fill="#D1C4E9"/>
        <rect x="$x" y="$y" width="$w" height="${h * 0.8}" stroke="black" stroke-width="1" fill="#D1C4E9"/>
        <ellipse cx="${x + w / 2}" cy="${y + h * 0.8}" rx="${w / 2}" ry="${h * 0.2}" stroke="black" stroke-width="1" fill="#D1C4E9"/>
        ''';
          fill = '#D1C4E9';
          break;
      }

      // Add the node shape
      svg += nodeShape;

      // Add text
      svg +=
          '<text x="${x + w / 2}" y="${y + h / 2}" font-family="Arial" font-size="14" text-anchor="middle" dominant-baseline="middle" fill="black">${_escapeXml(text)}</text>';
    }

    // Add connections
    for (var connection in flowManager.connections) {
      final sourceNode = nodeList[connection.sourceNodeId]!;
      final targetNode = nodeList[connection.targetNodeId]!;

      // Calculate connection points
      final sourcePoint =
          _getConnectionPointCoordinates(sourceNode, connection.sourcePoint);
      final targetPoint =
          _getConnectionPointCoordinates(targetNode, connection.targetPoint);

      // Draw the connection line
      svg +=
          '<path d="M${sourcePoint.dx},${sourcePoint.dy} C${sourcePoint.dx + 50},${sourcePoint.dy} ${targetPoint.dx - 50},${targetPoint.dy} ${targetPoint.dx},${targetPoint.dy}" stroke="black" stroke-width="2" fill="none" marker-end="url(#arrowhead)"/>';
    }

    // Add arrowhead marker definition
    svg += '''
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="black"/>
    </marker>
  </defs>
  ''';

    // Close SVG
    svg += '</svg>';

    return svg;
  }

// Helper function to escape XML special characters
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

// Helper to get connection point coordinates
  Offset _getConnectionPointCoordinates(FlowNode node, ConnectionPoint point) {
    final centerX = node.position.dx + (node.size.width / 2);
    final centerY = node.position.dy + (node.size.height / 2);

    switch (point) {
      case ConnectionPoint.top:
        return Offset(centerX, node.position.dy);
      case ConnectionPoint.right:
        return Offset(node.position.dx + node.size.width, centerY);
      case ConnectionPoint.bottom:
        return Offset(centerX, node.position.dy + node.size.height);
      case ConnectionPoint.left:
        return Offset(node.position.dx, centerY);
    }
  }

  void removeConnection(Connection connection) {
  _saveStateForUndo();
  
  // Remove the connection from the nodes
  if (_nodeList.containsKey(connection.sourceNodeId)) {
    _nodeList[connection.sourceNodeId]!.removeConnection(connection);
  }
  if (_nodeList.containsKey(connection.targetNodeId)) {
    _nodeList[connection.targetNodeId]!.removeConnection(connection);
  }
  
  // Remove from the flowManager
  flowManager.connections.remove(connection);
  
  // Update database
  saveChanges();
  notifyListeners();
}
}
