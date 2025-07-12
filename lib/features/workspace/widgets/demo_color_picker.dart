import 'package:flutter/material.dart';
import 'dart:math' as math;


class ColorPickerWidget extends StatefulWidget {
  @override
  _ColorPickerDemoState createState() => _ColorPickerDemoState();
}

class _ColorPickerDemoState extends State<ColorPickerWidget> {
  Color pickerColor = Color(0xff443a49);
  Color currentColor = Color(0xff443a49);

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Color Picker Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: currentColor,
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Current Color: ${currentColor.toString()}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Pick a color!'),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: pickerColor,
                        onColorChanged: changeColor,
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        child: Text('Got it'),
                        onPressed: () {
                          setState(() => currentColor = pickerColor);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Text('Open Color Picker'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Material Color Picker'),
                    content: SingleChildScrollView(
                      child: MaterialPicker(
                        pickerColor: pickerColor,
                        onColorChanged: changeColor,
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        child: Text('Got it'),
                        onPressed: () {
                          setState(() => currentColor = pickerColor);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Text('Open Material Picker'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Block Color Picker'),
                    content: SingleChildScrollView(
                      child: BlockPicker(
                        pickerColor: pickerColor,
                        onColorChanged: changeColor,
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        child: Text('Got it'),
                        onPressed: () {
                          setState(() => currentColor = pickerColor);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Text('Open Block Picker'),
            ),
          ],
        ),
      ),
    );
  }
}

// HSV Color Picker Implementation
class ColorPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final bool showLabel;
  final bool enableAlpha;

  const ColorPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
    this.showLabel = true,
    this.enableAlpha = true,
  }) : super(key: key);

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late HSVColor currentHsvColor;

