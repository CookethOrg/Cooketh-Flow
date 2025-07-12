import 'package:flutter/material.dart';

class WorkspaceDesktop extends StatelessWidget {
  const WorkspaceDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'cooketh flow',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
