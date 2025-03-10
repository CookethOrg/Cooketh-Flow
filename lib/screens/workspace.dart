import 'package:cookethflow/core/widgets/drawers/project_page_drawer.dart';
import 'package:cookethflow/core/widgets/line_painter.dart';
import 'package:cookethflow/core/widgets/nodes/node.dart';
import 'package:cookethflow/core/widgets/toolbar.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:cookethflow/core/widgets/toolbox/toolbox.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class Workspace extends StatefulWidget {
  final String flowId;
  const Workspace({super.key, required this.flowId});

  @override
  State<Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWorkspace();
    });
  }

  void _initializeWorkspace() {
    final workspaceProvider =
        Provider.of<WorkspaceProvider>(context, listen: false);

    // Check if we need to initialize or if the workspace is already set to this flow
    if (workspaceProvider.currentFlowId != widget.flowId) {
      workspaceProvider.initializeWorkspace(widget.flowId);
    }

    setState(() {
      _isInitialized = true;
    });
  }

  void _showExportOptions(BuildContext context, WorkspaceProvider workProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Export Workspace',
            style: TextStyle(fontFamily: 'Frederik', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildExportOption(
                context: context,
                icon: PhosphorIconsRegular.fileCode,
                label: 'Export as JSON',
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await workProvider.exportWorkspace(exportType: ExportType.json);
                    _showSuccessSnackbar('JSON file exported successfully!');
                  } catch (e) {
                    _showErrorSnackbar('Error exporting JSON: ${e.toString()}');
                  }
                },
              ),
              SizedBox(height: 8),
              _buildExportOption(
                context: context,
                icon: PhosphorIconsRegular.fileImage,
                label: 'Export as PNG',
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await workProvider.exportWorkspace(exportType: ExportType.png);
                    _showSuccessSnackbar('PNG file exported successfully!');
                  } catch (e) {
                    _showErrorSnackbar('Error exporting PNG: ${e.toString()}');
                  }
                },
              ),
              SizedBox(height: 8),
              _buildExportOption(
                context: context,
                icon: PhosphorIconsRegular.fileSvg,
                label: 'Export as SVG',
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await workProvider.exportWorkspace(exportType: ExportType.svg);
                    _showSuccessSnackbar('SVG file exported successfully!');
                  } catch (e) {
                    _showErrorSnackbar('Error exporting SVG: ${e.toString()}');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Frederik',
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, workProvider, child) {
        if (!_isInitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(workProvider.flowManager.flowName),
            actions: [
              ElevatedButton.icon(
                onPressed: () => _showExportOptions(context, workProvider),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  side: BorderSide(color: Colors.black, width: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: PhosphorIcon(
                  PhosphorIcons.export(),
                  color: Colors.black,
                ),
                label: Text(
                  'Export Workspace',
                  style: TextStyle(
                    fontFamily: 'Frederik',
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              SizedBox(width: 30),
            ],
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: RepaintBoundary(
            key: workProvider.repaintBoundaryKey,
            child: GestureDetector(
              onTapDown: (details) {
                bool hitNode = false;
                for (var node in workProvider.nodeList.values) {
                  if (node.bounds.contains(details.globalPosition)) {
                    hitNode = true;
                    break;
                  }
                }
                if (!hitNode) {
                  for (var node in workProvider.nodeList.values) {
                    if (node.isSelected) {
                      workProvider.changeSelected(node.id);
                    }
                  }
                }
              },
              child: Stack(
                children: [
                  // Lines & Nodes
                  Stack(
                    children: [
                      for (var i = 0; i < workProvider.connections.length; i++)
                        CustomPaint(
                          size: Size.infinite,
                          painter: LinePainter(
                            start: workProvider
                                .nodeList[
                                    workProvider.connections[i].sourceNodeId]!
                                .position,
                            end: workProvider
                                .nodeList[
                                    workProvider.connections[i].targetNodeId]!
                                .position,
                            sourceNodeId:
                                workProvider.connections[i].sourceNodeId,
                            startPoint: workProvider.connections[i].sourcePoint,
                            targetNodeId:
                                workProvider.connections[i].targetNodeId,
                            endPoint: workProvider.connections[i].targetPoint,
                          ),
                        ),
                      ...workProvider.nodeList.entries.map((entry) {
                        var str = entry.key;
                        var node = entry.value;
                        return Positioned(
                          left: node.position.dx,
                          top: node.position.dy,
                          child: Node(
                            id: str,
                            type: node.type,
                            onResize: (Size newSize) =>
                                workProvider.onResize(str, newSize),
                            onDrag: (offset) =>
                                workProvider.dragNode(str, offset),
                            position: node.position,
                          ),
                        );
                      }),
                    ],
                  ),
                  FloatingDrawer(flowId: widget.flowId),
                  Toolbar(
                    onDelete: workProvider.removeSelectedNodes,
                    onUndo: workProvider.undo,
                    onRedo: workProvider.redo,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}