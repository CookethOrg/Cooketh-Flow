// lib/features/workspace/widgets/object_text_editor.dart

import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
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
    return Consumer3<WorkspaceProvider, CanvasProvider, SupabaseService>(
      builder: (context, workspaceProvider, canvasProvider, suprovider, child) {
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

        final quillController = workspaceProvider.selectedObjectQuillController;
        final defaultTextColor = _getContrastColor(selectedObject.color);

        return Positioned(
          left: visibleRect.left,
          top: visibleRect.top,
          child: ClipRect(
            child: SizedBox(
              width: visibleRect.width,
              height: visibleRect.height,
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: QuillEditor.basic(
                    controller: quillController,
                    config: QuillEditorConfig(
                      padding: const EdgeInsets.all(8.0),
                      scrollable: false,
                      expands: false,
                      autoFocus: true,
                      customStyles: DefaultStyles(
                        placeHolder: DefaultTextBlockStyle(
                          TextStyle(color: defaultTextColor.withOpacity(0.5)),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        paragraph: DefaultTextBlockStyle(
                          TextStyle(color: defaultTextColor, fontSize: 14),
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
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getContrastColor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.4 ? Colors.black : Colors.white;
  }
}
