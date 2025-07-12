import 'package:flutter/material.dart';

class WorkspaceTablet extends StatelessWidget {
  const WorkspaceTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'cooketh flow — Tablet View',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}
