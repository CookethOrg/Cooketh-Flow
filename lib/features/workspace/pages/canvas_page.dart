// lib/features/workspace/pages/canvas_page.dart

import 'package:cookethflow/features/models/canvas_models/canvas_painter.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math; // Required for Vector3.
import 'package:cookethflow/core/utils/enums.dart'; // NEW: Import enums
import 'package:cookethflow/features/workspace/widgets/object_text_editor.dart'; // NEW: Import ObjectTextEditor

class CanvasPage extends StatelessWidget {
  const CanvasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkspaceProvider, CanvasProvider>(
      builder: (context, workspaceProvider, canvasProvider, child) {
        return Scaffold(
          backgroundColor: workspaceProvider.currentWorkspaceColor,
          body: MouseRegion(
            onHover: (event) {
              final Matrix4 transform = canvasProvider.transformationController.value;
              final Matrix4? inverseTransform = Matrix4.tryInvert(transform);

              if (inverseTransform == null) {
                return;
              }

              final vector_math.Vector3 transformed = inverseTransform.transform3(vector_math.Vector3(event.localPosition.dx, event.localPosition.dy, 0));
              final Offset canvasCoordinates = Offset(transformed.x, transformed.y);

              // NEW: Only sync cursor position if not in text editing mode to avoid flickering
              if (workspaceProvider.interactionMode != InteractionMode.editingText) {
                workspaceProvider.syncCanvasObject(canvasCoordinates);
              }
            },
            child: InteractiveViewer(
              transformationController: canvasProvider.transformationController,
              minScale: 0.1, // Minimum zoom level
              maxScale: 4.0, // Maximum zoom level
              boundaryMargin: const EdgeInsets.all(double.infinity), // Allows "infinite" panning
              constrained: false, // Important: allows content to go beyond initial bounds
              // NEW: Disable InteractiveViewer's default pan/zoom if we are actively editing text
              panEnabled: workspaceProvider.interactionMode != InteractionMode.editingText,
              scaleEnabled: workspaceProvider.interactionMode != InteractionMode.editingText,
              child: Container(
                color: Colors.grey[200],
                child: GestureDetector(
                  // NEW: Conditionally enable/disable pan/update based on interaction mode
                  onPanDown: workspaceProvider.interactionMode == InteractionMode.editingText
                      ? (details) {
                          // If in text editing mode, only allow panDown if click is outside the current object
                          // This is handled within workspaceProvider.onPanDown
                          final currentObject = workspaceProvider.canvasObjects[workspaceProvider.currentlySelectedObjectId!];
                          if (currentObject != null && !currentObject.getBounds().contains(details.localPosition)) {
                             workspaceProvider.onPanDown(DragDownDetails(globalPosition: details.localPosition));
                          }
                          // If click is inside, do nothing, let Quill handle it
                      }
                      : (details) {
                          workspaceProvider.onPanDown(DragDownDetails(globalPosition: details.localPosition));
                      },
                  onPanUpdate: workspaceProvider.interactionMode == InteractionMode.editingText
                      ? null // Disable panUpdate when editing text
                      : (details) {
                          workspaceProvider.onPanUpdate(DragUpdateDetails(
                            globalPosition: details.localPosition,
                            delta: details.delta,
                          ));
                      },
                  onPanEnd: workspaceProvider.interactionMode == InteractionMode.editingText
                      ? null // Disable panEnd when editing text
                      : workspaceProvider.onPanEnd,
                  child: CustomPaint(
                    size: const Size(20000, 20000), // Sufficiently large "infinite" canvas
                    painter: CanvasPainter(
                      userCursors: workspaceProvider.userCursors,
                      canvasObjects: workspaceProvider.canvasObjects,
                      currentlySelectedObjectId: workspaceProvider.currentlySelectedObjectId,
                      handleRadius: workspaceProvider.handleRadius,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}