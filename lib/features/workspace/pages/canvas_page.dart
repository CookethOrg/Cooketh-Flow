import 'package:cookethflow/core/utils/enums.dart';
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
          body: MouseRegion(
            onHover: (event) {
              provider.syncCanvasObject(event.position);
            },
            child: Stack(
              children: [
                GestureDetector(
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
                // Positioned(
                //   top: 500,
                //   left: 0,
                //   child: Row(
                //     children:
                //         DrawMode.values
                //             .map(
                //               (mode) => IconButton(
                //                 iconSize: 48,
                //                 onPressed: () {
                //                   provider.changeDrawMode(mode);
                //                 },
                //                 icon: Icon(mode.iconData),
                //                 color:
                //                     provider.currentMode == mode ? Colors.green : null,
                //               ),
                //             )
                //             .toList(),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
