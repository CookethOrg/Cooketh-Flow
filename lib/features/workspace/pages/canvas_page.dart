import 'package:cookethflow/features/models/canvas_models/canvas_painter.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CanvasPage extends StatelessWidget {
  const CanvasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: provider.currentWorkspaceColor,
          body: MouseRegion(
            onHover: (event) {
              provider.syncCanvasObject(event.position);
            },
            child: GestureDetector(
              onPanDown: provider.onPanDown,
              onPanUpdate: provider.onPanUpdate,
              onPanEnd: provider.onPanEnd,
              child: CustomPaint(
                size: MediaQuery.of(context).size,
                painter: CanvasPainter(
                  userCursors: provider.userCursors,
                  canvasObjects: provider.canvasObjects,
                  currentlySelectedObjectId:
                      provider.currentlySelectedObjectId,
                  handleRadius: provider.handleRadius,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
