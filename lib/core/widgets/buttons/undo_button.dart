import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
class UndoButton extends StatelessWidget {
  final VoidCallback onUndo;

  const UndoButton({super.key, required this.onUndo});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      hoverColor: Colors.orange.withOpacity(0.1),
      tooltip: 'Undo',
      icon: Icon(PhosphorIconsRegular.arrowUUpLeft),
      onPressed: onUndo,
    );
  }
}