  @override
  void initState() {
    super.initState();
    currentHsvColor = HSVColor.fromColor(widget.pickerColor);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Color Wheel
        Container(
          width: 250,
          height: 250,
          child: CustomPaint(
            painter: ColorWheelPainter(currentHsvColor),
            child: GestureDetector(
              onPanUpdate: (details) {
                RenderBox box = context.findRenderObject() as RenderBox;
                Offset localOffset = box.globalToLocal(details.globalPosition);
                _updateColorFromWheel(localOffset, Size(250, 250));
              },
            ),
          ),
        ),
        SizedBox(height: 20),
        // Hue Slider
        Container(
          width: 250,
          height: 20,
          child: CustomPaint(
            painter: HueSliderPainter(),
            child: GestureDetector(
              onPanUpdate: (details) {
                RenderBox box = context.findRenderObject() as RenderBox;
                Offset localOffset = box.globalToLocal(details.globalPosition);
                double hue = (localOffset.dx / 250) * 360;
                hue = hue.clamp(0.0, 360.0);
                setState(() {
                  currentHsvColor = currentHsvColor.withHue(hue);
                  widget.onColorChanged(currentHsvColor.toColor());
                });
              },
            ),
          ),
        ),
        SizedBox(height: 20),
        // Alpha Slider (if enabled)
        if (widget.enableAlpha) ...[
          Container(
            width: 250,
            height: 20,
            child: CustomPaint(
              painter: AlphaSliderPainter(currentHsvColor.toColor()),
              child: GestureDetector(
                onPanUpdate: (details) {
                  RenderBox box = context.findRenderObject() as RenderBox;
                  Offset localOffset = box.globalToLocal(details.globalPosition);
                  double alpha = (localOffset.dx / 250);
                  alpha = alpha.clamp(0.0, 1.0);
                  setState(() {
                    currentHsvColor = currentHsvColor.withAlpha(alpha);
                    widget.onColorChanged(currentHsvColor.toColor());
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
        // Color Preview
        Container(
          width: 250,
          height: 50,
          decoration: BoxDecoration(
            color: currentHsvColor.toColor(),
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        // Color Values Display
        if (widget.showLabel) ...[
          SizedBox(height: 10),
          Text(
            'HSV: ${currentHsvColor.hue.round()}°, ${(currentHsvColor.saturation * 100).round()}%, ${(currentHsvColor.value * 100).round()}%',
            style: TextStyle(fontSize: 12),
          ),
          Text(
            'RGB: ${(currentHsvColor.toColor().red)}, ${(currentHsvColor.toColor().green)}, ${(currentHsvColor.toColor().blue)}',
            style: TextStyle(fontSize: 12),
          ),
          Text(
            'HEX: #${currentHsvColor.toColor().value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ],
    );
  }

  void _updateColorFromWheel(Offset offset, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final delta = offset - center;
    final distance = delta.distance;
    final radius = size.width / 2;

    if (distance <= radius) {
      final angle = math.atan2(delta.dy, delta.dx);
      final hue = (angle * 180 / math.pi + 360) % 360;
      final saturation = (distance / radius).clamp(0.0, 1.0);

      setState(() {
        currentHsvColor = currentHsvColor.withHue(hue).withSaturation(saturation);
        widget.onColorChanged(currentHsvColor.toColor());
      });
    }
  }
}

// Material Color Picker Implementation
class MaterialPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final bool showLabel;

  const MaterialPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
    this.showLabel = true,
  }) : super(key: key);

  @override
  _MaterialPickerState createState() => _MaterialPickerState();
}

class _MaterialPickerState extends State<MaterialPicker> {
  static const List<MaterialColor> materialColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  MaterialColor? selectedColor;
  Color? selectedShade;

  @override
  void initState() {
    super.initState();
    _findClosestMaterialColor();
  }

  void _findClosestMaterialColor() {
    Color targetColor = widget.pickerColor;
    MaterialColor? closest;
    Color? closestShade;
    double minDistance = double.infinity;

    for (MaterialColor color in materialColors) {
      List<int> shades = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];
      for (int shade in shades) {
        Color? shadeColor = color[shade];
        if (shadeColor != null) {
          double distance = _colorDistance(targetColor, shadeColor);
          if (distance < minDistance) {
            minDistance = distance;
            closest = color;
            closestShade = shadeColor;
          }
        }
      }
    }

    selectedColor = closest;
    selectedShade = closestShade;
  }

  double _colorDistance(Color c1, Color c2) {
    return math.sqrt(
      math.pow(c1.red - c2.red, 2) +
      math.pow(c1.green - c2.green, 2) +
      math.pow(c1.blue - c2.blue, 2)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Material Color Selection
        Container(
          width: 300,
          height: 200,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              childAspectRatio: 1,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: materialColors.length,
            itemBuilder: (context, index) {
              MaterialColor color = materialColors[index];
              bool isSelected = selectedColor == color;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                    selectedShade = color[500];
                    widget.onColorChanged(color[500]!);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color[500],
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey,
                      width: isSelected ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
        // Shade Selection
        if (selectedColor != null) ...[
          Text('Shades:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Container(
            width: 300,
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]
                  .map((shade) {
                Color? shadeColor = selectedColor![shade];
                if (shadeColor == null) return SizedBox.shrink();
                
                bool isSelected = selectedShade == shadeColor;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedShade = shadeColor;
                      widget.onColorChanged(shadeColor);
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: shadeColor,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        shade.toString(),
                        style: TextStyle(
                          color: shade < 400 ? Colors.black : Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        SizedBox(height: 20),
        // Color Preview
        Container(
          width: 300,
          height: 50,
          decoration: BoxDecoration(
            color: selectedShade ?? Colors.grey,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        if (widget.showLabel && selectedShade != null) ...[
          SizedBox(height: 10),
          Text(
            'RGB: ${selectedShade!.red}, ${selectedShade!.green}, ${selectedShade!.blue}',
            style: TextStyle(fontSize: 12),
          ),
          Text(
            'HEX: #${selectedShade!.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ],
    );
  }
}

// Block Color Picker Implementation
class BlockPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;
  final List<Color>? availableColors;

  const BlockPicker({
    Key? key,
    required this.pickerColor,
    required this.onColorChanged,
    this.availableColors,
  }) : super(key: key);

  @override
  _BlockPickerState createState() => _BlockPickerState();
}

class _BlockPickerState extends State<BlockPicker> {
  late List<Color> colors;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    colors = widget.availableColors ?? _getDefaultColors();
    selectedColor = widget.pickerColor;
  }

  List<Color> _getDefaultColors() {
    return [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.black,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              Color color = colors[index];
              bool isSelected = selectedColor == color;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedColor = color;
                    widget.onColorChanged(color);
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey,
                      width: isSelected ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),
        Container(
          width: 300,
          height: 50,
          decoration: BoxDecoration(
            color: selectedColor,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        SizedBox(height: 10),
        Text(
          'RGB: ${selectedColor.red}, ${selectedColor.green}, ${selectedColor.blue}',
          style: TextStyle(fontSize: 12),
        ),
        Text(
          'HEX: #${selectedColor.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

// Custom Painters for Color Wheel and Sliders
class ColorWheelPainter extends CustomPainter {
  final HSVColor hsvColor;

  ColorWheelPainter(this.hsvColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw color wheel
    for (int i = 0; i < 360; i++) {
      for (double r = 0; r < radius; r += 1) {
        final paint = Paint()
          ..color = HSVColor.fromAHSV(1.0, i.toDouble(), r / radius, hsvColor.value).toColor();
        
        final x = center.dx + r * math.cos(i * math.pi / 180);
        final y = center.dy + r * math.sin(i * math.pi / 180);
        
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }

    // Draw selection indicator
    final selectedAngle = hsvColor.hue * math.pi / 180;
    final selectedRadius = hsvColor.saturation * radius;
    final selectedX = center.dx + selectedRadius * math.cos(selectedAngle);
    final selectedY = center.dy + selectedRadius * math.sin(selectedAngle);
    
    canvas.drawCircle(
      Offset(selectedX, selectedY),
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class HueSliderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      colors: [
        HSVColor.fromAHSV(1.0, 0, 1.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, 60, 1.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, 120, 1.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, 180, 1.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, 240, 1.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, 300, 1.0, 1.0).toColor(),
        HSVColor.fromAHSV(1.0, 360, 1.0, 1.0).toColor(),
      ],
    );
    
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AlphaSliderPainter extends CustomPainter {
  final Color color;

  AlphaSliderPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Draw checkerboard pattern
    final checkerPaint = Paint()..color = Colors.grey[300]!;
    final checkerSize = 10.0;
    for (double x = 0; x < size.width; x += checkerSize * 2) {
      for (double y = 0; y < size.height; y += checkerSize * 2) {
        canvas.drawRect(Rect.fromLTWH(x, y, checkerSize, checkerSize), checkerPaint);
        canvas.drawRect(Rect.fromLTWH(x + checkerSize, y + checkerSize, checkerSize, checkerSize), checkerPaint);
      }
    }
    
    // Draw alpha gradient
    final gradient = LinearGradient(
      colors: [
        color.withAlpha(0),
        color.withAlpha(255),
      ],
    );
    
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}