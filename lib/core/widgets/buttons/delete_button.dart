import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DeleteButton extends StatelessWidget {
  final Function() onDelete;

  const DeleteButton({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Delete selected node',
      hoverColor: Colors.red.withOpacity(0.1),
      icon: Icon(PhosphorIconsRegular.trash, color: Colors.red,),
      onPressed: onDelete,
    );
  }
}
