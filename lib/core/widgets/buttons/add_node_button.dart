import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class AddButton extends StatelessWidget {
  final void Function() onAdd;

  const AddButton({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, pv, child) {
        return IconButton(
          icon: Icon(PhosphorIconsRegular.plus),
          onPressed: () => pv.addNode(),
          tooltip: "Add Node",
        );
      },
    );
  }
}
