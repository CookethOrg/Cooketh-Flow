import 'package:flutter/material.dart';
import 'package:cookethflow/core/widgets/toolbox.dart';
import 'package:cookethflow/core/widgets/custom_cursor.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: CustomToolbar()), // Your actual workspace
          CustomCursor(), // Overlays the custom cursor
        ],
      ),
    );
  }
}
