import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:cookethflow/core/services/file_services.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/core/utils/ui_helper.dart';
import 'package:cookethflow/core/widgets/nodes/database_node.dart';
import 'package:cookethflow/core/widgets/nodes/diamond_node.dart';
import 'package:cookethflow/core/widgets/nodes/parallelogram_node.dart';
import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/models/flow_manager.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;

import 'package:phosphor_flutter/phosphor_flutter.dart';

class WorkspaceProvider extends StateHandler {
  late final FlowmanageProvider fl;
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
  double _scale = 1.0;
  Offset _position = Offset.zero;
  double minScale = 0.1;
  double maxScale = 5.0;
  bool _isPanning = false;
  final TransformationController _transformationController =
      TransformationController();

  String get currentFlowId => _currentFlowId;
  TransformationController get transformationController =>
      _transformationController;
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
  bool get isPanning => _isPanning;

  WorkspaceProvider(this.fl) : super() {
    if (fl.newFlowId.isNotEmpty) {
      initializeWorkspace(fl.newFlowId);
    }
  }

  void updatePanning(bool val) {
    _isPanning = val;
    notifyListeners();
  }

  void setInitialize(bool val) {
    if (_isInitialized != val) {
      _isInitialized = val;
      notifyListeners();
    }
  }

  void setHovered(bool val) {
    if (_isHovered != val) {
      _isHovered = val;
      notifyListeners();
    }
  }

