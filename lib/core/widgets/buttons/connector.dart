import 'package:flutter/material.dart';

class Connector extends StatelessWidget {
  const Connector({super.key, this.color, required this.icon});
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 10,
      // width: 10,
      child: GestureDetector(
        onTap: (){},
        child: Icon(
            icon,
            color: color ?? Colors.blue,
            // size: 25,
          ),
      ),
    );
  }
}
