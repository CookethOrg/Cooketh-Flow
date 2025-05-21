import 'package:cookethflow/core/utils/ui_helper.dart';
import 'package:cookethflow/core/widgets/alert_dialogues/delete_workspace.dart';
import 'package:cookethflow/core/widgets/alert_dialogues/export_options.dart';
import 'package:cookethflow/core/widgets/drawers/project_page_drawer.dart';
import 'package:cookethflow/core/widgets/painters/grid_painter.dart';
import 'package:cookethflow/core/widgets/painters/line_painter.dart';
import 'package:cookethflow/core/widgets/nodes/node.dart';
import 'package:cookethflow/core/widgets/toolbox/toolbar.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:cookethflow/core/widgets/toolbox/toolbox.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cookethflow/core/routes/app_route_const.dart';
import 'dart:math' as math;

class Workspace extends StatefulWidget {
  final String flowId;
  const Workspace({super.key, required this.flowId});

  @override
  State<Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<Workspace> {
  // bool _isPanning = false;

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

    // Get the screen size
    final screenSize = MediaQuery.of(context).size;

    // Calculate the initial offset to center the view
    // Canvas size is 100000x100000, so center is (50000, 50000)
    // Adjust the offset to center it relative to the screen size
    final double centerX = (canvasDimension / 2) - (screenSize.width / 2);
    final double centerY = (canvasDimension / 2) - (screenSize.height / 2);

    // Set the initial transformation matrix to center the view
    Matrix4 matrix = Matrix4.identity()
      ..translate(-centerX,
          -centerY); // Negative because we move the canvas opposite to center it

    workspaceProvider.transformationController.value = matrix;

    // Sync initial state with provider
    workspaceProvider.updatePosition(Offset(-centerX, -centerY));
    workspaceProvider.updateScale(1.0); // Default scale
    workspaceProvider.updateFlowManager();

    workspaceProvider.setInitialize(true);
  }

  // Connect the transformation controller to the workspace provider
  void _syncWithProvider() {
    final workspaceProvider =
        Provider.of<WorkspaceProvider>(context, listen: false);

    // Extract matrix values
    final Matrix4 matrix = workspaceProvider.transformationController.value;

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

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, workProvider, child) {
        if (!workProvider.isInitialized) {
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
                    onPressed: () => context.push(RoutesPath.dashboard),
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
                      onPressed: () => showDialog(context: context, builder: (context) => DeleteWorkspace(flowId: widget.flowId),),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          showDialog(context: context, builder: (context) => ExportOptions(),),
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
          body: Stack(
              children: [
                // The infinite canvas
                RepaintBoundary(
                  key: workProvider.repaintBoundaryKey,
                  child: InteractiveViewer(
                    transformationController:
                        workProvider.transformationController,
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
                      final Matrix4 matrix =
                          workProvider.transformationController.value;
                  
                      // Extract scale from the transformation matrixF
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
                      width: canvasDimension,
                      height: canvasDimension,
                      child: Stack(
                        children: [
                          // Background grid for better visual orientation
                          Positioned.fill(
                            child: CustomPaint(
                              painter: GridPainter(),
                            ),
                          ),
                  
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
                                // position: node.position,
                              ),
                            );
                          }
                          ),
                        ],
                      ),
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
                      final matrix =
                          workProvider.transformationController.value;

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
        );
      },
    );
  }
}