  void initializeWorkspace(String flowId) {
    _currentFlowId = flowId;

    if (fl.flowList.containsKey(flowId)) {
      flowManager = fl.flowList[flowId]!;
      _nodeList = {};
      flowManager.nodes.forEach((id, node) {
        _nodeList[id] = node.copy();
        debugPrint(
            'Loaded node $id with color: #${node.colour.value.toRadixString(16).padLeft(8, '0')}');
      });
      flowNameController.text = flowManager.flowName;
      _scale = flowManager.scale ?? 1.0;
      _scale = _scale.clamp(0.1, 5.0);
      _position = flowManager.position ?? Offset.zero;
      _isInitialized = true;
      notifyListeners();
    } else {
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
    _scale = newScale.clamp(0.1, 5.0);
    notifyListeners();
  }

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

  void changeProjectName(String val) {
    flowNameController.text = val;
    flowManager.flowName = val;
    updateFlowManager();
    notifyListeners();
  }

  Widget buildNode(String id, NodeType type) {
    Widget nodeStruct;
    final nodeColor = _nodeList[id]!.colour; // Get the node's color

    switch (type) {
      case NodeType.diamond:
        nodeStruct = DiamondNode(
          id: id,
          tcontroller: nodeList[id]!.data,
          height: getHeight(id),
          width: getWidth(id),
          // color: nodeColor, // Pass color explicitly
        );
        break;
      case NodeType.database:
        nodeStruct = DatabaseNode(
          id: id,
          controller: nodeList[id]!.data,
          height: getHeight(id),
          width: getWidth(id),
          // color: nodeColor, // Pass color explicitly
        );
        break;
      case NodeType.parallelogram:
        nodeStruct = ParallelogramNode(
          id: id,
          controller: nodeList[id]!.data,
          width: getWidth(id),
          height: getHeight(id),
          // color: nodeColor, // Pass color explicitly
        );
        break;
      default:
        nodeStruct = Container(
          width: getWidth(id),
          height: getHeight(id),
          padding: const EdgeInsets.fromLTRB(15, 12, 15, 18),
          decoration: BoxDecoration(
            color: nodeColor,
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
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: Colors.black,
              fontStyle:
                  nodeList[id]!.isItalic ? FontStyle.italic : FontStyle.normal,
              fontWeight:
                  nodeList[id]!.isBold ? FontWeight.bold : FontWeight.normal,
              decoration: TextDecoration.combine([
                if (nodeList[id]!.isUnderlined) TextDecoration.underline,
                if (nodeList[id]!.isStrikeThrough) TextDecoration.lineThrough
              ]),
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
      selectedConnection = ConnectionPointSelection(nodeId, connectionPoint);
      notifyListeners();
    } else {
      if (selectedConnection!.nodeId != nodeId) {
        bool connected = flowManager.connectNodes(
          sourceNodeId: selectedConnection!.nodeId,
          targetNodeId: nodeId,
          sourcePoint: selectedConnection!.connectionPoint,
          targetPoint: connectionPoint,
        );

        if (connected) {
          updateFlowManager();
        }
      }
      selectedConnection = null;
      notifyListeners();
    }
  }

  void onResize(String id, Size newSize) {
    if (nodeList.containsKey(id)) {
      double width = newSize.width.clamp(150.0, double.infinity);
      double height = newSize.height.clamp(75.0, double.infinity);

      _saveStateForUndo();
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

    if (_undoStack.length > 20) {
      _undoStack.removeAt(0);
    }
  }

  void updateFlowManager() {
    flowManager.nodes.clear();
    _nodeList.forEach((id, node) {
      flowManager.nodes[id] = node.copy();
    });
    flowManager.scale = _scale;
    flowManager.position = _position;
    saveChanges();
  }

  Future<void> saveChanges() async {
    try {
      await fl.updateFlowList();
    } catch (e) {
      print("Error saving workspace changes: $e");
    }
  }

  void addNode({NodeType type = NodeType.rectangular}) {
    _saveStateForUndo();

    String newId = (_nodeList.length + 1).toString();
    while (_nodeList.containsKey(newId)) {
      newId = (int.parse(newId) + 1).toString();
    }

    FlowNode node = FlowNode(
      id: newId,
      type: type,
      position: Offset(
        ((canvasDimension / 2) - 100) + Random().nextDouble() * 300,
        ((canvasDimension / 2) - 100) + Random().nextDouble() * 300,
      ),
      colour: Color(0xffFAD7A0),
    );

    _nodeList[newId] = node;
    updateFlowManager();
    notifyListeners();
  }

  void dragNode(String id, Offset newPosition) {
    if (_nodeList.containsKey(id)) {
      _saveStateForUndo();
      final node = _nodeList[id]!;
      node.position = newPosition;

      final connectionsToUpdate = flowManager.connections
          .where((c) => c.sourceNodeId == id || c.targetNodeId == id)
          .toList();

      for (final connection in connectionsToUpdate) {
        flowManager.connections.remove(connection);
        flowManager.connections.add(connection.copy());
      }

      updateFlowManager();
      notifyListeners();
    }
  }

  void removeSelectedNodes() {
    if (selectedNode == null) {
      return;
    }

    String nodeId = selectedNode!.id;

    if (!_nodeList.containsKey(nodeId)) {
      return;
    }

    _saveStateForUndo();

    List<Connection> connectionsToRemove = [];
    for (var connection in flowManager.connections) {
      if (connection.sourceNodeId == nodeId ||
          connection.targetNodeId == nodeId) {
        connectionsToRemove.add(connection);
      }
    }

    for (var connection in connectionsToRemove) {
      flowManager.connections.remove(connection);
      String otherNodeId = connection.sourceNodeId == nodeId
          ? connection.targetNodeId
          : connection.sourceNodeId;

      if (_nodeList.containsKey(otherNodeId)) {
        _nodeList[otherNodeId]!.removeConnection(connection);
      }
    }

    _nodeList.remove(nodeId);
    flowManager.removeNode(nodeId);
    selectedNode = null;
    updateFlowManager();
    notifyListeners();
  }

  void undo() {
    if (_undoStack.isNotEmpty) {
      _redoStack.add(Map<String, FlowNode>.from(_nodeList.map(
        (key, node) => MapEntry(key, node.copy()),
      )));

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
    if (!isOpen) isEditing = false;
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
              .exportFile(defaultName: fileName, jsonString: jsonString);
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
                .exportPNG(defaultName: fileName, pngBytes: pngBytes);
          } else {
            throw Exception("Failed to generate PNG data");
          }
          break;

        case ExportType.svg:
          final svgString = _generateSVG();
          res = await FileServices()
              .exportSVG(defaultName: fileName, svgString: svgString);
          break;
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> createImg() async {
    final boundary = _repaintBoundaryKey.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData;
  }

  String _generateSVG() {
    int width = 1000;
    int height = 800;

    String svg = '''
  <svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height" viewBox="0 0 $width $height">
  <rect width="$width" height="$height" fill="white"/>
  ''';

    for (var entry in nodeList.entries) {
      final node = entry.value;
      final x = node.position.dx;
      final y = node.position.dy;
      final w = node.size.width;
      final h = node.size.height;
      final text = node.data.text;
      final fill =
          '#${node.colour.value.toRadixString(16).padLeft(8, '0').substring(2)}'; // Use node color

      String nodeShape;

      switch (node.type) {
        case NodeType.rectangular:
          nodeShape =
              '<rect x="$x" y="$y" width="$w" height="$h" rx="8" ry="8" stroke="black" stroke-width="1" fill="$fill"/>';
          break;
        case NodeType.diamond:
          final centerX = x + w / 2;
          final centerY = y + h / 2;
          final points =
              '$centerX,$y ${x + w},$centerY $centerX,${y + h} $x,$centerY';
          nodeShape =
              '<polygon points="$points" stroke="black" stroke-width="1" fill="$fill"/>';
          break;
        case NodeType.parallelogram:
          final offset = 20.0;
          final points =
              '${x + offset},$y ${x + w},$y ${x + w - offset},${y + h} $x,${y + h}';
          nodeShape =
              '<polygon points="$points" stroke="black" stroke-width="1" fill="$fill"/>';
          break;
        case NodeType.database:
          nodeShape = '''
        <ellipse cx="${x + w / 2}" cy="$y" rx="${w / 2}" ry="${h * 0.2}" stroke="black" stroke-width="1" fill="$fill"/>
        <rect x="$x" y="$y" width="$w" height="${h * 0.8}" stroke="black" stroke-width="1" fill="$fill"/>
        <ellipse cx="${x + w / 2}" cy="${y + h * 0.8}" rx="${w / 2}" ry="${h * 0.2}" stroke="black" stroke-width="1" fill="$fill"/>
        ''';
          break;
      }

      svg += nodeShape;
      svg +=
          '<text x="${x + w / 2}" y="${y + h / 2}" font-family="Arial" font-size="14" text-anchor="middle" dominant-baseline="middle" fill="black">${_escapeXml(text)}</text>';
    }

    for (var connection in flowManager.connections) {
      final sourceNode = nodeList[connection.sourceNodeId]!;
      final targetNode = nodeList[connection.targetNodeId]!;
      final sourcePoint =
          _getConnectionPointCoordinates(sourceNode, connection.sourcePoint);
      final targetPoint =
          _getConnectionPointCoordinates(targetNode, connection.targetPoint);
      svg +=
          '<path d="M${sourcePoint.dx},${sourcePoint.dy} C${sourcePoint.dx + 50},${sourcePoint.dy} ${targetPoint.dx - 50},${targetPoint.dy} ${targetPoint.dx},${targetPoint.dy}" stroke="black" stroke-width="2" fill="none" marker-end="url(#arrowhead)"/>';
    }

    svg += '''
  <defs>
    <marker id="arrowhead" markerWidth="10" markerHeight="7" refX="9" refY="3.5" orient="auto">
      <polygon points="0 0, 10 3.5, 0 7" fill="black"/>
    </marker>
  </defs>
  ''';

    svg += '</svg>';

    return svg;
  }

  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

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

    if (_nodeList.containsKey(connection.sourceNodeId)) {
      _nodeList[connection.sourceNodeId]!.removeConnection(connection);
    }
    if (_nodeList.containsKey(connection.targetNodeId)) {
      _nodeList[connection.targetNodeId]!.removeConnection(connection);
    }

    flowManager.connections.remove(connection);
    updateFlowManager();
    notifyListeners();
  }

  void changeNodeType(NodeType type, String nodeId) {
    _nodeList[nodeId]?.type = type;
    flowManager.nodes[nodeId]?.type = type;
    updateFlowManager();
    _saveStateForUndo();
    notifyListeners();
  }

  void changeNodeColour(Color newColour, String nodeId) {
    if (_nodeList.containsKey(nodeId)) {
      _nodeList[nodeId]?.colour = newColour;
      flowManager.nodes[nodeId]?.colour = newColour;
      updateFlowManager();
      _saveStateForUndo();
      notifyListeners();
    }
  }

  NodeType getNodeTypeFromIcon(IconData nodeIcon) {
    NodeType nodeType = NodeType.rectangular;

    switch (nodeIcon) {
      case PhosphorIconsRegular.square:
        nodeType = NodeType.rectangular;
        break;
      case PhosphorIconsRegular.diamond:
        nodeType = NodeType.diamond;
        break;
      case PhosphorIconsRegular.database:
        nodeType = NodeType.database;
        break;
      case PhosphorIconsRegular.parallelogram:
        nodeType = NodeType.parallelogram;
        break;
    }

    return nodeType;
  }

  IconData getNodeIcon(NodeType node) {
    IconData nodeIcon = PhosphorIconsRegular.square;
    switch (node) {
      case NodeType.rectangular:
        nodeIcon = PhosphorIconsRegular.square;
        break;
      case NodeType.diamond:
        nodeIcon = PhosphorIconsRegular.diamond;
        break;
      case NodeType.database:
        nodeIcon = PhosphorIconsRegular.database;
        break;
      case NodeType.parallelogram:
        nodeIcon = PhosphorIconsRegular.parallelogram;
        break;
    }

    return nodeIcon;
  }

  Color get selectedColor =>
      selectedNode == null ? nodeColors[0] : selectedNode!.colour;
  set selectedColor(Color col) {
    changeNodeColour(col, selectedNode!.id);
    notifyListeners();
  }

  void selectColor(Color color) {
    selectedColor = color;
  }

  IconData selectedNodeIcon = PhosphorIconsRegular.square;

  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  bool isStrikethrough = false;

  void selectNode(IconData node) {
    selectedNodeIcon = node;
    NodeType type = getNodeTypeFromIcon(node);
    String nodeId = selectedNode!.id;
    changeNodeType(type, nodeId);
    notifyListeners();
  }

  void toggleBold() {
    if (selectedNode != null) {
      selectedNode!.isBold = !selectedNode!.isBold;
      updateFlowManager();
      saveChanges();
    }
    isBold = !isBold;
    notifyListeners();
  }

  void toggleItalic() {
    if (selectedNode != null) {
      selectedNode!.isItalic = !selectedNode!.isItalic;
      updateFlowManager();
      saveChanges();
    }
    isItalic = !isItalic;
    notifyListeners();
  }

  void toggleUnderline() {
    if (selectedNode != null) {
      selectedNode!.isUnderlined = !selectedNode!.isUnderlined;
      updateFlowManager();
      saveChanges();
    }
    isUnderline = !isUnderline;
    notifyListeners();
  }

  void toggleStrikethrough() {
    if (selectedNode != null) {
      selectedNode!.isStrikeThrough = !selectedNode!.isStrikeThrough;
      updateFlowManager();
      saveChanges();
    }
    isStrikethrough = !isStrikethrough;
    notifyListeners();
  }

  void showLinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Insert Link"),
          content: TextField(
            decoration: InputDecoration(
              hintText: "Type or paste URL",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text("Insert"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}
