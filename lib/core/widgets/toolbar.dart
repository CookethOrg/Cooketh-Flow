// lib/core/widgets/toolbar.dart

import 'package:flutter/material.dart';
import 'package:cookethflow/core/widgets/buttons/add_node_button.dart';
import 'package:cookethflow/core/widgets/buttons/redo_button.dart';
import 'package:cookethflow/core/widgets/buttons/undo_button.dart';
import 'package:cookethflow/core/widgets/buttons/delete_button.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class Toolbar extends StatelessWidget {
  final Function() onDelete;
  final void Function() onUndo;
  final void Function() onRedo;

  const Toolbar({super.key, required this.onUndo, required this.onRedo, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      top: 24,
      child: Container(
        padding: EdgeInsets.all(16),
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
            SizedBox(height: 12),
            DeleteButton(onDelete: onDelete), // Use the DeleteButton that was already defined
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}