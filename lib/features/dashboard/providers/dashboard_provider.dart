import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/features/auth/providers/auth_provider.dart';

class DashboardProvider extends StateHandler {
  late Object? auth;
  DashboardProvider(this.auth);
  bool _isDrawerOpen = true;
  bool get isDrawerOpen => _isDrawerOpen;

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }
}
