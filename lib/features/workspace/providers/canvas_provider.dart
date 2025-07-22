import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/widgets.dart'; // Import for TransformationController

class CanvasProvider extends StateHandler {
  final WorkspaceProvider _workspaceProvider;
  CanvasProvider(this._workspaceProvider) : super() {
    // Initialize the transformation to center the view when the provider is created
    // We need to wait a frame for the context and size to be available,
    // or ideally set it after the initial build. For now, we can set a
    // default center based on the large canvas size.
    // A more robust solution might involve `WidgetsBinding.instance.addPostFrameCallback`.
    // For a fixed large canvas size, we can calculate the center directly.
    _initializeCenteredView();
  }

  final TransformationController _transformationController = TransformationController();

  TransformationController get transformationController => _transformationController;

  // Define the size of your virtual canvas
  static const Size _canvasSize = Size(20000, 20000);

  void _initializeCenteredView() {
    // Calculate the center of the large virtual canvas
    final Offset canvasCenter = Offset(_canvasSize.width / 2, _canvasSize.height / 2);

    // Get the initial viewport size (e.g., screen size).
    // This will be dynamic, so for initial setup, we might approximate or
    // use a post-frame callback to get the actual InteractiveViewer bounds.
    // For now, let's assume we want to center the canvas's origin in the middle of the screen's interactive area.
    // However, the request is to center the *canvas itself*.
    // So, we need to translate the viewer so that the canvasCenter is at (0,0) in the viewport.
    // Or, more accurately, we want the screen's center to align with the canvas's center.

    // This sets the initial matrix to translate the view such that the
    // center of the 20000x20000 canvas is visible in the middle of the viewport.
    // This assumes the InteractiveViewer will occupy the full available space.
    // The translation needs to move the canvas's center to the viewport's center.
    // If the viewport is V_w x V_h, and canvas is C_w x C_h,
    // we want to display C_w/2, C_h/2 at V_w/2, V_h/2.
    // This implies a translation of (V_w/2 - C_w/2, V_h/2 - C_h/2).
    // However, InteractiveViewer automatically handles placing its child based on its current matrix.
    // If we want the *center of our very large canvas* to be at the *center of the screen*,
    // we need to translate the *view* by the negative of the canvas's center offset.

    // Let's set the translation such that the top-left of the canvas (0,0) is moved.
    // If we want the center of the canvas (10000, 10000) to appear at the center of our screen (e.g., 500, 300),
    // then the transformation matrix needs to translate the canvas so that
    // (10000, 10000) maps to (500, 300).
    // The InteractiveViewer's transform applies to its child.
    // A simple way to center a large child is to translate it by half the viewport dimensions
    // minus half the child dimensions, or directly translate by a specific point.

    // A common approach for centering a large canvas in InteractiveViewer:
    // When the InteractiveViewer first appears, it's typically showing the (0,0) of its child
    // at its top-left corner. To center the content, we need to apply a translation
    // to the InteractiveViewer's matrix.
    // The required translation is such that `canvasCenter` moves to `viewportCenter`.
    // Let's assume the viewport center is `(screenWidth / 2, screenHeight / 2)`.
    // The canvas center is `(canvasWidth / 2, canvasHeight / 2)`.
    // The translation needed for the InteractiveViewer's matrix is:
    // `(screenWidth / 2 - canvasWidth / 2, screenHeight / 2 - canvasHeight / 2)`
    // This translation will move the canvas's top-left corner such that the canvas center
    // aligns with the viewport center.

    // Since we don't have direct access to `MediaQuery.of(context).size` here in the constructor,
    // we might need a `WidgetsBinding.instance.addPostFrameCallback` in the `CanvasPage`
    // or a method that can be called after the `BuildContext` is available.
    // For demonstration, let's just set a large initial translation to make sure
    // some central part of the 20000x20000 canvas is visible.
    // A translation of (-canvasCenter.dx + viewport_center_dx, -canvasCenter.dy + viewport_center_dy)
    // would be ideal if viewport size was known.

    // Let's try to initialize it to a point that's approximately central.
    // If the canvas is 20000x20000, its center is 10000, 10000.
    // We want to translate the view *to* that point, so we need a negative translation.
    // The `_transformationController.value` is a `Matrix4`.
    // `Matrix4.translationValues(x, y, z)` creates a translation matrix.
    // If we want the point (X, Y) on the child to be visible at the top-left of the viewer,
    // the translation would be (-X, -Y).
    // If we want (X, Y) to be visible at the center of the viewer, it's more complex
    // as it depends on the viewer's size.

    // A simpler approach for *initial centering* without knowing the viewport size
    // is to translate by a fixed large amount that will bring a central part of
    // the 20000x20000 canvas into view.
    // Let's assume a typical screen size and calculate the offset needed to bring
    // the (10000, 10000) point of the canvas to the center of a hypothetical 1000x800 screen.
    // Target viewport center: (500, 400)
    // Canvas center: (10000, 10000)
    // Desired translation for canvas origin (0,0) relative to viewport:
    // (500 - 10000, 400 - 10000) = (-9500, -9600)

    _transformationController.value = Matrix4.translationValues(
      -canvasCenter.dx + 500, // Adjust 500 based on expected initial viewport width / 2
      -canvasCenter.dy + 400, // Adjust 400 based on expected initial viewport height / 2
      0,
    );
  }

  void zoomIn() {
    _transformationController.value = Matrix4.identity()
      ..translate(_transformationController.value.getTranslation().x, _transformationController.value.getTranslation().y)
      ..scale(_transformationController.value.storage[0] * 1.2); // Zoom in by 20%
    notifyListeners();
  }

  void zoomOut() {
    _transformationController.value = Matrix4.identity()
      ..translate(_transformationController.value.getTranslation().x, _transformationController.value.getTranslation().y)
      ..scale(_transformationController.value.storage[0] * 0.8); // Zoom out by 20%
    notifyListeners();
  }

  void resetZoom() {
    // Reset to the initially calculated centered view
    _initializeCenteredView();
    notifyListeners();
  }

  double get currentZoomPercentage {
    final scale = _transformationController.value.storage[0];
    return scale * 100;
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}