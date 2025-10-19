import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/core/utils/enums.dart' as Rh;
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/connector_object.dart';
import 'package:cookethflow/features/workspace/pages/canvas_page.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/export_dialog.dart';
import 'package:cookethflow/features/workspace/widgets/node_editing_toolbox.dart';
import 'package:cookethflow/features/workspace/widgets/sticky_notes.dart';
import 'package:cookethflow/features/workspace/widgets/toolbar.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cookethflow/features/workspace/widgets/object_text_editor.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;
import 'package:cookethflow/core/utils/enums.dart' as en;

class WorkspaceMobile extends StatefulWidget {
  const WorkspaceMobile({super.key});

  @override
  State<WorkspaceMobile> createState() => _WorkspaceMobileState();
}

class _WorkspaceMobileState extends State<WorkspaceMobile> {
  final FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    en.DeviceType device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Consumer3<WorkspaceProvider, SupabaseService, ShortcutManagerr>(
      builder: (context, provider, suprovider, shortcutmanager, child) {
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
              provider.changeDrawMode(en.DrawMode.pointer);
              return null;
            },
          ),
          PanIntent: CallbackAction<PanIntent>(
            onInvoke: (intent) {
              provider.changeDrawMode(en.DrawMode.hand);
              return null;
            },
          ),
          TextIntent: CallbackAction<TextIntent>(
            onInvoke: (intent) {
              provider.changeDrawMode(en.DrawMode.textBox);
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
              focusNode: _focusNode,
              child: Scaffold(
                backgroundColor: provider.currentWorkspaceColor,
                body: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.h,
                    horizontal: 20.h,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const CanvasPage(),
                      workspaceDrawerMob(device),
                      // Positioned(
                      //   top: 120.h,
                      //   right: 0.h,
                      //   child: UndoRedoButton(su: suprovider),
                      // ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 40.h),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ToolBar(),
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
                                if (selectedObject is ConnectorObject) {
                                  // For connectors, position at midpoint of the line
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

                                    // Calculate midpoint
                                    final midPoint = Offset(
                                      (startPoint.dx + endPoint.dx) / 2,
                                      (startPoint.dy + endPoint.dy) / 2,
                                    );

                                    // Transform to screen coordinates
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
                                  // For shapes, use the top center as before
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
                      const ObjectTextEditor(),
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

Widget workspaceDrawerMob(en.DeviceType device) {
  return Consumer2<WorkspaceProvider, SupabaseService>(
    builder: (context, provider, suprovider, child) {
      Color defaultBorderColor = const Color(0xFFD9D9D9);

      // Check if currentWorkspace is set before accessing its properties
      final String workspaceName =
          provider.currentWorkspace?.name ?? "Loading...";

      return GestureDetector(
        onTap: () {
          // Optional: Close drawer if tapping outside visible content
          // if (provider.isDrawerOpen) {
          //   provider.toggleDrawer();
          // }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Always visible header row
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    provider.toggleDrawer();
                  },
                  icon:
                      !provider.isDrawerOpen
                          ? Icon(
                            PhosphorIconsRegular.sidebarSimple,
                            size: 100.sp,
                            color: Colors.black,
                          )
                          : Icon(
                            Icons.close,
                            size: 100.sp,
                            color: Colors.black,
                          ),
                  splashRadius: 24.r,
                  tooltip: 'Toggle Sidebar',
                ),
                SizedBox(width: 30.w),
                Expanded(
                  child: TextField(
                    controller: provider.workspaceNameController,
                    style: TextStyle(
                      fontFamily: 'Fredrik',
                      fontSize: 72.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      letterSpacing: 0.6,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),

                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder:
                          (context) =>
                              ExportDialog(su: suprovider, wp: provider),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 0.1.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Icon(
                    PhosphorIconsRegular.export,
                    color: Colors.white,
                    size: 100.sp,
                  ),
                ),
              ],
            ),
            Divider(),
            Expanded(
              child: AnimatedOpacity(
                opacity: provider.isDrawerOpen ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.topCenter,
                  child:
                      provider.isDrawerOpen
                          ? Align(
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: 350.h,
                              height: 780.h,
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount:
                                          provider.canvasObjectsList.length,
                                      itemBuilder: (context, index) {
                                        CanvasObject item =
                                            provider.canvasObjectsList[index];
                                        return _buildSelectableListTile(
                                          context,
                                          provider: provider,
                                          title:
                                              item.toJson()['object_type']
                                                  as String,
                                          iconData: provider
                                              .getIconForObjectType(
                                                item.toJson()['object_type'],
                                              ), // Use the helper
                                          index: index,
                                          isSelected:
                                              provider
                                                  .currentlySelectedObjectId ==
                                              item.id,
                                          device: device,
                                          onTap: () {
                                            provider.changeCurrentlySelectedObj(
                                              item.id,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildSelectableListTile(
  BuildContext context, {
  required WorkspaceProvider provider,
  required String title,
  required IconData iconData,
  required int index,
  required bool isSelected,
  required VoidCallback onTap,
  required en.DeviceType device,
}) {
  Color iconTextColor = isSelected ? Colors.blue : Colors.black;

  return Container(
    color: Colors.white,
    child: ListTile(
      leading: Icon(iconData, size: 85.sp, color: iconTextColor),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Fredrik',
          fontSize: 60.sp,
          color: iconTextColor,
        ),
      ),
      onTap: onTap,
    ),
  );
}
