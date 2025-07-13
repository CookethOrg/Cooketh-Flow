import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class NodeOutline extends StatelessWidget {
  const NodeOutline({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: 420,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.x, size: 24, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Thickness selection buttons
            Row(
              children: [
                _buildModeButton('Thin', PhosphorIconsFill.circle, color: Colors.black),
                const SizedBox(width: 8),
                _buildModeButton('Medium', PhosphorIconsFill.circle, color: Colors.black),
                const SizedBox(width: 8),
                _buildModeButton('Thick', PhosphorIconsFill.circle, color: Colors.black),
              ],
            ),
            const SizedBox(height: 20),
            
            // Color grid
            Column(
              children: [
                // Top row (darker colors)
                Wrap(
                  spacing: 12, // Horizontal gap between color boxes
                  children: secondaryColors.map((color) => _buildColorBox(color)).toList(),
                ),
                const SizedBox(height: 8),
                // Bottom row (lighter colors)
                Wrap(
                  spacing: 12,
                  children: tertiaryColors.map((color) => _buildColorBox(color)).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(String text, IconData icon, {Color color = Colors.black}) {
    bool isSelected = text == 'Thin';
    double iconSize = text == 'Thin' ? 12.0 : text == 'Medium' ? 16.0 : 20.0; // Different sizes for Thin, Medium, Thick
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFFD9D9D9) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBox(Color color, {bool isSelected = false}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        border: isSelected 
          ? Border.all(color: Colors.blue, width: 2)
          : Border.all(color: Colors.grey.shade300, width: 1),
      ),
    );
  }
}