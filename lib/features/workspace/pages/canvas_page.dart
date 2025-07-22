import 'package:cookethflow/features/models/canvas_models/canvas_painter.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math; // Required for Vector3.

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
              // Mouse hover position is directly event.localPosition relative to MouseRegion.
              // InteractiveViewer's transform is applied implicitly by its child's position.
              // We need to apply the inverse of the current transformation to get canvas coordinates.
              final Matrix4 transform = canvasProvider.transformationController.value;
              final Matrix4? inverseTransform = Matrix4.tryInvert(transform);

              if (inverseTransform == null) {
                // This case should be rare for valid transforms.
                return;
              }

              // Transform the local position (relative to InteractiveViewer's viewport)
              // to canvas coordinates.
              final vector_math.Vector3 transformed = inverseTransform.transform3(vector_math.Vector3(event.localPosition.dx, event.localPosition.dy, 0));
              final Offset canvasCoordinates = Offset(transformed.x, transformed.y);

              workspaceProvider.syncCanvasObject(canvasCoordinates);
            },
            child: InteractiveViewer(
              transformationController: canvasProvider.transformationController,
              minScale: 0.1, // Minimum zoom level
              maxScale: 4.0, // Maximum zoom level
              boundaryMargin: const EdgeInsets.all(double.infinity), // Allows "infinite" panning
              constrained: false, // Important: allows content to go beyond initial bounds
              // InteractiveViewer automatically handles mouse drag for pan and scroll wheel for zoom.
              // We do NOT put onPanDown, onPanUpdate directly on InteractiveViewer as it will conflict
              // with the child GestureDetector for object manipulation.
              // We let InteractiveViewer manage its own pan/zoom gestures.
              // The GestureDetector below will handle *object* interactions.
              child: Container(
                color: Colors.grey[200],
                child: GestureDetector(
                  // Use onTapDown for adding new nodes when not in pointer mode,
                  // and for initiating object selection/move/resize.
                  onPanDown: (details) {
                    // details.localPosition is already relative to the GestureDetector's parent (InteractiveViewer's child).
                    // This means it's already in the canvas coordinate system!
                    workspaceProvider.onPanDown(DragDownDetails(globalPosition: details.localPosition));
                  },
                  onPanUpdate: (details) {
                    // details.localPosition and details.delta are already in canvas coordinates.
                    workspaceProvider.onPanUpdate(DragUpdateDetails(
                      globalPosition: details.localPosition,
                      delta: details.delta,
                    ));
                  },
                  onPanEnd: workspaceProvider.onPanEnd,
                  child: CustomPaint(
                    // Set a large, arbitrary size for the CustomPaint.
                    // The actual drawing will occur based on the canvas coordinates of your objects.
                    // InteractiveViewer will handle the viewport.
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