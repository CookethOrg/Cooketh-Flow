import 'package:cookethflow/core/widgets/drawers/project_page_drawer.dart';
import 'package:cookethflow/core/widgets/line_painter.dart';
import 'package:cookethflow/core/widgets/nodes/node.dart';
import 'package:cookethflow/core/widgets/toolbar.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:cookethflow/core/widgets/toolbox/toolbox.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Workspace extends StatefulWidget {
  final String flowId;
  const Workspace({Key? key, required this.flowId}) : super(key: key);

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
    final workspaceProvider = Provider.of<WorkspaceProvider>(context, listen: false);
    
    // Check if we need to initialize or if the workspace is already set to this flow
    if (workspaceProvider.currentFlowId != widget.flowId) {
      workspaceProvider.initializeWorkspace(widget.flowId);
    }
    
    setState(() {
      _isInitialized = true;
    });
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
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: GestureDetector(
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
                              .nodeList[workProvider.connections[i].sourceNodeId]!
                              .position,
                          end: workProvider
                              .nodeList[workProvider.connections[i].targetNodeId]!
                              .position,
                          sourceNodeId: workProvider.connections[i].sourceNodeId,
                          startPoint: workProvider.connections[i].sourcePoint,
                          targetNodeId: workProvider.connections[i].targetNodeId,
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
                          onResize: (Size newSize) => workProvider.onResize(str, newSize),
                          onDrag: (offset) => workProvider.dragNode(str, offset),
                          position: node.position,
                        ),
                      );
                    }).toList(), // Ensure the list is a valid `List<Widget>`
                  ],
                ),
                FloatingDrawer(flowId: widget.flowId), // Left-side floating drawer
                Toolbar(
                  onDelete: workProvider.removeSelectedNodes,
                  onUndo: workProvider.undo,
                  onRedo: workProvider.redo,
                ),
                // if (workProvider.displayToolbox()) CustomToolbar(),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => workProvider.addNode(),
            child: const Icon(Icons.add),
            tooltip: 'Add Node',
          ),
        );
      },
    );
  }
}