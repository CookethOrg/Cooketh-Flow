import 'package:cookethflow/core/utils/state_handler.dart';
import 'package:cookethflow/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DashboardProvider extends StateHandler {
  late Object? auth;
  DashboardProvider(this.auth);
  bool _isDrawerOpen = true;
  int _tabIndex = 0;
  bool get isDrawerOpen => _isDrawerOpen;
  int get tabIndex => _tabIndex;

  List<Map<String, dynamic>> tabItems = [
    {"label": "All", "icon": Icon(PhosphorIcons.cardsThree())},
    {"label": "Starred", "icon": Icon(PhosphorIcons.star())},
    {"label": "Trash", "icon": Icon(PhosphorIcons.trashSimple())},
    {"label": "About us", "icon": Icon(PhosphorIcons.info())},
  ];

  void toggleDrawer() {
    _isDrawerOpen = !_isDrawerOpen;
    notifyListeners();
  }

  void toggleTab(int idx) {
    if (_tabIndex != idx) {
      _tabIndex = idx;
      notifyListeners();
    }
  }
}
