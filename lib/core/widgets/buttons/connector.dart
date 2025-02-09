import 'package:flutter/material.dart';

class Connector extends StatelessWidget {
  const Connector({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: (){}, icon: Icon(Icons.arrow_drop_up, color: Colors.blue,));
  }
}