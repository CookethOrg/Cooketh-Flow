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
  // bool _isPanning = false;

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

    // Get the screen size
    final screenSize = MediaQuery.of(context).size;

    // Calculate the initial offset to center the view
    // Canvas size is 100000x100000, so center is (50000, 50000)
    // Adjust the offset to center it relative to the screen size
    final double centerX = 50000.0 - (screenSize.width / 2);
    final double centerY = 50000.0 - (screenSize.height / 2);

    // Set the initial transformation matrix to center the view
    Matrix4 matrix = Matrix4.identity()
      ..translate(-centerX,
          -centerY); // Negative because we move the canvas opposite to center it

    _transformationController.value = matrix;

    // Sync initial state with provider
    workspaceProvider.updatePosition(Offset(-centerX, -centerY));
    workspaceProvider.updateScale(1.0); // Default scale
    workspaceProvider.updateFlowManager();

    setState(() {
      _isInitialized = true;
    });
  }

  void _updateTransformationMatrix() {
    final workspaceProvider =
        Provider.of<WorkspaceProvider>(context, listen: false);

    // Create a new matrix based on the current scale and offset
    Matrix4 matrix = Matrix4.identity()
      ..translate(workspaceProvider.position.dx, workspaceProvider.position.dy)
      ..scale(workspaceProvider.scale);

    _transformationController.value = matrix;
  }

  // Connect the transformation controller to the workspace provider
  void _syncWithProvider() {
    final workspaceProvider =
        Provider.of<WorkspaceProvider>(context, listen: false);

    // Extract matrix values
    final Matrix4 matrix = _transformationController.value;

    // Extract scale (using proper mathematical approach to extract scale)
    final double scaleX = math.sqrt(
        matrix.getColumn(0)[0] * matrix.getColumn(0)[0] +
            matrix.getColumn(0)[1] * matrix.getColumn(0)[1]);

    // Extract translation
    final Offset offset =
        Offset(matrix.getTranslation().x, matrix.getTranslation().y);

    // Update provider values
    workspaceProvider.updateScale(scaleX);
    workspaceProvider.updatePosition(offset);

    // Update flow manager to persist zoom/pan state
    workspaceProvider.updateFlowManager();
  }

  bool _isHorizontal(ConnectionPoint point) {
    return point == ConnectionPoint.left || point == ConnectionPoint.right;
  }

  bool _isVertical(ConnectionPoint point) {
    return point == ConnectionPoint.top || point == ConnectionPoint.bottom;
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
      hoverColor: Colors.orange.withOpacity(0.1),
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

        // bool _isPanning = workProvider.isPanning;
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
                      hoverColor: Colors.red.withOpacity(0.1),
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
                        overlayColor: Colors.orange.withOpacity(0.1),
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
                // The infinite canvas
                InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.1, // Allow zoom out to 10%
                  maxScale: 5.0,
                  constrained:
                      false, // This is critical - don't constrain the canvas
                  boundaryMargin:
                      EdgeInsets.all(double.infinity), // Allow infinite panning
                  onInteractionStart: (details) {
                    workProvider.updatePanning(true);
                  },
                  onInteractionUpdate: (details) {
                    // Update provider with current scale and position for node dragging calculations
                    final Matrix4 matrix = _transformationController.value;

                    // Extract scale from the transformation matrix
                    final scaleX = math.sqrt(
                        matrix.getColumn(0)[0] * matrix.getColumn(0)[0] +
                            matrix.getColumn(0)[1] * matrix.getColumn(0)[1]);

                    final translation = Offset(
                        matrix.getTranslation().x, matrix.getTranslation().y);

                    workProvider.updateScale(scaleX);
                    workProvider.updatePosition(translation);
                  },
                  onInteractionEnd: (details) {
                    // Sync final state with provider
                    _syncWithProvider();
                    workProvider.updatePanning(false);
                  },
                  child: SizedBox(
                    // Huge size for effectively infinite canvas
                    width: 100000,
                    height: 100000,
                    child: Stack(
                      children: [
                        // Background grid for better visual orientation
                        Positioned.fill(
                          child: CustomPaint(
                            painter: GridPainter(),
                          ),
                        ),

                        // Center point indicator
                        // Positioned(
                        //   left: 10000,
                        //   top: 10000,
                        //   child: Container(
                        //     width: 10,
                        //     height: 10,
                        //     decoration: BoxDecoration(
                        //       color: Colors.red.withOpacity(0.5),
                        //       shape: BoxShape.circle,
                        //     ),
                        //   ),
                        // ),

                        // Draw connections
                        ...workProvider.connections.map((connection) {
                          return CustomPaint(
                            size: Size.infinite,
                            painter: LinePainter(
                              start: workProvider
                                  .nodeList[connection.sourceNodeId]!.position,
                              end: workProvider
                                  .nodeList[connection.targetNodeId]!.position,
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
                          return Node(
                            id: id,
                            type: node.type,
                            onResize: (Size newSize) =>
                                workProvider.onResize(id, newSize),
                            onDrag: (offset) =>
                                workProvider.dragNode(id, offset),
                            position: node.position,
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                // UI elements that should stay fixed regardless of zoom/pan
                FloatingDrawer(flowId: widget.flowId),

                // Toolbar and node editing tools
                Positioned(
                  top: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Toolbar(
                        onDelete: workProvider.removeSelectedNodes,
                        onUndo: workProvider.undo,
                        onRedo: workProvider.redo,
                      ),
                      SizedBox(height: 16),
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

                // Zoom indicator
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
                    child: Builder(builder: (context) {
                      // Get the current matrix
                      final matrix = _transformationController.value;

                      // Extract the scale value accurately
                      final scale = math.sqrt(
                          matrix.getColumn(0)[0] * matrix.getColumn(0)[0] +
                              matrix.getColumn(0)[1] * matrix.getColumn(0)[1]);

                      // Display accurate percentage
                      return Text(
                        "${(scale * 100).toInt()}%",
                        style: TextStyle(
                          fontFamily: 'Frederik',
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
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

// Grid painter to add visual orientation to the canvas
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      // ..color = Colors.red
      ..strokeWidth = 1;

    // Draw grid lines every 100 pixels
    const spacing = 100.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
