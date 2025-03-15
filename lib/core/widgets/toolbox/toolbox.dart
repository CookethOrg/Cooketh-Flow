import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/widgets/toolbox/colour_picker.dart';
import 'package:cookethflow/core/widgets/toolbox/select_node.dart';

class CustomToolbar extends StatefulWidget {
  @override
  _CustomToolbarState createState() => _CustomToolbarState();
}

class _CustomToolbarState extends State<CustomToolbar> {
  Color selectedColor = const Color(0xffF9B9B7);
  IconData selectedNode = PhosphorIconsRegular.circle;

  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  bool isStrikethrough = false;

  void _selectColor(Color color) {
    setState(() {
      selectedColor = color;
    });
  }

  void _selectNode(IconData node) {
    setState(() {
      selectedNode = node;
    });
  }

  void _toggleBold() {
    setState(() {
      isBold = !isBold;
    });
  }

  void _toggleItalic() {
    setState(() {
      isItalic = !isItalic;
    });
  }

  void _toggleUnderline() {
    setState(() {
      isUnderline = !isUnderline;
    });
  }

  void _toggleStrikethrough() {
    setState(() {
      isStrikethrough = !isStrikethrough;
    });
  }

  void _showLinkDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Insert Link"),
          content: TextField(
            decoration: InputDecoration(
              hintText: "Type or paste URL",
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Insert"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SelectNode(
            //   selectedNode: selectedNode,
            //   onNodeSelected: _selectNode,
            // ),
            // _divider(),
            // ColorPickerButton(
            //   selectedColor: selectedColor,
            //   onColorSelected: _selectColor,
            // ),
            _divider(),
            _toggleableButton(
              isActive: isBold,
              activeIcon: PhosphorIconsBold.textB,
              inactiveIcon: PhosphorIconsRegular.textB,
              onPressed: _toggleBold,
            ),
            _toggleableButton(
              isActive: isItalic,
              activeIcon: PhosphorIconsBold.textItalic,
              inactiveIcon: PhosphorIconsRegular.textItalic,
              onPressed: _toggleItalic,
            ),
            _toggleableButton(
              isActive: isUnderline,
              activeIcon: PhosphorIconsBold.textUnderline,
              inactiveIcon: PhosphorIconsRegular.textUnderline,
              onPressed: _toggleUnderline,
            ),
            _toggleableButton(
              isActive: isStrikethrough,
              activeIcon: PhosphorIconsBold.textStrikethrough,
              inactiveIcon: PhosphorIconsRegular.textStrikethrough,
              onPressed: _toggleStrikethrough,
            ),
            _divider(),
            _toolbarButton(PhosphorIconsRegular.linkSimple, _showLinkDialog),
          ],
        ),
      ),
    );
  }

  Widget _toolbarButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.black),
      onPressed: onPressed,
    );
  }

  Widget _toggleableButton({
    required bool isActive,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(
        isActive ? activeIcon : inactiveIcon,
        color: isActive ? Colors.blue : Colors.black,
      ),
      onPressed: onPressed,
    );
  }

  Widget _divider() {
    return Container(
      width: 24,
      height: 1,
      color: Colors.black,
      margin: EdgeInsets.symmetric(vertical: 8),
    );
  }
}
