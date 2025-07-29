// lib/features/workspace/widgets/object_text_editor.dart

import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/models/canvas_models/canvas_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/text_box_object.dart';
import 'package:cookethflow/features/workspace/providers/canvas_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:vector_math/vector_math_64.dart' as vc; // Correct alias for Vector3

// Renamed from TextBox to ObjectTextEditor
class ObjectTextEditor extends StatelessWidget {
  const ObjectTextEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkspaceProvider, CanvasProvider>(
      builder: (context, workspaceProvider, canvasProvider, child) {
        // Only show the editor if an object is selected and it's a TextBoxObject
        // or if we are in text editing mode (which implies an object is selected for text editing).
        final bool isSelectedAndEditable = workspaceProvider.currentlySelectedObjectId != null &&
            (workspaceProvider.interactionMode == InteractionMode.editingText ||
             workspaceProvider.canvasObjects[workspaceProvider.currentlySelectedObjectId!]?.textDelta != null);

        if (!isSelectedAndEditable) {
          return const SizedBox.shrink(); // Hide the editor if no editable object is selected
        }

        final CanvasObject? selectedObject = workspaceProvider.canvasObjects[workspaceProvider.currentlySelectedObjectId!];

        if (selectedObject == null) {
          return const SizedBox.shrink();
        }

        // Get the object's bounds (in canvas coordinates)
        final Rect objectBounds = selectedObject.getBounds();

        // Convert canvas coordinates to screen coordinates
        // This requires applying the current transformation from InteractiveViewer
        final Matrix4 transform = canvasProvider.transformationController.value;

        // Corrected: Convert Vector3 to Offset manually
        final vc.Vector3 transformedTopLeft = transform.transform3(vc.Vector3(objectBounds.topLeft.dx, objectBounds.topLeft.dy, 0));
        final Offset screenTopLeft = Offset(transformedTopLeft.x, transformedTopLeft.y);

        final vc.Vector3 transformedBottomRight = transform.transform3(vc.Vector3(objectBounds.bottomRight.dx, objectBounds.bottomRight.dy, 0));
        final Offset screenBottomRight = Offset(transformedBottomRight.x, transformedBottomRight.y);

        // The actual visible rectangle on screen after pan/zoom
        final visibleRect = Rect.fromPoints(
          screenTopLeft,
          screenBottomRight,
        );

        // If it's a TextBoxObject, we want the editor to be exactly its size and position
        final bool isTextBox = selectedObject is TextBoxObject;

        return Positioned(
          left: visibleRect.left,
          top: visibleRect.top - (isTextBox ? (50.h + 5.h) : 0), // Position toolbar above if textbox
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isTextBox) // Only show toolbar directly above for TextBoxObjects
                Container(
                  width: visibleRect.width,
                  height: 50.h, // Fixed height for toolbar
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.r),
                      topRight: Radius.circular(8.r),
                    ),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: QuillSimpleToolbar(
                    controller: workspaceProvider.selectedObjectQuillController,
                  ),
                ),
              SizedBox(
                width: visibleRect.width,
                height: isTextBox ? visibleRect.height : 100.h, // Fixed height for non-textbox object's editor
                child: Container(
                  // CORRECTED: Moved color inside BoxDecoration when a decoration is present.
                  decoration: isTextBox && selectedObject.color.opacity == 0
                      ? BoxDecoration(
                          color: Colors.transparent, // Background color for text boxes when decoration is present
                          border: Border.all(color: Colors.grey.shade400, width: 1.0, style: BorderStyle.solid),
                        )
                      : BoxDecoration( // Provide a default BoxDecoration if no specific border is needed
                          color: isTextBox ? Colors.transparent : Colors.white70, // Background color for the editor itself
                        ),
                  child: AbsorbPointer(
                    absorbing: workspaceProvider.interactionMode != InteractionMode.editingText,
                    child: QuillEditor.basic(
                      controller: workspaceProvider.selectedObjectQuillController,
                      // readOnly: workspaceProvider.interactionMode != InteractionMode.editingText, // Make read-only if not in editing mode
                      focusNode: FocusNode(), // QuillEditor needs a focus node
                      // padding: EdgeInsets.zero, // Adjust padding if needed
                      // expands: true,
                      // scrollable: true,
                    ),
                  ),
                ),
              ),
              if (!isTextBox) // Show general floating toolbar for other objects
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Container(
                    width: 300.w, // Fixed width for floating toolbar
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: QuillSimpleToolbar(
                      controller: workspaceProvider.selectedObjectQuillController,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}