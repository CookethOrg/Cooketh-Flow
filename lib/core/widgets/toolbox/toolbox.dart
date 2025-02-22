import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/widgets/toolbox/colour_picker.dart';
class CustomToolbar extends StatefulWidget {
  @override
  _CustomToolbarState createState() => _CustomToolbarState();
}

class _CustomToolbarState extends State<CustomToolbar> {
  Color selectedColor = const Color(0xffF9B9B7);

  void _selectColor(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _toolbarButton(PhosphorIconsRegular.shapes),
            _divider(),
            ColorPickerButton(
              selectedColor: selectedColor,
              onColorSelected: _selectColor,
            ),
            _divider(),
            _toolbarButton(PhosphorIconsRegular.textB),
            _toolbarButton(PhosphorIconsRegular.textItalic),
            _toolbarButton(PhosphorIconsRegular.textUnderline),
            _toolbarButton(PhosphorIconsRegular.textStrikethrough),
            _divider(),
            _toolbarButton(PhosphorIconsRegular.linkSimple),
          ],
        ),
      ),
    );
  }

  Widget _toolbarButton(IconData icon) {
    return IconButton(
      icon: Icon(icon, color: Colors.black),
      onPressed: () {},
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.black,
      margin: EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
