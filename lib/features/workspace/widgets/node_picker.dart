import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cookethflow/core/utils/enums.dart' as en;

// The main NodePicker widget, now stateful
class NodePicker extends StatefulWidget {
  final ValueChanged<ShapeType>? onShapeSelected;
  final SupabaseService su;

  const NodePicker({super.key, this.onShapeSelected, required this.su});

  @override
  State<NodePicker> createState() => _NodePickerState();
}

class _NodePickerState extends State<NodePicker> {
  late final TextEditingController _searchController;
  late final List<Map<String, dynamic>> _allShapes;
  List<Map<String, dynamic>> _filteredShapes = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // Define all available shapes
    _allShapes = [
      {
        'name': 'Square',
        'drawMode': DrawMode.square,
        'shapeType': ShapeType.square,
      },
      {
        'name': 'Diamond',
        'drawMode': DrawMode.diamond,
        'shapeType': ShapeType.diamond,
      },
      {
        'name': 'Rounded Square',
        'drawMode': DrawMode.roundedSquare,
        'shapeType': ShapeType.roundedSquare,
      },
      {
        'name': 'Parallelogram',
        'drawMode': DrawMode.parallelogram,
        'shapeType': ShapeType.parallelogram,
      },
      {
        'name': 'Cylinder',
        'drawMode': DrawMode.cylinder,
        'shapeType': ShapeType.cylinder,
      },
      {
        'name': 'Circle',
        'drawMode': DrawMode.circle,
        'shapeType': ShapeType.circle,
      },
      {
        'name': 'Triangle',
        'drawMode': DrawMode.triangle,
        'shapeType': ShapeType.triangle,
      },
      {
        'name': 'Inverted Triangle',
        'drawMode': DrawMode.invertedTriangle,
        'shapeType': ShapeType.invertedTriangle,
      },
    ];

    _filteredShapes = _allShapes;

    _searchController.addListener(_filterShapes);
  }

  void _filterShapes() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredShapes =
          _allShapes.where((shape) {
            final shapeName = shape['name'].toString().toLowerCase();
            return shapeName.contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterShapes);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);
    return Consumer<WorkspaceProvider>(
      builder: (context, provider, child) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width:
                device == en.DeviceType.desktop
                    ? 340
                    : device == en.DeviceType.tab
                    ? 340
                    : 300,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color:
                  widget.su.isDark
                      ? const Color.fromRGBO(48, 48, 48, 1)
                      : Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.onShapeSelected == null ? 'Nodes' : 'Change Shape',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color:
                            widget.su.isDark
                                ? Colors.white
                                : const Color(0xFF111827),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color:
                            widget.su.isDark
                                ? Colors.white
                                : const Color(0xFF111827),
                        size: 28,
                      ),
                      onPressed: () {
                        // When closing, if we're not changing a shape, reset the mode
                        if (widget.onShapeSelected == null) {
                          provider.changeDrawMode(DrawMode.pointer);
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a shape',
                    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF9CA3AF),
                    ),
                    filled: true,
                    fillColor:
                        widget.su.isDark
                            ? const Color.fromRGBO(48, 48, 48, 1)
                            : const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14.0,
                      horizontal: 16.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(color: Color(0xFF6B7280)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Grid of shapes
                GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  itemCount: _filteredShapes.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final shape = _filteredShapes[index];
                    return GestureDetector(
                      onTap: () {
                        if (widget.onShapeSelected != null) {
                          widget.onShapeSelected!(shape['shapeType']);
                        } else {
                          provider.changeDrawMode(shape['drawMode']);
                        }
                        Navigator.of(
                          context,
                        ).pop(); // Close picker on selection
                      },
                      child: ShapeWidget(
                        shapeType: shape['shapeType'],
                        su: widget.su,
                        provider: provider,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// A widget to display a single shape
class ShapeWidget extends StatelessWidget {
  final ShapeType shapeType;
  final SupabaseService su;
  final WorkspaceProvider provider;

  const ShapeWidget({
    super.key,
    required this.shapeType,
    required this.su,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: CustomPaint(
        painter: ShapePainter(shapeType: shapeType, su: su, provider: provider),
      ),
    );
  }
}

// Custom painter to draw the shapes
class ShapePainter extends CustomPainter {
  final ShapeType shapeType;
  final SupabaseService su;
  final WorkspaceProvider provider;

  ShapePainter({
    required this.shapeType,
    required this.su,
    required this.provider,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = su.isDark ? Colors.white : Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final path = Path();
    final w = size.width;
    final h = size.height;

    switch (shapeType) {
      case ShapeType.square:
        path.addRect(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8));
        break;
      case ShapeType.diamond:
        path.moveTo(w * 0.5, h * 0.05);
        path.lineTo(w * 0.95, h * 0.5);
        path.lineTo(w * 0.5, h * 0.95);
        path.lineTo(w * 0.05, h * 0.5);
        path.close();
        break;
      case ShapeType.roundedSquare:
        path.addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8),
            const Radius.circular(8.0),
          ),
        );
        break;
      case ShapeType.parallelogram:
        path.moveTo(w * 0.1, h * 0.9);
        path.lineTo(w * 0.4, h * 0.1);
        path.lineTo(w * 0.9, h * 0.1);
        path.lineTo(w * 0.6, h * 0.9);
        path.close();
        break;
      case ShapeType.cylinder:
        final rect = Rect.fromCenter(
          center: Offset(w / 2, h / 2),
          width: w * 0.7,
          height: h * 0.6,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(rect.center.dx, rect.top),
            width: rect.width,
            height: rect.height * 0.3,
          ),
          paint,
        );
        canvas.drawArc(
          Rect.fromCenter(
            center: Offset(rect.center.dx, rect.bottom),
            width: rect.width,
            height: rect.height * 0.3,
          ),
          0,
          math.pi,
          false,
          paint,
        );
        canvas.drawLine(rect.topLeft, rect.bottomLeft, paint);
        canvas.drawLine(rect.topRight, rect.bottomRight, paint);
        return;
      case ShapeType.circle:
        path.addOval(Rect.fromLTWH(w * 0.1, h * 0.1, w * 0.8, h * 0.8));
        break;
      case ShapeType.triangle:
        path.moveTo(w * 0.5, h * 0.1);
        path.lineTo(w * 0.9, h * 0.9);
        path.lineTo(w * 0.1, h * 0.9);
        path.close();
        break;
      case ShapeType.invertedTriangle:
        path.moveTo(w * 0.1, h * 0.1);
        path.lineTo(w * 0.9, h * 0.1);
        path.lineTo(w * 0.5, h * 0.9);
        path.close();
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
