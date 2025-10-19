// lib/core/services/shortcut_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

class ShortcutManagerr extends ChangeNotifier {
  static const String _storageKey = 'custom_shortcuts';
  final SupabaseClient? supabase;

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
  //UserSettingsModel? _userSettings;

  ShortcutManagerr(this.supabase) {
    _shortcuts = Map.from(_defaultShortcuts);
    _loadShortcuts();
  }

  // Get current shortcuts
  Map<String, List<LogicalKeyboardKey>> get shortcuts => _shortcuts;
  //UserSettingsModel? get userSettings => _userSettings;

  // Get shortcut for specific action
  List<LogicalKeyboardKey>? getShortcut(String action) => _shortcuts[action];

  // Get human-readable shortcut string
  String getShortcutLabel(String action) {
    final keys = _shortcuts[action];
    if (keys == null || keys.isEmpty) return 'Not set';

    return keys
        .map((key) {
          String label = key.keyLabel.toUpperCase();
          if (key == LogicalKeyboardKey.control ||
              key == LogicalKeyboardKey.controlLeft ||
              key == LogicalKeyboardKey.controlRight) {
            label = 'Ctrl';
          } else if (key == LogicalKeyboardKey.shift ||
              key == LogicalKeyboardKey.shiftLeft ||
              key == LogicalKeyboardKey.shiftRight) {
            label = 'Shift';
          } else if (key == LogicalKeyboardKey.alt ||
              key == LogicalKeyboardKey.altLeft ||
              key == LogicalKeyboardKey.altRight) {
            label = 'Alt';
          } else if (key == LogicalKeyboardKey.meta ||
              key == LogicalKeyboardKey.metaLeft ||
              key == LogicalKeyboardKey.metaRight) {
            label = 'Cmd';
          }
          return label;
        })
        .join(' + ');
  }

  // Update shortcut for an action
  Future<void> updateShortcut(
    String action,
    List<LogicalKeyboardKey> keys,
  ) async {
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
  Map<LogicalKeySet, Intent> buildShortcutsMap(
    Map<Type, Intent Function()> intentFactories,
  ) {
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
        shortcutsMap[LogicalKeySet.fromSet(entry.value.toSet())] =
            intentFactory();
      }
    }

