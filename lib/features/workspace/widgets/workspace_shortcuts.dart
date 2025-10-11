// lib/core/services/shortcut_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ShortcutManagerr extends ChangeNotifier {
  static const String _storageKey = 'custom_shortcuts';
  
  // Default shortcuts
  static final Map<String, List<LogicalKeyboardKey>> _defaultShortcuts = {
    'pointer': [LogicalKeyboardKey.keyP],
    'pan': [LogicalKeyboardKey.keyA],
    'text': [LogicalKeyboardKey.keyT],
    'stickyNote': [LogicalKeyboardKey.keyS],
    'reset': [LogicalKeyboardKey.keyR],
    'zoomIn': [LogicalKeyboardKey.keyZ],
    'zoomOut': [LogicalKeyboardKey.keyX],
  };

  Map<String, List<LogicalKeyboardKey>> _shortcuts = {};
  
  ShortcutManagerr() {
    _shortcuts = Map.from(_defaultShortcuts);
    _loadShortcuts();
  }

  // Get current shortcuts
  Map<String, List<LogicalKeyboardKey>> get shortcuts => _shortcuts;

  // Get shortcut for specific action
  List<LogicalKeyboardKey>? getShortcut(String action) => _shortcuts[action];

  // Get human-readable shortcut string
  String getShortcutLabel(String action) {
    final keys = _shortcuts[action];
    if (keys == null || keys.isEmpty) return 'Not set';
    
    return keys.map((key) {
      String label = key.keyLabel.toUpperCase();
      if (key == LogicalKeyboardKey.control || key == LogicalKeyboardKey.controlLeft || key == LogicalKeyboardKey.controlRight) {
        label = 'Ctrl';
      } else if (key == LogicalKeyboardKey.shift || key == LogicalKeyboardKey.shiftLeft || key == LogicalKeyboardKey.shiftRight) {
        label = 'Shift';
      } else if (key == LogicalKeyboardKey.alt || key == LogicalKeyboardKey.altLeft || key == LogicalKeyboardKey.altRight) {
        label = 'Alt';
      } else if (key == LogicalKeyboardKey.meta || key == LogicalKeyboardKey.metaLeft || key == LogicalKeyboardKey.metaRight) {
        label = 'Cmd';
      }
      return label;
    }).join(' + ');
  }

  // Update shortcut for an action
  Future<void> updateShortcut(String action, List<LogicalKeyboardKey> keys) async {
    // Check for conflicts
    for (var entry in _shortcuts.entries) {
      if (entry.key != action && _areKeysEqual(entry.value, keys)) {
        throw Exception('Shortcut already assigned to ${entry.key}');
      }
    }

    _shortcuts[action] = keys;
    await _saveShortcuts();
    notifyListeners();
  }

  // Reset to default shortcuts
  Future<void> resetToDefaults() async {
    _shortcuts = Map.from(_defaultShortcuts);
    await _saveShortcuts();
    notifyListeners();
  }

  // Reset specific shortcut
  Future<void> resetShortcut(String action) async {
    if (_defaultShortcuts.containsKey(action)) {
      _shortcuts[action] = _defaultShortcuts[action]!;
      await _saveShortcuts();
      notifyListeners();
    }
  }

  // Build shortcuts map for Flutter Shortcuts widget
  Map<LogicalKeySet, Intent> buildShortcutsMap(Map<Type, Intent Function()> intentFactories) {
    final Map<LogicalKeySet, Intent> shortcutsMap = {};
    
    final actionToIntent = {
      'pointer': intentFactories[PointerIntent],
      'pan': intentFactories[PanIntent],
      'text': intentFactories[TextIntent],
      'stickyNote': intentFactories[StickyNoteIntent],
      'reset': intentFactories[ResetIntent],
      'zoomIn': intentFactories[ZoomInIntent],
      'zoomOut': intentFactories[ZoomOutIntent],
    };

    for (var entry in _shortcuts.entries) {
      final intentFactory = actionToIntent[entry.key];
      if (intentFactory != null && entry.value.isNotEmpty) {
        shortcutsMap[LogicalKeySet.fromSet(entry.value.toSet())] = intentFactory();
      }
    }

    return shortcutsMap;
  }

  // Check if two key lists are equal
  bool _areKeysEqual(List<LogicalKeyboardKey> keys1, List<LogicalKeyboardKey> keys2) {
    if (keys1.length != keys2.length) return false;
    final set1 = keys1.toSet();
    final set2 = keys2.toSet();
    return set1.difference(set2).isEmpty && set2.difference(set1).isEmpty;
  }

  // Load shortcuts from storage
  Future<void> _loadShortcuts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      
      if (data != null) {
        final Map<String, dynamic> decoded = json.decode(data);
        _shortcuts = decoded.map((key, value) {
          final List<int> keyIds = List<int>.from(value);
          return MapEntry(
            key,
            keyIds.map((id) => LogicalKeyboardKey(id)).toList(),
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading shortcuts: $e');
      _shortcuts = Map.from(_defaultShortcuts);
    }
    notifyListeners();
  }

  // Save shortcuts to storage
  Future<void> _saveShortcuts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> toEncode = _shortcuts.map((key, value) {
        return MapEntry(key, value.map((k) => k.keyId).toList());
      });
      await prefs.setString(_storageKey, json.encode(toEncode));
    } catch (e) {
      debugPrint('Error saving shortcuts: $e');
    }
  }
}

// Intent classes (same as before)
class PointerIntent extends Intent {}
class PanIntent extends Intent {}
class TextIntent extends Intent {}
class StickyNoteIntent extends Intent {}
class ResetIntent extends Intent {}
class ZoomInIntent extends Intent {}
class ZoomOutIntent extends Intent {}