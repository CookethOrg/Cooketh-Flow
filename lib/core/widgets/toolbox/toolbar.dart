// lib/core/widgets/toolbar.dart

import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:cookethflow/core/widgets/buttons/add_node_button.dart';
import 'package:cookethflow/core/widgets/buttons/redo_button.dart';
import 'package:cookethflow/core/widgets/buttons/undo_button.dart';
import 'package:cookethflow/core/widgets/buttons/delete_button.dart';

class Toolbar extends StatelessWidget {
  final Function() onDelete;
  final void Function() onUndo;
  final void Function() onRedo;

  const Toolbar({
    super.key,
    required this.onUndo,
    required this.onRedo,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UndoButton(onUndo: onUndo),
          const SizedBox(height: 12),
          RedoButton(onRedo: onRedo),
          const SizedBox(height: 12),
          const AddButton(),
          const SizedBox(height: 12),
          DeleteButton(onDelete: onDelete),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}