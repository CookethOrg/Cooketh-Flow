import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
class UndoButton extends StatelessWidget {
  final VoidCallback onUndo;

  const UndoButton({super.key, required this.onUndo});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(PhosphorIconsRegular.arrowUUpLeft),
      onPressed: onUndo,
    );
  }
}
