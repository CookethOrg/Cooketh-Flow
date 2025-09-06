// lib/features/workspace/pages/workspace_desktop.dart (Fully Modified)
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/workspace/pages/canvas_page.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/export_project_button.dart';
import 'package:cookethflow/features/workspace/widgets/node_editing_toolbox.dart';
import 'package:cookethflow/features/workspace/widgets/toolbar.dart';
import 'package:cookethflow/features/workspace/widgets/undo_redo_button.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_drawer.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_shortcuts.dart'; // shortcut file
import 'package:cookethflow/features/workspace/widgets/zoom_control_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cookethflow/features/workspace/widgets/object_text_editor.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;

class WorkspaceDesktop extends StatefulWidget {
  const WorkspaceDesktop({super.key});

  @override
  _WorkspaceDesktopState createState() => _WorkspaceDesktopState();
}

class _WorkspaceDesktopState extends State<WorkspaceDesktop> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus when the widget is first built
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    // Clean up the focus node when the widget is disposed
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define actions
    final Map<Type, Action<Intent>> actions = {
      PointerIntent: CallbackAction<PointerIntent>(
        onInvoke: (intent) {
          final provider = Provider.of<WorkspaceProvider>(
            context,
            listen: false,
          );
          provider.changeDrawMode(DrawMode.pointer);
          return null;
        },
      ),
      PanIntent: CallbackAction<PanIntent>(
        onInvoke: (intent) {
          final provider = Provider.of<WorkspaceProvider>(
            context,
            listen: false,
          );
          provider.changeDrawMode(DrawMode.hand);
          return null;
        },
      ),
      TextIntent: CallbackAction<TextIntent>(
        onInvoke: (intent) {
          final provider = Provider.of<WorkspaceProvider>(
            context,
            listen: false,
          );
          provider.changeDrawMode(DrawMode.textBox);
          return null;
        },
      ),
    };

    return Consumer2<WorkspaceProvider, SupabaseService>(
      builder: (context, provider, suprovider, child) {
        return Shortcuts(
          shortcuts: workspaceShortCut,
          child: Actions(
            actions: actions,
            child: Focus(
              focusNode: _focusNode,
              child: Scaffold(
                backgroundColor: provider.currentWorkspaceColor,
                body: GestureDetector(
                  onTap: () {
                    // This ensures focus is regained when the user taps on the canvas
                    _focusNode.requestFocus();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.w,
                      vertical: 40.h,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const CanvasPage(),
                        const WorkspaceDrawer(),
                        SizedBox(width: 20.w),
                        Positioned(
                          top: 0,
                          left: 0.21.sw,
                          child: UndoRedoButton(su: suprovider),
                        ),
                        Positioned(
                          top: 0,
                          right: 0.001.sw,
                          child: ExportProjectButton(
                            su: suprovider,
                            wp: provider,
                          ),
                        ),
                        Positioned(right: 0, top: 0.10.sh, child: ToolBar()),
                        Positioned(
                          bottom: 0.h,
                          right: 0.w,
                          child: ZoomControlButton(),
                        ),
                        Consumer2<WorkspaceProvider, CanvasProvider>(
                          builder: (
                            context,
                            workspaceProvider,
                            canvasProvider,
                            child,
                          ) {
                            return ListenableBuilder(
                              listenable:
                                  canvasProvider.transformationController,
                              builder: (context, child) {
                                if (workspaceProvider.shouldShowObjectToolbox) {
                                  final selectedObject =
                                      workspaceProvider
                                          .canvasObjects[workspaceProvider
                                          .currentlySelectedObjectId!]!;
                                  final objectBounds =
                                      selectedObject.getBounds();
                                  final matrix =
                                      canvasProvider
                                          .transformationController
                                          .value;
                                  final transformedTopCenter = matrix
                                      .transform3(
                                        vector_math.Vector3(
                                          objectBounds.topCenter.dx,
                                          objectBounds.topCenter.dy,
                                          0,
                                        ),
                                      );
                                  final screenPosition = Offset(
                                    transformedTopCenter.x,
                                    transformedTopCenter.y,
                                  );
                                  const double toolboxWidth = 240;
                                  const double toolboxHeight = 48;
                                  return Positioned(
                                    left:
                                        screenPosition.dx - (toolboxWidth / 2),
                                    top: screenPosition.dy - toolboxHeight - 15,
                                    child: const NodeEditingToolbox(),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            );
                          },
                        ),
                        const ObjectTextEditor(),
                      ],
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
