// it is the file to control the keyboard shortcuts
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


// define intents
class PointerIntent extends Intent {}

class PanIntent extends Intent {}

class TextIntent extends Intent {}

// define shortcuts

final Map<LogicalKeySet, Intent> workspaceShortCut = {
  LogicalKeySet(LogicalKeyboardKey.keyP): PointerIntent(),
  LogicalKeySet(LogicalKeyboardKey.keyA): PanIntent(),
  LogicalKeySet(LogicalKeyboardKey.keyT): TextIntent(),
};


