import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

/// Custom painter that draws a sticky note with a folded corner.
class _StickyNotePainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final double foldSize;

  _StickyNotePainter({
    required this.fillColor,
    required this.borderColor,
    this.foldSize = 20.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final f = foldSize;

    // Main body path (with bottom-right corner cut)
    final bodyPath = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w, h - f)
      ..lineTo(w - f, h)
      ..lineTo(0, h)
      ..close();

    final fillPaint = Paint()..color = fillColor;
    canvas.drawPath(bodyPath, fillPaint);

    // Border
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(bodyPath, borderPaint);

    // Fold triangle
    final foldPath = Path()
      ..moveTo(w - f, h)
      ..lineTo(w - f, h - f)
      ..lineTo(w, h - f)
      ..close();

    final foldPaint = Paint()..color = borderColor;
    canvas.drawPath(foldPath, foldPaint);
  }

  @override
  bool shouldRepaint(_StickyNotePainter oldDelegate) =>
      oldDelegate.fillColor != fillColor || oldDelegate.borderColor != borderColor;
}

class StickyNotesWidget extends StatelessWidget {
  final SupabaseService su;
  const StickyNotesWidget({super.key, required this.su});

  // Color indices into tertiaryColors (fill) and secondaryColors (border)
  static const List<int> _noteIndices = [3, 4, 5, 2, 6, 1];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: su.isDark ? const Color.fromRGBO(48, 48, 48, 1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
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
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: su.isDark ? Colors.white : Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  PhosphorIconsRegular.x,
                  size: 20,
                  color: su.isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2-column grid of sticky notes with folded corners
          GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: _noteIndices.map((i) {
              return _buildStickyNote(context, tertiaryColors[i], secondaryColors[i]);
            }).toList(),
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
        final provider = Provider.of<WorkspaceProvider>(context, listen: false);
        provider.setStickyNoteMode(fillColor);
        Navigator.pop(context);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: CustomPaint(
          painter: _StickyNotePainter(
            fillColor: fillColor,
            borderColor: borderColor,
            foldSize: 18.0,
          ),
        ),
      ),
    );
  }
}
