import 'package:flutter/material.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';


class StickyNotesWidget extends StatelessWidget {
  const StickyNotesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: 200,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sticky notes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: Icon(PhosphorIconsRegular.x, size: 24, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Grid of sticky notes with scroll
            SizedBox(
              height: 240,
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 1.0,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  _buildStickyNote(tertiaryColors[1], secondaryColors[1]),
                  _buildStickyNote(tertiaryColors[2], secondaryColors[2]),
                  _buildStickyNote(tertiaryColors[3], secondaryColors[3]),
                  _buildStickyNote(tertiaryColors[4], secondaryColors[4]),
                  _buildStickyNote(tertiaryColors[5], secondaryColors[5]),
                  _buildStickyNote(tertiaryColors[6], secondaryColors[6]),
                  _buildStickyNote(tertiaryColors[7], secondaryColors[7]),
                  _buildStickyNote(tertiaryColors[8], secondaryColors[8]),
                  _buildStickyNote(tertiaryColors[9], secondaryColors[9]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyNote(Color fillColor, Color borderColor) {
    return GestureDetector(
      onTap: () {
        print('Sticky note tapped');
      },
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}