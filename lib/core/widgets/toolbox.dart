import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomToolbar extends StatelessWidget {
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 1),
      ),
    );
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
            _toolbarButton(context, PhosphorIconsRegular.shapes, "Shapes Button Clicked"),
            _divider(),
            SizedBox(width: 8),
            _colorPickerButton(context),
            SizedBox(width: 8),
            _divider(),
            SizedBox(width: 8),
            _borderWidthButton(context),
            SizedBox(width: 8),
            _divider(),
            SizedBox(width: 8),
            _toolbarButton(context, PhosphorIconsRegular.textB, "Bold Button Clicked"),
            _toolbarButton(context, PhosphorIconsRegular.textItalic, "Italic Button Clicked"),
            _toolbarButton(context, PhosphorIconsRegular.textUnderline, "Underline Button Clicked"),
            _toolbarButton(context, PhosphorIconsRegular.textStrikethrough, "Strikethrough Button Clicked"),
            SizedBox(width: 8),
            _divider(),
            _toolbarButton(context, PhosphorIconsRegular.linkSimple, "Link Button Clicked"),
          ],
        ),
      ),
    );
  }

  Widget _borderWidthButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _showMessage(context, "Text Align Button Clicked");
      },
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Icon(PhosphorIconsRegular.textAlignCenter, color: Colors.black),
          SizedBox(width: 4),
          Icon(PhosphorIconsRegular.caretDown, color: Colors.black, size: 16),
        ],
      ),
    );
  }

  Widget _toolbarButton(BuildContext context, IconData icon, String message) {
    return IconButton(
      icon: Icon(icon, color: Colors.black),
      onPressed: () {
        _showMessage(context, message);
      },
    );
  }

  Widget _colorPickerButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _showMessage(context, "Color Picker Button Clicked");
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xffF9B9B7),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4),
          Icon(PhosphorIconsRegular.caretDown, color: Colors.black, size: 16),
        ],
      ),
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
