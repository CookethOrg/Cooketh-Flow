import 'package:flutter/material.dart';
import 'package:cookethflow/core/widgets/buttons/add_node_button.dart';
import 'package:cookethflow/core/widgets/buttons/redo_button.dart';
import 'package:cookethflow/core/widgets/buttons/undo_button.dart';

class Toolbar extends StatelessWidget {
  final void Function() onAdd;
  final void Function() onUndo;
  final void Function() onRedo;

  const Toolbar({super.key, required this.onAdd, required this.onUndo, required this.onRedo});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      top: 24,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UndoButton(onUndo: onUndo),
            SizedBox(height: 12),
            RedoButton(onRedo: onRedo),
            SizedBox(height: 12),
            AddButton(),
          ],
        ),
      ),
    );
  }
}
