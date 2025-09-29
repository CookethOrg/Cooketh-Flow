// lib/features/workspace/pages/workspace_desktop.dart
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/models/canvas_models/objects/connector_object.dart';
import 'package:cookethflow/features/workspace/pages/canvas_page.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/export_project_button.dart';
import 'package:cookethflow/features/workspace/widgets/node_editing_toolbox.dart';
import 'package:cookethflow/features/workspace/widgets/sticky_notes.dart';
import 'package:cookethflow/features/workspace/widgets/toolbar.dart';
import 'package:cookethflow/features/workspace/widgets/undo_redo_button.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_drawer.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_shortcuts.dart'; // shortcut file
import 'package:cookethflow/features/workspace/widgets/zoom_control_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cookethflow/features/workspace/widgets/object_text_editor.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;
import 'package:cookethflow/core/utils/enums.dart' as en;

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
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      StickyNoteIntent: CallbackAction<StickyNoteIntent>(
        onInvoke: (intent) {
          final provider = Provider.of<SupabaseService>(context, listen: false);
          final device = en.DeviceType.desktop;
          _showStickyNote(context, device, provider);
          return null;
        },
      ),
      ResetIntent: CallbackAction<ResetIntent>(
        onInvoke: (intent) {
          final canvasProvider = Provider.of<CanvasProvider>(
            context,
            listen: false,
          );
          canvasProvider.resetZoom();
          return null;
        },
      ),
      ZoomInIntent: CallbackAction<ZoomInIntent>(
        onInvoke: (intent) {
          final canvasProvider = Provider.of<CanvasProvider>(
            context,
            listen: false,
          );
          canvasProvider.zoomIn();
          return null;
        },
      ),
      ZoomOutIntent: CallbackAction<ZoomOutIntent>(
        onInvoke: (intent) {
          final canvasProvider = Provider.of<CanvasProvider>(
            context,
            listen: false,
          );
          canvasProvider.zoomOut();
          return null;
        },
      ),
      EscapeIntent: CallbackAction<EscapeIntent>(
        onInvoke: (intent) {
          context.pop();
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

                                  Offset objectPosition;
                                  if (selectedObject is ConnectorObject) {
                                    // For connectors, calculate the midpoint for positioning
                                    final sourceObject =
                                        workspaceProvider
                                            .canvasObjects[selectedObject
                                            .sourceId];
                                    final targetObject =
                                        workspaceProvider
                                            .canvasObjects[selectedObject
                                            .targetId];
                                    if (sourceObject != null &&
                                        targetObject != null) {
                                      final startPoint = sourceObject
                                          .getConnectionPoint(
                                            selectedObject.sourceAlignment,
                                          );
                                      final endPoint = targetObject
                                          .getConnectionPoint(
                                            selectedObject.targetAlignment,
                                          );
                                      objectPosition = Offset(
                                        (startPoint.dx + endPoint.dx) / 2,
                                        (startPoint.dy + endPoint.dy) / 2,
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  } else {
                                    objectPosition =
                                        selectedObject.getBounds().topCenter;
                                  }

                                  final matrix =
                                      canvasProvider
                                          .transformationController
                                          .value;
                                  final transformedPosition = matrix.transform3(
                                    vector_math.Vector3(
                                      objectPosition.dx,
                                      objectPosition.dy,
                                      0,
                                    ),
                                  );
                                  final screenPosition = Offset(
                                    transformedPosition.x,
                                    transformedPosition.y,
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

  void _showStickyNote(
    BuildContext context,
    en.DeviceType device,
    SupabaseService su,
  ) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder:
            (context) => Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Positioned(
                  right: device == en.DeviceType.mobile ? position.dx : 150.w,
                  top:
                      device == en.DeviceType.desktop
                          ? 500.h
                          : device == en.DeviceType.tab
                          ? 500.h
                          : position.dy - 390.h,
                  child: Material(
                    color: Colors.transparent,
                    child: StickyNotesWidget(su: su),
                  ),
                ),
              ],
            ),
      );
    }
  }
}
