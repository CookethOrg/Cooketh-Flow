import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/models/canvas_models/canvas_painter.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

class CanvasPage extends StatelessWidget {
  const CanvasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkspaceProvider, CanvasProvider>(
      builder: (context, workspaceProvider, canvasProvider, child) {
        final isHandToolActive = workspaceProvider.currentMode == DrawMode.hand;

        return Scaffold(
          backgroundColor: workspaceProvider.currentWorkspaceColor,
          body: Listener(
            onPointerDown: (event) {
              if (event.kind == PointerDeviceKind.mouse && event.buttons == kPrimaryMouseButton && event.down) {
                 // You could implement double-click logic here if needed
              }
            },
            child: MouseRegion(
              // Change cursor based on the active tool
              cursor: isHandToolActive ? SystemMouseCursors.grab : SystemMouseCursors.basic,
              onHover: (event) {
                final Matrix4 transform = canvasProvider.transformationController.value;
                final Matrix4? inverseTransform = Matrix4.tryInvert(transform);

                if (inverseTransform == null) return;

                final vector_math.Vector3 transformed = inverseTransform.transform3(
                    vector_math.Vector3(event.localPosition.dx, event.localPosition.dy, 0));
                final Offset canvasCoordinates = Offset(transformed.x, transformed.y);

                if (workspaceProvider.interactionMode != InteractionMode.editingText) {
                  workspaceProvider.syncCanvasObject(canvasCoordinates);
                }
              },
              child: InteractiveViewer(
                transformationController: canvasProvider.transformationController,
                minScale: 0.1,
                maxScale: 4.0,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                constrained: false,
                // Enable panning only when Hand Tool is active
                panEnabled: isHandToolActive,
                scaleEnabled: workspaceProvider.interactionMode != InteractionMode.editingText,
                child: Container(
                  color: workspaceProvider.currentWorkspaceColor,
                  child: GestureDetector(
                    // Disable GestureDetector's pan events when Hand Tool is active
                    onPanDown: isHandToolActive ? null : (details) {
                        workspaceProvider.onPanDown(DragDownDetails(globalPosition: details.localPosition));
                      },
                    onPanUpdate: isHandToolActive ? null : (details) {
                        workspaceProvider.onPanUpdate(DragUpdateDetails(
                          globalPosition: details.localPosition,
                          delta: details.delta,
                        ));
                      },
                    onPanEnd: isHandToolActive ? null : workspaceProvider.onPanEnd,
                    child: CustomPaint(
                      size: const Size(20000, 20000),
                      painter: CanvasPainter(
                        userCursors: workspaceProvider.userCursors,
                        canvasObjects: workspaceProvider.canvasObjects,
                        currentlySelectedObjectId: workspaceProvider.currentlySelectedObjectId,
                        handleRadius: workspaceProvider.handleRadius,
                        interactionMode: workspaceProvider.interactionMode,
                        connectionPointRadius: workspaceProvider.connectionPointRadius,
                        connectorSourceId: workspaceProvider.connectorSourceId,
                        connectorSourceAlignment: workspaceProvider.connectorSourceAlignment,
                        connectorDragPosition: workspaceProvider.connectorDragPosition,
                      ),
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