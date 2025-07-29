// lib/features/workspace/widgets/object_text_editor.dart

import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vc;

class ObjectTextEditor extends StatefulWidget {
  const ObjectTextEditor({super.key});

  @override
  State<ObjectTextEditor> createState() => _ObjectTextEditorState();
}

class _ObjectTextEditorState extends State<ObjectTextEditor> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkspaceProvider, CanvasProvider>(
      builder: (context, workspaceProvider, canvasProvider, child) {
        final selectedObjectId = workspaceProvider.currentlySelectedObjectId;
        final selectedObject =
            selectedObjectId != null
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
        final Matrix4 transform = canvasProvider.transformationController.value;
        final vc.Vector3 transformedTopLeft = transform.transform3(
          vc.Vector3(objectBounds.topLeft.dx, objectBounds.topLeft.dy, 0),
        );
        final Offset screenTopLeft = Offset(
          transformedTopLeft.x,
          transformedTopLeft.y,
        );
        final vc.Vector3 transformedBottomRight = transform.transform3(
          vc.Vector3(
            objectBounds.bottomRight.dx,
            objectBounds.bottomRight.dy,
            0,
          ),
        );
        final visibleRect = Rect.fromPoints(
          screenTopLeft,
          Offset(transformedBottomRight.x, transformedBottomRight.y),
        );

        final quillController = workspaceProvider.selectedObjectQuillController;

        return Positioned(
          left: visibleRect.left,
          // Position the entire widget (toolbar + editor) at the object's location
          top: visibleRect.top,
          child: Material(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
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
                  child: QuillSimpleToolbar(
                    controller: quillController,
                    config: QuillSimpleToolbarConfig(
                      showBackgroundColorButton: true,
                      showFontFamily: false,
                      showLink: false,
                      showSearchButton: false,
                      showInlineCode: false,
                      showListCheck: false,
                      showQuote: false,
                      showCodeBlock: false,
                      showListBullets: true,
                      showListNumbers: true,
                      showClearFormat: true,
                      showBoldButton: true,
                      showItalicButton: true,
                      showHeaderStyle: true,
                    ),
                  ),
                ),
                SizedBox(height: 4.h), // Spacing between toolbar and editor
                // FIX: Add a visible container for the editor
                Container(
                  width: visibleRect.width,
                  height: visibleRect.height,
                  decoration: BoxDecoration(
                    color: Colors.white, // Make the editor background white
                    border: Border.all(
                      color: Colors.blue.shade300,
                      width: 1.5,
                    ), // Add a border
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
                      ),
                      placeholder: 'Type here...',
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
