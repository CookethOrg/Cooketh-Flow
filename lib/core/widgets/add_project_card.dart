import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';

class AddProjectCard extends StatelessWidget {
  const AddProjectCard({super.key, required this.onTap});
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        dashPattern: const [16, 12], // [dash length, gap length]
        color: Colors.black,
        strokeWidth: 2,
        child: Center(
          child: Container(
            width: 280,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.add, size: 50, color: Colors.black),
                SizedBox(height: 8),
                Text(
                  'Create Project',
                  style: TextStyle(fontFamily: 'Frederik', fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}