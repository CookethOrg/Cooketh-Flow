import 'package:cookethflow/core/widgets/drawers/project_page_drawer.dart';
import 'package:cookethflow/core/widgets/line_painter.dart';
import 'package:cookethflow/core/widgets/nodes/node.dart';
import 'package:cookethflow/core/widgets/toolbar.dart';
import 'package:cookethflow/models/connection.dart';
import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/providers/flowmanage_provider.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:cookethflow/core/widgets/toolbox/toolbox.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class Workspace extends StatefulWidget {
  final String flowId;
  const Workspace({super.key, required this.flowId});

  @override
  State<Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  bool _isInitialized = false;
  TransformationController _transformationController =
      TransformationController();
  bool _isPanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWorkspace();
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _initializeWorkspace() {
    final workspaceProvider =
        Provider.of<WorkspaceProvider>(context, listen: false);

    // Check if we need to initialize or if the workspace is already set to this flow
    if (workspaceProvider.currentFlowId != widget.flowId) {
      workspaceProvider.initializeWorkspace(widget.flowId);
    }

    // set initial transform based on saved state and position
    _updateTransformFromProvider();

    setState(() {
      _isInitialized = true;
    });
  }

  // Check if a point is close to a connection line
  bool _isPointNearConnection(Offset point, Connection connection, WorkspaceProvider provider, Matrix4 matrix) {
    final scale = math.sqrt(matrix.getColumn(0)[0] * matrix.getColumn(0)[0] +
        matrix.getColumn(1)[0] * matrix.getColumn(1)[0]);
    
    final sourceNode = provider.nodeList[connection.sourceNodeId]!;
    final targetNode = provider.nodeList[connection.targetNodeId]!;
    
    // Calculate connection points in world coordinates
    final sourcePoint = _getConnectionPointCoordinates(
      sourceNode, 
      connection.sourcePoint,
      matrix
    );
    
    final targetPoint = _getConnectionPointCoordinates(
      targetNode,
      connection.targetPoint,
      matrix
    );
    
    // Calculate midpoint for orthogonal routing
    final midX = (sourcePoint.dx + targetPoint.dx) / 2;
    final midY = (sourcePoint.dy + targetPoint.dy) / 2;
    
    // Create points for orthogonal path
    List<Offset> pathPoints = [sourcePoint];
    
    // Add intermediate points based on connection points
    if (_isHorizontal(connection.sourcePoint) && _isHorizontal(connection.targetPoint)) {
      pathPoints.add(Offset(midX, sourcePoint.dy));
      pathPoints.add(Offset(midX, targetPoint.dy));
    } else if (_isVertical(connection.sourcePoint) && _isVertical(connection.targetPoint)) {
      pathPoints.add(Offset(sourcePoint.dx, midY));
      pathPoints.add(Offset(targetPoint.dx, midY));
    } else if (_isHorizontal(connection.sourcePoint) && _isVertical(connection.targetPoint)) {
      pathPoints.add(Offset(targetPoint.dx, sourcePoint.dy));
    } else if (_isVertical(connection.sourcePoint) && _isHorizontal(connection.targetPoint)) {
      pathPoints.add(Offset(sourcePoint.dx, targetPoint.dy));
    }
    
    pathPoints.add(targetPoint);
    
    // Check if point is close to any line segment of the path
    for (int i = 0; i < pathPoints.length - 1; i++) {
      if (_isPointNearLineSegment(point, pathPoints[i], pathPoints[i + 1])) {
        return true;
      }
    }
    
    return false;
  }

  bool _isHorizontal(ConnectionPoint point) {
    return point == ConnectionPoint.left || point == ConnectionPoint.right;
  }
  
  bool _isVertical(ConnectionPoint point) {
    return point == ConnectionPoint.top || point == ConnectionPoint.bottom;
  }

  // Check if a point is near a line segment
  bool _isPointNearLineSegment(Offset point, Offset lineStart, Offset lineEnd) {
    const double hitThreshold = 10.0; // Distance in pixels within which we consider a hit
    
    // Calculate squared length of the line segment
    final lengthSquared = (lineEnd - lineStart).distanceSquared;
    
    if (lengthSquared == 0) {
      // Line segment is actually a point
      return (point - lineStart).distance < hitThreshold;
    }
    
    // Calculate projection of point onto line segment
    final t = ((point.dx - lineStart.dx) * (lineEnd.dx - lineStart.dx) +
              (point.dy - lineStart.dy) * (lineEnd.dy - lineStart.dy)) / lengthSquared;
    
    if (t < 0) {
      // Point is beyond the lineStart end of the line segment
      return (point - lineStart).distance < hitThreshold;
    } else if (t > 1) {
      // Point is beyond the lineEnd end of the line segment
      return (point - lineEnd).distance < hitThreshold;
    }
    
    // Calculate the projection point
    final projection = Offset(
      lineStart.dx + t * (lineEnd.dx - lineStart.dx),
      lineStart.dy + t * (lineEnd.dy - lineStart.dy)
    );
    
    // Calculate distance from point to line
    return (point - projection).distance < hitThreshold;
  }

  // Helper to get connection point coordinates
  Offset _getConnectionPointCoordinates(FlowNode node, ConnectionPoint point, Matrix4 matrix) {
    final scale = math.sqrt(matrix.getColumn(0)[0] * matrix.getColumn(0)[0] +
        matrix.getColumn(1)[0] * matrix.getColumn(1)[0]);
    
    final dx = matrix.getTranslation().x;
    final dy = matrix.getTranslation().y;
    
    final centerX = node.position.dx * scale + dx + (node.size.width * scale / 2);
    final centerY = node.position.dy * scale + dy + (node.size.height * scale / 2);

    switch (point) {
      case ConnectionPoint.top:
        return Offset(centerX, node.position.dy * scale + dy);
      case ConnectionPoint.right:
        return Offset(node.position.dx * scale + dx + node.size.width * scale, centerY);
      case ConnectionPoint.bottom:
        return Offset(centerX, node.position.dy * scale + dy + node.size.height * scale);
      case ConnectionPoint.left:
        return Offset(node.position.dx * scale + dx, centerY);
    }
  }

  void _showConnectionContextMenu(
      BuildContext context, Connection connection, Offset position) {
    final RenderBox overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(position, position),
        Rect.fromLTWH(0, 0, overlay.size.width, overlay.size.height),
      ),
      items: [
        PopupMenuItem(
          child: Row(
            children: [
              Icon(PhosphorIconsRegular.trash, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Connection'),
            ],
          ),
          onTap: () {
            // Remove the connection
            final workspaceProvider =
                Provider.of<WorkspaceProvider>(context, listen: false);
            workspaceProvider.removeConnection(connection);
          },
        ),
      ],
    );
  }

  void _showDeleteWorkspaceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Delete Workspace',
            style:
                TextStyle(fontFamily: 'Frederik', fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this workspace? This action cannot be undone.',
            style: TextStyle(fontFamily: 'Frederik'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  final workspaceProvider =
                      Provider.of<WorkspaceProvider>(context, listen: false);
                  final flowProvider =
                      Provider.of<FlowmanageProvider>(context, listen: false);

                  await flowProvider.deleteWorkspace(widget.flowId);

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Workspace deleted successfully')));

                  Navigator.of(context).pop(); // Return to dashboard
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Error deleting workspace: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _updateTransformFromProvider() {
    final workspaceProvider =
        Provider.of<WorkspaceProvider>(context, listen: false);

    // Create a matrix from the saved scale and position
    Matrix4 matrix = Matrix4.identity()
      ..translate(workspaceProvider.position.dx, workspaceProvider.position.dy)
      ..scale(workspaceProvider.scale);

    _transformationController.value = matrix;
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    final workspaceProvider =
        Provider.of<WorkspaceProvider>(context, listen: false);

    // Get the current transformation matrix
    final matrix = _transformationController.value;

    // Extract scale from matrix (using the proper mathematical approach)
    final scaleX = math.sqrt(matrix.getColumn(0)[0] * matrix.getColumn(0)[0] +
        matrix.getColumn(1)[0] * matrix.getColumn(1)[0]);

    // Extract translation from matrix
    final dx = matrix.getTranslation().x;
    final dy = matrix.getTranslation().y;

    // Update provider with scale and position
    workspaceProvider.updateScale(scaleX);
    workspaceProvider.updatePosition(Offset(dx, dy));
  }

  void _showExportOptions(
      BuildContext context, WorkspaceProvider workProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(
            'Export Workspace',
            style:
                TextStyle(fontFamily: 'Frederik', fontWeight: FontWeight.bold),
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
                    await workProvider.exportWorkspace(
                        exportType: ExportType.json);
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
                    await workProvider.exportWorkspace(
                        exportType: ExportType.png);
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
                    await workProvider.exportWorkspace(
                        exportType: ExportType.svg);
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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 1.0,
                  ),
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                toolbarHeight: 80,
                centerTitle: true,
                title: Text(
                  workProvider.flowManager.flowName,
                  style: const TextStyle(
                    fontFamily: 'Frederik',
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                leading: Container(
                  alignment: Alignment.center,
                  child: IconButton(
                    padding: const EdgeInsets.only(left: 16.0),
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                actions: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    child: IconButton(
                      icon: Icon(PhosphorIconsRegular.trash, color: Colors.red),
                      tooltip: 'Delete Workspace',
                      onPressed: () => _showDeleteWorkspaceDialog(context),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showExportOptions(context, workProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 18),
                        side: const BorderSide(color: Colors.black, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: Colors.transparent,
                      ),
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: PhosphorIcon(
                          PhosphorIcons.export(),
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                      label: Text(
                        'Export Workspace',
                        style: const TextStyle(
                          fontFamily: 'Frederik',
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: RepaintBoundary(
            key: workProvider.repaintBoundaryKey,
            child: Stack(
              children: [
                // Use InteractiveViewer for zoom and pan
                InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.1,
                  maxScale: 5.0,
                  onInteractionEnd: (details) {
                    _onInteractionUpdate(ScaleUpdateDetails());
                    _isPanning = false;
                  },
                  onInteractionStart: (details) {
                    _isPanning = details.pointerCount > 0;
                  },
                  child: GestureDetector(
                    onTapDown: (details) {
                      if (_isPanning) return;

                      // First check if the click is on a connection
                      bool hitConnection = false;
                      Connection? hitConnectionObj;
                      
                      for (var connection in workProvider.connections) {
                        if (_isPointNearConnection(
                          details.globalPosition, 
                          connection, 
                          workProvider,
                          _transformationController.value
                        )) {
                          hitConnection = true;
                          hitConnectionObj = connection;
                          break;
                        }
                      }
                      
                      if (hitConnection && hitConnectionObj != null) {
                        _showConnectionContextMenu(
                          context, 
                          hitConnectionObj, 
                          details.globalPosition
                        );
                        return;
                      }

                      // If not a connection, check if it's a node
                      bool hitNode = false;
                      for (var node in workProvider.nodeList.values) {
                        // Get transformed bounds
                        final matrix = _transformationController.value;
                        final scale = math.sqrt(matrix.getColumn(0)[0] *
                                matrix.getColumn(0)[0] +
                            matrix.getColumn(0)[1] * matrix.getColumn(0)[1]);

                        final transformedBounds = Rect.fromLTWH(
                          node.position.dx * scale + matrix.getTranslation().x,
                          node.position.dy * scale + matrix.getTranslation().y,
                          node.size.width * scale,
                          node.size.height * scale,
                        );

                        if (transformedBounds
                            .contains(details.globalPosition)) {
                          hitNode = true;
                          break;
                        }
                      }

                      if (!hitNode) {
                        // Click on empty space deselects all nodes
                        for (var node in workProvider.nodeList.values) {
                          if (node.isSelected) {
                            workProvider.changeSelected(node.id);
                          }
                        }
                      }
                    },
                    child: Container(
                      // Very large size to allow for "infinite" panning
                      width: 10000,
                      height: 10000,
                      color: Colors.white,
                      child: Stack(
                        children: [
                          // Center point indicator
                          Positioned(
                            left: 5000,
                            top: 5000,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // Draw connections
                          ...workProvider.connections.map((connection) {
                            return CustomPaint(
                              size: Size.infinite,
                              painter: LinePainter(
                                start: workProvider
                                    .nodeList[connection.sourceNodeId]!
                                    .position,
                                end: workProvider
                                    .nodeList[connection.targetNodeId]!
                                    .position,
                                sourceNodeId: connection.sourceNodeId,
                                startPoint: connection.sourcePoint,
                                targetNodeId: connection.targetNodeId,
                                endPoint: connection.targetPoint,
                                scale: workProvider.scale,
                                connection: connection,
                              ),
                            );
                          }),
                          
                          // Draw nodes
                          ...workProvider.nodeList.entries.map((entry) {
                            var id = entry.key;
                            var node = entry.value;
                            return Positioned(
                              left: node.position.dx,
                              top: node.position.dy,
                              child: Node(
                                id: id,
                                type: node.type,
                                onResize: (Size newSize) =>
                                    workProvider.onResize(id, newSize),
                                onDrag: (offset) =>
                                    workProvider.dragNode(id, offset),
                                position: node.position,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                // UI elements that should stay fixed regardless of zoom/pan
                FloatingDrawer(flowId: widget.flowId),
                // Replace the existing Toolbar and CustomToolbar sections in your Stack with:
                Positioned(
                  top: 20, // Add some spacing from the app bar
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Toolbar(
                        onDelete: workProvider.removeSelectedNodes,
                        onUndo: workProvider.undo,
                        onRedo: workProvider.redo,
                      ),
                      SizedBox(height: 16), // Add spacing between the toolbars
                      Opacity(
                        opacity: workProvider.hasSelectedNode ? 1.0 : 0.5,
                        child: IgnorePointer(
                          ignoring: !workProvider.hasSelectedNode,
                          child: CustomToolbar(),
                        ),
                      ),
                    ],
                  ),
                ),
                // Add zoom indicator
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Text(
                      "${(workProvider.scale * 100).toInt()}%",
                      style: TextStyle(
                        fontFamily: 'Frederik',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}