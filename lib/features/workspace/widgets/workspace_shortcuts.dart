// it is the file to control the keyboard shortcuts
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// define intents
class PointerIntent extends Intent {}

class PanIntent extends Intent {}

class TextIntent extends Intent {}

class StickyNoteIntent extends Intent {}

class ResetIntent extends Intent {}

class ZoomInIntent extends Intent {}

class ZoomOutIntent extends Intent {}

// define shortcuts

final Map<LogicalKeySet, Intent> workspaceShortCut = {
  LogicalKeySet(LogicalKeyboardKey.keyP): PointerIntent(),
  LogicalKeySet(LogicalKeyboardKey.keyA): PanIntent(),
  LogicalKeySet(LogicalKeyboardKey.keyT): TextIntent(),
  LogicalKeySet(LogicalKeyboardKey.keyS): StickyNoteIntent(),
  LogicalKeySet(LogicalKeyboardKey.keyR): ResetIntent(),
  LogicalKeySet(LogicalKeyboardKey.keyZ): ZoomInIntent(),
  LogicalKeySet(LogicalKeyboardKey.keyX): ZoomOutIntent(),
};
