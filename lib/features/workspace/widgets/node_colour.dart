import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NodeColourPicker extends StatelessWidget {
  final ValueChanged<Color> onColorSelected;
  final Color? initialColor;

  const NodeColourPicker({
    super.key,
    required this.onColorSelected,
    this.initialColor,
  });

  @override
  Widget build(BuildContext context) {
    final su = context.read<SupabaseService>();
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: 320, // Adjusted width as mode buttons are removed
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:su.isDark?Color.fromRGBO(48, 48, 48, 1): Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(
                  'Change Color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: su.isDark?Colors.white:Colors.black),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: su.isDark ? Colors.white : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Color grid
            Column(
              children: [
                // Top row
                Wrap(
                  spacing: 12, // Horizontal gap between color boxes
                  runSpacing: 12, // Vertical gap between rows
                  children:
                      secondaryColors
                          .map(
                            (color) => _buildColorBox(
                              color,
                              isSelected: initialColor?.value == color.value,
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 12),
                // Bottom row
                Wrap(
                  spacing: 12, // Horizontal gap between color boxes
                  runSpacing: 12,
                  children:
                      tertiaryColors.asMap().entries.map((entry) {
                        Color color = entry.value;
                        return _buildColorBox(
                          color,
                          isSelected: initialColor?.value == color.value,
                        );
                      }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorBox(Color color, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        onColorSelected(color);
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4), // Added border radius
          border:
              isSelected
                  ? Border.all(
                    color: Colors.blue,
                    width: 2.5,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  )
                  : Border.all(color: Colors.grey.shade300, width: 1),
        ),
      ),
    );
  }
}
