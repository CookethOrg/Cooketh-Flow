import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter/material.dart';

class ExportOptionWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const ExportOptionWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      hoverColor: Colors.orange.withOpacity(0.1),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: textColor, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Frederik',
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
