import 'package:cookethflow/models/flow_node.dart';
import 'package:cookethflow/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/widgets/toolbox/colour_picker.dart';
import 'package:cookethflow/core/widgets/toolbox/select_node.dart';
import 'package:provider/provider.dart';

class CustomToolbar extends StatelessWidget {
  CustomToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(builder: (context, pv, child) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SelectNode(
                  selectedNode: pv.selectedNodeIcon,
                  onNodeSelected: pv.selectNode,
                ),
              ),
              _divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ColorPickerButton(
                  selectedColor: pv.selectedColor,
                  onColorSelected: pv.selectColor,
                ),
              ),
              _divider(),
              _toggleableButton(
                isActive: pv.isBold,
                activeIcon: PhosphorIconsBold.textB,
                inactiveIcon: PhosphorIconsRegular.textB,
                onPressed: pv.toggleBold,
              ),
              _toggleableButton(
                isActive: pv.isItalic,
                activeIcon: PhosphorIconsBold.textItalic,
                inactiveIcon: PhosphorIconsRegular.textItalic,
                onPressed: pv.toggleItalic,
              ),
              _toggleableButton(
                isActive: pv.isUnderline,
                activeIcon: PhosphorIconsBold.textUnderline,
                inactiveIcon: PhosphorIconsRegular.textUnderline,
                onPressed: pv.toggleUnderline,
              ),
              _toggleableButton(
                isActive: pv.isStrikethrough,
                activeIcon: PhosphorIconsBold.textStrikethrough,
                inactiveIcon: PhosphorIconsRegular.textStrikethrough,
                onPressed: pv.toggleStrikethrough,
              ),
              _divider(),
              _toolbarButton(PhosphorIconsRegular.linkSimple,
                  () => pv.showLinkDialog(context)),
            ],
          ),
        ),
      );
    });
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