    return shortcutsMap;
  }

  // Check if two key lists are equal
  bool _areKeysEqual(
    List<LogicalKeyboardKey> keys1,
    List<LogicalKeyboardKey> keys2,
  ) {
    if (keys1.length != keys2.length) return false;
    final set1 = keys1.toSet();
    final set2 = keys2.toSet();
    return set1.difference(set2).isEmpty && set2.difference(set1).isEmpty;
  }

  // Load shortcuts from storage (SharedPreferences first, fallback to Supabase)
  Future<void> _loadShortcuts() async {
    try {
      // Try loading from SharedPreferences first (faster)
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
        debugPrint('Shortcuts loaded from SharedPreferences.');
      } else {
        // If not in SharedPreferences, try loading from Supabase
        //await _loadFromSupabase();
      }
    } catch (e) {
      debugPrint('Error loading shortcuts: $e');
      _shortcuts = Map.from(_defaultShortcuts);
    }
    notifyListeners();
  }

  // Load shortcuts from Supabase
  // Load shortcuts from Supabase user_metadata
  // Future<void> _loadFromSupabase() async {
  //   if (supabase == null) {
  //     debugPrint("Supabase client is not initialized.");
  //     return;
  //   }

  //   try {
  //     final user = supabase!.auth.currentUser;
  //     if (user == null) {
  //       debugPrint("No authenticated user found.");
  //       return;
  //     }

  //     final Map<String, dynamic>? metadata = user.userMetadata;
  //     if (metadata == null) {
  //       debugPrint("No user_metadata found for user.");
  //       return;
  //     }

  //     final dynamic shortcutsRaw = metadata['shortcuts'];
  //     if (shortcutsRaw != null && shortcutsRaw is Map) {
  //       final parsed = <String, List<LogicalKeyboardKey>>{};
  //       shortcutsRaw.forEach((key, value) {
  //         try {
  //           final ids = List<int>.from(value as List);
  //           parsed[key as String] =
  //               ids.map((id) => LogicalKeyboardKey(id)).toList();
  //         } catch (e) {
  //           debugPrint('Error parsing one shortcut entry: $e');
  //         }
  //       });

  //       if (parsed.isNotEmpty) {
  //         _shortcuts = parsed;
  //         debugPrint('Shortcuts loaded from user_metadata.');
  //         // cache locally
  //         await _saveToSharedPreferences();
  //       }
  //     }

  //     // Optionally parse last_updated if you want
  //     if (metadata['last_updated'] != null) {
  //       try {
  //         _userSettings ??= UserSettingsModel(userId: user.id, shortcuts: {});
  //         _userSettings = _userSettings!.copyWith(
  //           lastUpdated: DateTime.parse(metadata['last_updated'] as String),
  //         );
  //       } catch (_) {}
  //     }
  //   } catch (e) {
  //     debugPrint('Error loading shortcuts from Supabase metadata: $e');
  //   }
  // }

  // Save shortcuts to both SharedPreferences and Supabase
  Future<void> _saveShortcuts() async {
    // Save to SharedPreferences (local cache)
    await _saveToSharedPreferences();

    // Save to Supabase (persistent storage)
    // await _updateUserSettings();
  }

  // Save to SharedPreferences
  Future<void> _saveToSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> toEncode = _shortcuts.map((key, value) {
        return MapEntry(key, value.map((k) => k.keyId).toList());
      });
      await prefs.setString(_storageKey, json.encode(toEncode));
      debugPrint('Shortcuts saved to SharedPreferences.');
    } catch (e) {
      debugPrint('Error saving shortcuts to SharedPreferences: $e');
    }
  }

  // Save to Supabase user_metadata
  // Future<void> _updateUserSettings() async {
  //   if (supabase == null) {
  //     debugPrint(
  //       " Supabase client is not initialized. Cannot save to Supabase.",
  //     );
  //     return;
  //   }

  //   try {
  //     final user = supabase!.auth.currentUser;
  //     if (user == null) {
  //       debugPrint(" No authenticated user found. Cannot save to Supabase.");
  //       return;
  //     }

  //     // Existing metadata (important: merge, not replace)
  //     final existingMetadata = Map<String, dynamic>.from(
  //       user.userMetadata ?? {},
  //     );

  //     // Convert shortcuts to Map<String, List<int>>
  //     final Map<String, dynamic> shortcutsData = _shortcuts.map((key, value) {
  //       return MapEntry(key, value.map((k) => k.keyId).toList());
  //     });

  //     final nowIso = DateTime.now().toUtc().toIso8601String();

  //     // Merge existing metadata with new shortcuts
  //     final mergedData = {
  //       ...existingMetadata,
  //       'shortcuts': shortcutsData,
  //       'last_updated': nowIso,
  //     };

  //     // Update Supabase user_metadata
  //     final res = await supabase!.auth.updateUser(
  //       UserAttributes(data: mergedData),
  //     );

  //     if (res.user != null) {
  //       debugPrint('User metadata updated successfully in Supabase.');

  //       // Refresh local session to sync updated metadata
  //       await supabase!.auth.refreshSession();

  //       final refreshedUser = supabase!.auth.currentUser;
  //       debugPrint('🔁 Refreshed metadata: ${refreshedUser?.userMetadata}');

  //       // Update local model
  //       _userSettings = UserSettingsModel(
  //         userId: res.user!.id,
  //         shortcuts: Map<String, List<int>>.from(
  //           shortcutsData.map((k, v) => MapEntry(k, List<int>.from(v))),
  //         ),
  //         lastUpdated: DateTime.parse(nowIso),
  //       );
  //     } else {
  //       debugPrint(' Failed to update user metadata: ${res.toString()}');
  //     }
  //   } catch (e) {
  //     debugPrint(' Error saving shortcuts to Supabase metadata: $e');
  //   }
  // }
}

// Intent classes
class PointerIntent extends Intent {}

class PanIntent extends Intent {}

class TextIntent extends Intent {}

class StickyNoteIntent extends Intent {}

class ResetIntent extends Intent {}

class ZoomInIntent extends Intent {}

class ZoomOutIntent extends Intent {}
