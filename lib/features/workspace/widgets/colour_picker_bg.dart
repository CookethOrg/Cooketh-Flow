import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/core/utils/enums.dart' as en;

/// Custom painter for the saturation-value gradient area
class _SVGradientPainter extends CustomPainter {
  final double hue;

  _SVGradientPainter({required this.hue});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw the hue base color
    final hueColor = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
    canvas.drawRect(rect, Paint()..color = hueColor);

    // White gradient from left to right (saturation)
    final whiteGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [Colors.white, Colors.white.withOpacity(0.0)],
    );
    canvas.drawRect(rect, Paint()..shader = whiteGradient.createShader(rect));

    // Black gradient from bottom to top (value)
    final blackGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.black.withOpacity(0.0), Colors.black],
    );
    canvas.drawRect(rect, Paint()..shader = blackGradient.createShader(rect));
  }

  @override
  bool shouldRepaint(_SVGradientPainter oldDelegate) =>
      oldDelegate.hue != hue;
}

class ColorPickerWidget extends StatefulWidget {
  final Color initialColor;
  final Function(Color) onColorChanged;

  const ColorPickerWidget({
    super.key,
    this.initialColor = Colors.red,
    required this.onColorChanged,
  });

  @override
  _ColorPickerWidgetState createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late double _hue;
  late double _saturation;
  late double _value;
  late double _opacity;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.initialColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
    _opacity = widget.initialColor.opacity;
  }

  Color get _currentColor {
    return HSVColor.fromAHSV(_opacity, _hue, _saturation, _value).toColor();
  }

  String get _hexString {
    final color = _currentColor;
    final r = color.red.toRadixString(16).padLeft(2, '0');
    final g = color.green.toRadixString(16).padLeft(2, '0');
    final b = color.blue.toRadixString(16).padLeft(2, '0');
    return '#${r.toUpperCase()}${g.toUpperCase()}${b.toUpperCase()}';
  }

  void _notifyColor() {
    widget.onColorChanged(_currentColor);
  }

  void _onSVPanUpdate(Offset localPosition, Size size) {
    setState(() {
      _saturation = (localPosition.dx / size.width).clamp(0.0, 1.0);
      _value = 1.0 - (localPosition.dy / size.height).clamp(0.0, 1.0);
    });
    _notifyColor();
  }

  void _selectPresetColor(Color color) {
    final hsv = HSVColor.fromColor(color);
    setState(() {
      _hue = hsv.hue;
      _saturation = hsv.saturation;
      _value = hsv.value;
      _opacity = color.opacity;
    });
    _notifyColor();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
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
                'Background Colour',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  PhosphorIconsRegular.x,
                  size: 20,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Saturation-Value area (tall, nearly square)
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = width * 1.1; // Slightly taller than wide
              return GestureDetector(
                onPanStart: (details) =>
                    _onSVPanUpdate(details.localPosition, Size(width, height)),
                onPanUpdate: (details) =>
                    _onSVPanUpdate(details.localPosition, Size(width, height)),
                onTapDown: (details) =>
                    _onSVPanUpdate(details.localPosition, Size(width, height)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        CustomPaint(
                          size: Size(width, height),
                          painter: _SVGradientPainter(hue: _hue),
                        ),
                        // Selector circle
                        Positioned(
                          left: _saturation * width - 12,
                          top: (1.0 - _value) * height - 12,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // Eyedropper icon + Hue slider row
          Row(
            children: [
              Icon(
                PhosphorIconsRegular.eyedropper,
                size: 22,
                color: Colors.black87,
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildHueSlider()),
            ],
          ),
          const SizedBox(height: 12),

          // Opacity slider (aligned with hue slider)
          Padding(
            padding: const EdgeInsets.only(left: 34),
            child: _buildOpacitySlider(),
          ),
          const SizedBox(height: 20),

          // HEX row: [HEX v] [#A12525    100%]
          Row(
            children: [
              // HEX dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'HEX',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black54),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Hex value + opacity
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _hexString,
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${(_opacity * 100).round()}%',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // On this page dropdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'On this page',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.black54,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Color palette presets - 5 on first row, 2 on second
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (var color in [
                secondaryColors[0], // Green
                secondaryColors[1], // Coral Red
                secondaryColors[2], // Amber
                secondaryColors[3], // Purple
                tertiaryColors[5],  // Light Pink
                tertiaryColors[0],  // Light Green
                tertiaryColors[3],  // Light Purple
              ])
                GestureDetector(
                  onTap: () => _selectPresetColor(color),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHueSlider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const height = 16.0;
        return GestureDetector(
          onPanStart: (details) {
            setState(() {
              _hue = (details.localPosition.dx / width).clamp(0.0, 1.0) * 360;
            });
            _notifyColor();
          },
          onPanUpdate: (details) {
            setState(() {
              _hue = (details.localPosition.dx / width).clamp(0.0, 1.0) * 360;
            });
            _notifyColor();
          },
          onTapDown: (details) {
            setState(() {
              _hue = (details.localPosition.dx / width).clamp(0.0, 1.0) * 360;
            });
            _notifyColor();
          },
          child: SizedBox(
            width: width,
            height: height + 4, // Extra for thumb overflow
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 2,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height / 2),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF0000),
                          Color(0xFFFFFF00),
                          Color(0xFF00FF00),
                          Color(0xFF00FFFF),
                          Color(0xFF0000FF),
                          Color(0xFFFF00FF),
                          Color(0xFFFF0000),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (_hue / 360) * width - 10,
                  top: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor(),
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOpacitySlider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const height = 16.0;
        final baseColor = HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
        return GestureDetector(
          onPanStart: (details) {
            setState(() {
              _opacity = (details.localPosition.dx / width).clamp(0.0, 1.0);
            });
            _notifyColor();
          },
          onPanUpdate: (details) {
            setState(() {
              _opacity = (details.localPosition.dx / width).clamp(0.0, 1.0);
            });
            _notifyColor();
          },
          onTapDown: (details) {
            setState(() {
              _opacity = (details.localPosition.dx / width).clamp(0.0, 1.0);
            });
            _notifyColor();
          },
          child: SizedBox(
            width: width,
            height: height + 4,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 2,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(height / 2),
                      gradient: LinearGradient(
                        colors: [
                          baseColor.withOpacity(0.0),
                          baseColor,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: _opacity * width - 10,
                  top: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: baseColor.withOpacity(_opacity),
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 3),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Updated ToolBar to use the new ColorPickerWidget
class ColorToolBar extends StatelessWidget {
  const ColorToolBar({super.key});

  @override
  Widget build(BuildContext context) {
    final device = rh.ResponsiveLayoutHelper.getDeviceType(context);

    return Container(
      margin: EdgeInsets.only(right: 20.w),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFD9D9D9), width: 1.2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toolIcon(
            PhosphorIconsRegular.paintBucket,
            device,
            onTap: () {
              _showColorPicker(context);
            },
          ),
          _horizontaldivider(),
          _toolIcon(PhosphorIconsRegular.circlesThreePlus, device),
          _toolIcon(
            PhosphorIconsFill.circle,
            device,
            iconColor: tertiaryColors[3],
          ),
          _horizontaldivider(),
          _toolIcon(PhosphorIconsRegular.handGrabbing, device),
          _toolIcon(PhosphorIconsRegular.textT, device),
          _toolIcon(PhosphorIconsRegular.image, device),
          _toolIcon(
            PhosphorIconsFill.noteBlank,
            device,
            iconColor: tertiaryColors[6],
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: ColorPickerWidget(
              initialColor: Colors.red,
              onColorChanged: (color) {
                print('Selected color: $color');
              },
            ),
          ),
    );
  }

  Widget _toolIcon(
    IconData iconData,
    en.DeviceType device, {
    Color iconColor = Colors.black87,
    Color backgroundColor = Colors.white,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: IconButton(
        onPressed: onTap ?? () {},
        icon: Icon(iconData, size: 32.sp, color: iconColor),
        splashRadius: 28.r,
      ),
    );
  }

  Widget _horizontaldivider() {
    return Container(
      width: 24.w,
      height: 1.2.h,
      color: const Color(0xFFD9D9D9),
      margin: EdgeInsets.symmetric(vertical: 8.h),
    );
  }
}
