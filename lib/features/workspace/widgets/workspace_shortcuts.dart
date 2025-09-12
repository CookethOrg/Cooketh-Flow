import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PointerIntent extends Intent {}

class PanIntent extends Intent {}

class TextIntent extends Intent {}

class StickyNoteIntent extends Intent {}

class ResetIntent extends Intent {}

class ZoomInIntent extends Intent {}

class ZoomOutIntent extends Intent {}

class EscapeIntent extends Intent {}

final Map<LogicalKeySet, Intent> workspaceShortCut = {
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP): PointerIntent(),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyA): PanIntent(),
  LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.keyT): TextIntent(),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): StickyNoteIntent(),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR): ResetIntent(),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyZ): ZoomInIntent(),
  LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyX): ZoomOutIntent(),
  LogicalKeySet(LogicalKeyboardKey.escape) : EscapeIntent(),
};