// lib/features/workspace/widgets/object_text_editor.dart

import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vc;
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;

class ObjectTextEditor extends StatefulWidget {
  const ObjectTextEditor({super.key});

  @override
  State<ObjectTextEditor> createState() => _ObjectTextEditorState();
}

class _ObjectTextEditorState extends State<ObjectTextEditor> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _toolbarKey = GlobalKey();
  double _toolbarHeight = 50.h; // A default height

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _toolbarKey.currentContext;
      if (context != null) {
        final box = context.findRenderObject() as RenderBox;
        if (mounted) {
          setState(() {
            _toolbarHeight = box.size.height;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return Consumer2<WorkspaceProvider, CanvasProvider>(
      builder: (context, workspaceProvider, canvasProvider, child) {
        final selectedObjectId = workspaceProvider.currentlySelectedObjectId;
        final selectedObject = selectedObjectId != null
            ? workspaceProvider.canvasObjects[selectedObjectId]
            : null;

        if (workspaceProvider.interactionMode != InteractionMode.editingText ||
            selectedObject == null) {
          return const SizedBox.shrink();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_focusNode.hasFocus) {
            _focusNode.requestFocus();
          }
        });

        final Rect objectBounds = selectedObject.getBounds();
        final Matrix4 transform =
            canvasProvider.transformationController.value;
        final vc.Vector3 transformedTopLeft = transform.transform3(
          vc.Vector3(objectBounds.topLeft.dx, objectBounds.topLeft.dy, 0),
        );
        final vc.Vector3 transformedBottomRight = transform.transform3(
          vc.Vector3(
            objectBounds.bottomRight.dx,
            objectBounds.bottomRight.dy,
            0,
          ),
        );
        final visibleRect = Rect.fromPoints(
          Offset(transformedTopLeft.x, transformedTopLeft.y),
          Offset(transformedBottomRight.x, transformedBottomRight.y),
        );

        final quillController =
            workspaceProvider.selectedObjectQuillController;

        return Positioned(
          left: visibleRect.left,
          top: visibleRect.top - _toolbarHeight - 4.h,
          child: Material(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  key: _toolbarKey,
                  width: visibleRect.width < 350.w ? 350.w : visibleRect.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: QuillSimpleToolbar(
                      controller: quillController,
                      config: const QuillSimpleToolbarConfig(
                        showBackgroundColorButton: true,
                        showFontFamily: true,
                        showLink: true,
                        showSearchButton: false,
                        showInlineCode: true,
                        showListCheck: true,
                        showQuote: true,
                        showCodeBlock: true,
                        showListBullets: true,
                        showListNumbers: true,
                        showClearFormat: true,
                        showBoldButton: true,
                        showItalicButton: true,
                        showHeaderStyle: true,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  width: visibleRect.width,
                  height: visibleRect.height,
                  decoration: BoxDecoration(
                    // The editor background is transparent to see the object behind it.
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.blue.shade400,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: QuillEditor.basic(
                    controller: quillController,
                    config: QuillEditorConfig(
                      padding: const EdgeInsets.all(8.0),
                      scrollable: true,
                      expands: true,
                      customStyles: DefaultStyles(
                        placeHolder: DefaultTextBlockStyle(
                          const TextStyle(color: Colors.grey),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        paragraph: DefaultTextBlockStyle(
                          // Default text color
                          const TextStyle(color: Colors.black),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                      ),
                      placeholder: 'Type something...',
                    ),
                    focusNode: _focusNode,
                    scrollController: ScrollController(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}