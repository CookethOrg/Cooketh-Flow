import 'package:flutter/material.dart';

class BuildProject extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color txtColor;
  final Color borderColor;
  const BuildProject({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.txtColor,
    required this.borderColor
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Frederik',
                fontSize: 16,
                color: txtColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
