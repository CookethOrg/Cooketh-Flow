import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class DeleteButton extends StatelessWidget {
  final Function() onDelete;

  const DeleteButton({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(PhosphorIconsRegular.trash),
      onPressed: onDelete,
    );
  }
}
