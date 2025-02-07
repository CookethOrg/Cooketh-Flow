import 'dart:math';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddButton extends StatelessWidget {
  final void Function(Offset) onAdd;

  const AddButton({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(PhosphorIconsRegular.plus),
      onPressed: () {
        Offset newNodePosition = Offset(
          Random().nextDouble() * 1500, // Random X position
          Random().nextDouble() * 800, // Random Y position
        );
        onAdd(newNodePosition);
      },
      tooltip: "Add Node",
    );
  }
}
