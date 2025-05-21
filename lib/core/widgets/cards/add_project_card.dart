import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AddProjectCard extends StatelessWidget {
  const AddProjectCard({super.key, required this.onTap});
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.orange.withOpacity(0.1),
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(10),
        dashPattern: const [16, 12], // [dash length, gap length]
        color: textColor,
        strokeWidth: 2,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(PhosphorIconsRegular.plus, size: 50, color: textColor),
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
