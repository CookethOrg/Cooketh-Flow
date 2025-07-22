import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/widgets.dart'; // Import for TransformationController

class CanvasProvider extends StateHandler {
  final WorkspaceProvider _workspaceProvider;
  CanvasProvider(this._workspaceProvider) : super();

  final TransformationController _transformationController =
      TransformationController();

  TransformationController get transformationController =>
      _transformationController;

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
    _transformationController.value = Matrix4.identity();
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