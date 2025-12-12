import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class StickyNotesWidget extends StatelessWidget {
  final SupabaseService su;
  const StickyNotesWidget({super.key, required this.su});

  @override
  Widget build(BuildContext context) {
    // This is wrapped in a Dialog-like container based on your other widgets
    return Container(
      width: 280, // Adjusted width for better spacing
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: su.isDark ? Color.fromRGBO(48, 48, 48, 1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                  color: su.isDark ? Colors.white : Colors.black,
                ),
              ),
              IconButton(
                icon: Icon(
                  PhosphorIconsRegular.x,
                  size: 24,
                  color: su.isDark ? Colors.white : Colors.black87,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid of sticky notes
          GridView.count(
            crossAxisCount: 4, // More compact grid
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(
              tertiaryColors.length < secondaryColors.length
                  ? tertiaryColors.length
                  : secondaryColors.length,
              (index) => _buildStickyNote(
                context, // Pass context
                tertiaryColors[index],
                secondaryColors[index],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyNote(
    BuildContext context,
    Color fillColor,
    Color borderColor,
  ) {
    return GestureDetector(
      onTap: () {
        // Get the provider
        final provider = Provider.of<WorkspaceProvider>(context, listen: false);
        // Set the mode to place a sticky note with the selected color
        provider.setStickyNoteMode(fillColor);
        // Close the dialog
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
