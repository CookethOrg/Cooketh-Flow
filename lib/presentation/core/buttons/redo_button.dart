import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class RedoButton extends StatelessWidget {
  final VoidCallback? onRedo;

  const RedoButton({super.key, this.onRedo});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Redo',
      hoverColor: Colors.orange.withOpacity(0.1),
      icon: Icon(PhosphorIconsRegular.arrowUUpRight),
      onPressed: onRedo,
    );
  }
}
