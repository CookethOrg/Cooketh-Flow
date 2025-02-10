import 'package:flutter/material.dart';

class Connector extends StatelessWidget {
  const Connector({super.key, this.color, required this.icon});
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 10,
      width: 10,
      child: IconButton(
          onPressed: () {},
          style: IconButton.styleFrom(fixedSize: Size(10, 5)),
          icon: Icon(
            icon,
            color: color ?? Colors.blue,
            // size: 25,
          )),
    );
  }
}
