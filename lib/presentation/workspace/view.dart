import 'package:cookethflow/app/theme/colors.dart';
import 'package:cookethflow/utilities/ui_helper.dart';
import 'package:cookethflow/presentation/core/alert_dialogues/delete_workspace.dart';
import 'package:cookethflow/presentation/core/alert_dialogues/export_options.dart';
import 'package:cookethflow/presentation/core/drawers/project_page_drawer.dart';
import 'package:cookethflow/presentation/core/painters/grid_painter.dart';
import 'package:cookethflow/presentation/core/painters/line_painter.dart';
import 'package:cookethflow/presentation/core/nodes/node.dart';
import 'package:cookethflow/presentation/core/toolbox/toolbar.dart';
import 'package:cookethflow/presentation/workspace/view_model.dart';
import 'package:cookethflow/app/providers/workspace_provider.dart';
import 'package:cookethflow/presentation/core/toolbox/toolbox.dart';
import 'package:cookethflow/utilities/enums/app_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

class WorkspaceView extends StatefulWidget {
  final String flowId;
  final WorkspaceViewModel viewModel;
  const WorkspaceView(
      {super.key, required this.flowId, required this.viewModel});

  @override
  State<WorkspaceView> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<WorkspaceView> {
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
    final double centerX = (canvasDimension / 2) - (screenSize.width / 2);
    final double centerY = (canvasDimension / 2) - (screenSize.height / 2);

    // Set the initial transformation matrix to center the view
    Matrix4 matrix = Matrix4.identity()..translate(-centerX, -centerY);

    workspaceProvider.transformationController.value = matrix;

    // Sync initial state with provider
    workspaceProvider.updatePosition(Offset(-centerX, -centerY));
    workspaceProvider.updateScale(1.0);
    workspaceProvider.updateFlowManager();

    workspaceProvider.setInitialize(true);
  }

  void _syncWithProvider() {
    final workspaceProvider =
        Provider.of<WorkspaceProvider>(context, listen: false);

    final Matrix4 matrix = workspaceProvider.transformationController.value;

    final double scaleX = math.sqrt(
        matrix.getColumn(0)[0] * matrix.getColumn(0)[0] +
            matrix.getColumn(0)[1] * matrix.getColumn(0)[1]);

    final Offset offset =
        Offset(matrix.getTranslation().x, matrix.getTranslation().y);

    workspaceProvider.updateScale(scaleX);
    workspaceProvider.updatePosition(offset);
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

        return Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: textColor,
                    width: 1.0,
                  ),
                ),
              ),
              child: AppBar(
                backgroundColor: transparent,
                elevation: 0,
                toolbarHeight: 80,
                centerTitle: true,
                title: Text(
                  workProvider.flowManager.flowName,
                  style: const TextStyle(
                    fontFamily: 'Frederik',
                    color: textColor,
                    fontSize: 20,
                  ),
                ),
                leading: Container(
                  alignment: Alignment.center,
                  child: IconButton(
                    padding: const EdgeInsets.only(left: 16.0),
                    icon: const Icon(Icons.arrow_back, color: textColor),
                    onPressed: () =>
                        context.pushReplacement(AppView.dashboard.path),
                  ),
                ),
                actions: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 8.0),
                    child: IconButton(
                      hoverColor: deleteButtons.withOpacity(0.1),
                      icon: Icon(PhosphorIconsRegular.trash,
                          color: deleteButtons),
                      tooltip: 'Delete WorkspaceView',
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) =>
                            DeleteWorkspace(flowId: widget.flowId),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => ExportOptions(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: white,
                        elevation: 0,
                        overlayColor: mainOrange.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 18),
                        side: const BorderSide(color: textColor, width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadowColor: transparent,
                      ),
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: PhosphorIcon(
                          PhosphorIcons.export(),
                          color: textColor,
                          size: 20,
                        ),
                      ),
                      label: Text(
                        'Export WorkspaceView',
                        style: const TextStyle(
                          fontFamily: 'Frederik',
                          fontSize: 16,
                          color: textColor,
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
          backgroundColor: white,
          body: Stack(
            children: [
              RepaintBoundary(
                key: workProvider.repaintBoundaryKey,
                child: InteractiveViewer(
                  transformationController:
                      workProvider.transformationController,
                  minScale: 0.1,
                  maxScale: 5.0,
                  constrained: false,
                  boundaryMargin: EdgeInsets.all(double.infinity),
                  onInteractionStart: (details) {
                    workProvider.updatePanning(true);
                  },
                  onInteractionUpdate: (details) {
                    final Matrix4 matrix =
                        workProvider.transformationController.value;

                    final scaleX = math.sqrt(
                        matrix.getColumn(0)[0] * matrix.getColumn(0)[0] +
                            matrix.getColumn(0)[1] * matrix.getColumn(0)[1]);

                    final translation = Offset(
                        matrix.getTranslation().x, matrix.getTranslation().y);

                    workProvider.updateScale(scaleX);
                    workProvider.updatePosition(translation);
                  },
                  onInteractionEnd: (details) {
                    _syncWithProvider();
                    workProvider.updatePanning(false);
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      workProvider.deselectAllNodes();
                    },
                    child: SizedBox(
                      width: canvasDimension,
                      height: canvasDimension,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: GridPainter(),
                            ),
                          ),
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
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              FloatingDrawer(flowId: widget.flowId),
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
              Positioned(
                right: 24,
                bottom: 24,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: textColor, width: 1),
                  ),
                  child: Builder(builder: (context) {
                    final matrix = workProvider.transformationController.value;
                    final scale = math.sqrt(
                        matrix.getColumn(0)[0] * matrix.getColumn(0)[0] +
                            matrix.getColumn(0)[1] * matrix.getColumn(0)[1]);
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
