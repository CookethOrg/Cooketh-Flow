import 'package:cookethflow/core/utils/state_handler.dart';

class WorkspaceProvider extends StateHandler {
  WorkspaceProvider() : super();
  bool _isLoading = false;
  bool _isDrawerOpen = false;

  bool get isLoading => _isLoading;
  bool get isDrawerOpen => _isDrawerOpen;

  void setLoadingState() {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }
}
