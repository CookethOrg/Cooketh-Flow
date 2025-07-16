import 'package:cookethflow/core/utils/state_handler.dart';

class WorkspaceProvider extends StateHandler {
  WorkspaceProvider() : super();

  bool _isLoading = false;
  bool _isDrawerOpen = false;
  int? _selectedTileIndex; // Stores the index of the currently selected tile, null if none

  bool get isLoading => _isLoading;
  bool get isDrawerOpen => _isDrawerOpen;
  int? get selectedTileIndex => _selectedTileIndex; // Getter for the selected index

  // New getter to easily check if any tile is selected for the drawer's border
  bool get hasSelectedTile => _selectedTileIndex != null;

  void selectTile(int index) {
    if (_selectedTileIndex == index) {
      // If the same tile is tapped again, deselect it
      _selectedTileIndex = null;
    } else {
      // Otherwise, select the new tile
      _selectedTileIndex = index;
    }
    notifyListeners();
  }

  void setLoadingState() {
    _isLoading = !_isLoading;
    notifyListeners();
  }

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }
}