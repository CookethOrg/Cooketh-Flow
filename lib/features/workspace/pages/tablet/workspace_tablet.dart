import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/enums.dart' as Rh;
import 'package:cookethflow/features/models/canvas_models/objects/connector_object.dart';
import 'package:cookethflow/features/workspace/pages/canvas_page.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart'
    show CanvasProvider;
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/export_project_button.dart';
import 'package:cookethflow/features/workspace/widgets/node_editing_toolbox.dart';
import 'package:cookethflow/features/workspace/widgets/sticky_notes.dart';
import 'package:cookethflow/features/workspace/widgets/toolbar.dart';
import 'package:cookethflow/features/workspace/widgets/vertical_divider.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_drawer.dart';
import 'package:cookethflow/core/utils/enums.dart' as en;
import 'package:vector_math/vector_math_64.dart' as vector_math;

class WorkspaceTablet extends StatefulWidget {
  const WorkspaceTablet({super.key});

  @override
  State<WorkspaceTablet> createState() => _WorkspaceTabletState();
}

class _WorkspaceTabletState extends State<WorkspaceTablet> {
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
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Consumer3<WorkspaceProvider, SupabaseService, ShortcutManagerr>(
      builder: (
        context,
        workspaceProvider,
        suprovider,
        shortcutmanager,
        child,
      ) {
        final shortcutsMap = shortcutmanager.buildShortcutsMap({
          PointerIntent: () => PointerIntent(),
          PanIntent: () => PanIntent(),
          TextIntent: () => TextIntent(),
          StickyNoteIntent: () => StickyNoteIntent(),
          ResetIntent: () => ResetIntent(),
          ZoomInIntent: () => ZoomInIntent(),
          ZoomOutIntent: () => ZoomOutIntent(),
        });

        final Map<Type, Action<Intent>> actions = {
          PointerIntent: CallbackAction<PointerIntent>(
            onInvoke: (intent) {
              workspaceProvider.changeDrawMode(en.DrawMode.pointer);
              return null;
            },
          ),
          PanIntent: CallbackAction<PanIntent>(
            onInvoke: (intent) {
              workspaceProvider.changeDrawMode(en.DrawMode.hand);
              return null;
            },
          ),
          TextIntent: CallbackAction<TextIntent>(
            onInvoke: (intent) {
              workspaceProvider.changeDrawMode(en.DrawMode.textBox);
              return null;
            },
          ),
          StickyNoteIntent: CallbackAction<StickyNoteIntent>(
            onInvoke: (intent) {
              final device = Rh.DeviceType.desktop;
              _showStickyNote(context, device, suprovider);
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
        };

        return Shortcuts(
          shortcuts: shortcutsMap,
          child: Actions(
            actions: actions,
            child: Focus(
              autofocus: true,
              child: Scaffold(
                backgroundColor: const Color(0xFFF8F8F8),
                body: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  child: Stack(
                    children: [
                      CanvasPage(),
                      const WorkspaceDrawer(),
                      Positioned(
                        top: 0,
                        right: 0.001.sw,
                        child: ExportProjectButton(
                          su: suprovider,
                          wp: workspaceProvider,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 10.w),
                          child: const ToolBar(),
                        ),
                      ),
                      Positioned(
                        bottom: 20.h,
                        right: 0.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFD9D9D9),
                              width: 1.2,
                            ),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "100%",
                                style: TextStyle(
                                  fontSize:
                                      device == en.DeviceType.desktop
                                          ? 20.sp
                                          : 40.sp,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              VerticalCustomDivider(),
                              SizedBox(width: 6.w),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  PhosphorIconsRegular.plus,
                                  size:
                                      device == en.DeviceType.desktop
                                          ? 20.sp
                                          : 50.sp,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                              SizedBox(width: 6.w),
                              VerticalCustomDivider(),
                              SizedBox(width: 6.w),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  PhosphorIconsRegular.minus,
                                  size:
                                      device == en.DeviceType.desktop
                                          ? 20.sp
                                          : 50.sp,
                                ),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Consumer2<WorkspaceProvider, CanvasProvider>(
                        builder: (
                          context,
                          workspaceProvider,
                          canvasProvider,
                          child,
                        ) {
                          return ListenableBuilder(
                            listenable: canvasProvider.transformationController,
                            builder: (context, child) {
                              if (workspaceProvider.shouldShowObjectToolbox) {
                                final selectedObject =
                                    workspaceProvider
                                        .canvasObjects[workspaceProvider
                                        .currentlySelectedObjectId!]!;

                                final matrix =
                                    canvasProvider
                                        .transformationController
                                        .value;
                                Offset screenPosition;

                                // Different positioning for connectors vs shapes
                                if (selectedObject is ConnectorObject) {
                                  final source =
                                      workspaceProvider
                                          .canvasObjects[selectedObject
                                          .sourceId];
                                  final target =
                                      workspaceProvider
                                          .canvasObjects[selectedObject
                                          .targetId];

                                  if (source != null && target != null) {
                                    final startPoint = source
                                        .getConnectionPoint(
                                          selectedObject.sourceAlignment,
                                        );
                                    final endPoint = target.getConnectionPoint(
                                      selectedObject.targetAlignment,
                                    );

                                    final midPoint = Offset(
                                      (startPoint.dx + endPoint.dx) / 2,
                                      (startPoint.dy + endPoint.dy) / 2,
                                    );

                                    final transformedMidPoint = matrix
                                        .transform3(
                                          vector_math.Vector3(
                                            midPoint.dx,
                                            midPoint.dy,
                                            0,
                                          ),
                                        );

                                    screenPosition = Offset(
                                      transformedMidPoint.x,
                                      transformedMidPoint.y,
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                } else {
                                  final objectBounds =
                                      selectedObject.getBounds();
                                  final transformedTopCenter = matrix
                                      .transform3(
                                        vector_math.Vector3(
                                          objectBounds.topCenter.dx,
                                          objectBounds.topCenter.dy,
                                          0,
                                        ),
                                      );

                                  screenPosition = Offset(
                                    transformedTopCenter.x,
                                    transformedTopCenter.y,
                                  );
                                }

                                const double toolboxWidth = 240;
                                const double toolboxHeight = 48;

                                return Positioned(
                                  left: screenPosition.dx - (toolboxWidth / 2),
                                  top: screenPosition.dy - toolboxHeight - 15,
                                  child: const NodeEditingToolbox(),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          );
                        },
                      ),
                    ],
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
    Rh.DeviceType device,
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
                  right: device == Rh.DeviceType.mobile ? position.dx : 150.w,
                  top:
                      device == Rh.DeviceType.desktop
                          ? 500.h
                          : device == Rh.DeviceType.tab
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
