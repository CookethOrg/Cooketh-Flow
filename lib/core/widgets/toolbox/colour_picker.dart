import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class ColorPickerButton extends StatefulWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;

  const ColorPickerButton({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  State<ColorPickerButton> createState() => _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  final List<Color> colors = [
    Color(0xffFAD7A0),
    Color(0xffF9B9B7),
    Color(0xFFA7C7E7),
    Color(0xffA9DFBF),
    Color(0xffC39BD3),
    Color(0xFFE0E0E0)
  ];

  Color? _tempSelectedColor;

  @override
  void initState() {
    super.initState();
    _tempSelectedColor = widget.selectedColor;
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Color>(
      onSelected: (color) {},
      tooltip: "Change node color",
      padding: EdgeInsets.zero,
      shadowColor: Colors.transparent,
      offset: Offset(-80, -15),
      menuPadding: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.black, width: 1),
      ),
      color: Colors.white,
      itemBuilder: (context) {
        return [
          PopupMenuItem<Color>(
            enabled: false,
            padding: EdgeInsets.zero, // Remove default padding
            child: Material(
              color: Colors.transparent,
              child: StatefulBuilder(
                builder: (context, setStatePopup) {
                  return IntrinsicWidth(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8), // More left & right padding
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        // children: [Text('Feature Coming Soon', style: TextStyle(fontFamily: 'Fredrick'),)],
                        children: colors.map((color) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6), // More spacing between circles
                            child: GestureDetector(
                              onTap: () {
                                setStatePopup(() {
                                  _tempSelectedColor = color;
                                });
                                widget.onColorSelected(color);
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _tempSelectedColor == color
                                        ? Colors.blue
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ];
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _tempSelectedColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1),
            ),
          ),
          SizedBox(width: 4),
          Icon(PhosphorIconsRegular.caretDown, color: Colors.black, size: 16),
        ],
      ),
    );
  }
}
