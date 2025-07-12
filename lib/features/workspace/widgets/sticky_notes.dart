import 'package:flutter/material.dart';

class StickyNotesWidget extends StatelessWidget {
  const StickyNotesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: 320,
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
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Grid of sticky notes
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildStickyNote(
                  Color(0xFFB19CD9), // Light purple
                  Color(0xFF9B7BC8), // Darker purple for fold
                ),
                _buildStickyNote(
                  Color(0xFF87CEEB), // Sky blue
                  Color(0xFF4FC3F7), // Darker blue for fold
                ),
                _buildStickyNote(
                  Color(0xFFFFB6C1), // Light pink
                  Color(0xFFFF8A95), // Darker pink for fold
                ),
                _buildStickyNote(
                  Color(0xFFFFDDA0), // Light orange/yellow
                  Color(0xFFFFA726), // Darker orange for fold
                ),
                _buildStickyNote(
                  Color(0xFF87CEFA), // Light blue
                  Color(0xFF42A5F5), // Darker blue for fold
                ),
                _buildStickyNote(
                  Color(0xFFFFB6C1), // Light pink (duplicate)
                  Color(0xFFFF8A95), // Darker pink for fold
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyNote(Color noteColor, Color foldColor) {
    return Container(
      width: 120,
      height: 120,
      child: Stack(
        children: [
          // Main note body
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: noteColor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          
          // Bottom-right corner fold
          Positioned(
            bottom: 0,
            right: 0,
            child: ClipPath(
              clipper: CornerFoldClipper(),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: foldColor,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CornerFoldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}