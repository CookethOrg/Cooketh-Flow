import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CustomToolbar extends StatelessWidget {
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
            _toolbarButton(PhosphorIconsRegular.shapes), // Shapes Icon
            _divider(),
            SizedBox(width: 8),
            _colorPickerButton(),
            SizedBox(width: 8),
            _divider(),
            SizedBox(width: 8),
            _borderWidthButton(),
            SizedBox(width: 8),
            _divider(),
            SizedBox(width: 8),
            _toolbarButton(PhosphorIconsRegular.textB), // Bold
            _toolbarButton(PhosphorIconsRegular.textItalic), // Italic
            _toolbarButton(PhosphorIconsRegular.textUnderline), // Underline
            _toolbarButton(PhosphorIconsRegular.textStrikethrough), // Strikethrough
            SizedBox(width: 8),
            _divider(),
            _toolbarButton(PhosphorIconsRegular.link), // Link Icon
          ],
        ),
      ),
    );
  }

  Widget _borderWidthButton() {
    return InkWell(
      onTap: () {
        print("Text Align Button Clicked");
      },
      borderRadius: BorderRadius.circular(12),
      child: Row(
          children: [
            Icon(PhosphorIconsRegular.textAlignCenter, color: Colors.black,),
            SizedBox(width: 4),
            Icon(PhosphorIconsRegular.caretDown, color: Colors.black, size: 16,),
          ],
        ),
      );
  }

  Widget _toolbarButton(IconData icon) {
    return IconButton(
      icon: Icon(icon, color: Colors.black),
      onPressed: () {},
    );
  }

  Widget _colorPickerButton() {
    return InkWell(
      onTap: () {},
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
            Icon(PhosphorIconsRegular.caretDown, color: Colors.black, size: 16,),
          ]
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
