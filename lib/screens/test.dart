import 'package:flutter/material.dart';
import 'package:cookethflow/core/widgets/toolbox.dart';
import 'package:cookethflow/core/widgets/custom_pointer.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: CustomToolbar()),
          CustomPointer()
        ],
      ),
    );
  }
}
