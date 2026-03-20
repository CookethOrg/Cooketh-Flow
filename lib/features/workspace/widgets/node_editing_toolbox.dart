import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/features/models/canvas_models/objects/connector_object.dart';
import 'package:cookethflow/features/models/canvas_models/objects/text_box_object.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:cookethflow/features/workspace/widgets/connector_customizer.dart';
import 'package:cookethflow/features/workspace/widgets/node_colour.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class NodeEditingToolbox extends StatelessWidget {
  const NodeEditingToolbox({super.key});

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _buildIconButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? color,
    required SupabaseService su,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: onPressed,
      color: color ?? (su.isDark ? Colors.white : Colors.black87),
      splashRadius: 18,
      tooltip: tooltip,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WorkspaceProvider, SupabaseService>(
      builder: (context, provider, su, child) {
        final selectedObjectId = provider.currentlySelectedObjectId;

        if (selectedObjectId == null) {
          return const SizedBox.shrink();
        }

        final object = provider.canvasObjects[selectedObjectId];
        if (object == null) {
          return const SizedBox.shrink();
        }

        final isConnector = object is ConnectorObject;
        final buttons = <Widget>[];

        if (isConnector) {
          _buildConnectorButtons(context, buttons, provider, su, object);
        } else {
          _buildShapeButtons(context, buttons, provider, su, object);
        }

        return Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: su.isDark
                  ? const Color.fromRGBO(48, 48, 48, 1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: buttons),
          ),
        );
      },
    );
  }

  void _buildShapeButtons(
    BuildContext context,
    List<Widget> buttons,
    WorkspaceProvider provider,
    SupabaseService su,
    dynamic object,
  ) {
    final controller = provider.selectedObjectQuillController;
    final canChangeColor =
        object is! TextBoxObject && object is! ConnectorObject;

    // Color picker dot
    if (canChangeColor) {
      buttons.add(
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => NodeColourPicker(
                initialColor: object.color,
                onColorSelected: (color) {
                  provider.changeObjectColor(color);
                  Navigator.of(context).pop();
                },
              ),
            );
          },
          child: Tooltip(
            message: 'Node Color',
            child: Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: object.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400, width: 1.5),
              ),
            ),
          ),
        ),
      );
      buttons.add(_buildDivider());
    }

    // Font size dropdown
    buttons.add(
      _FontSizeDropdown(controller: controller, su: su),
    );
    buttons.add(_buildDivider());

    // Bold
    buttons.add(
      _WholeTextToggleButton(
        controller: controller,
        attribute: Attribute.bold,
        icon: Icons.format_bold,
        tooltip: 'Bold',
        su: su,
      ),
    );

    // Italic
    buttons.add(
      _WholeTextToggleButton(
        controller: controller,
        attribute: Attribute.italic,
        icon: Icons.format_italic,
        tooltip: 'Italic',
        su: su,
      ),
    );

    // Underline
    buttons.add(
      _WholeTextToggleButton(
        controller: controller,
        attribute: Attribute.underline,
        icon: Icons.format_underline,
        tooltip: 'Underline',
        su: su,
      ),
    );

    // Strikethrough
    buttons.add(
      _WholeTextToggleButton(
        controller: controller,
        attribute: Attribute.strikeThrough,
        icon: Icons.format_strikethrough,
        tooltip: 'Strikethrough',
        su: su,
      ),
    );

    buttons.add(_buildDivider());

    // Link
    buttons.add(
      _buildIconButton(
        context,
        icon: Icons.link,
        onPressed: () {
          _showLinkDialog(context, controller);
        },
        tooltip: 'Insert Link',
        su: su,
      ),
    );

    buttons.add(_buildDivider());

    // Delete
    buttons.add(
      _buildIconButton(
        context,
        icon: PhosphorIcons.trash(),
        onPressed: () {
          provider.deleteSelectedObject();
        },
        tooltip: 'Delete',
        color: Colors.redAccent,
        su: su,
      ),
    );
  }

  void _buildConnectorButtons(
    BuildContext context,
    List<Widget> buttons,
    WorkspaceProvider provider,
    SupabaseService su,
    ConnectorObject object,
  ) {
    buttons.add(
      _buildIconButton(
        context,
        icon: PhosphorIcons.lineSegment(),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => ConnectorCustomizer(
              initialColor: object.color,
              initialType: object.connectionType,
              initialThickness: object.thickness,
              onStyleSelected: (color, type, thickness) {
                provider.changeConnectorStyle(color, type, thickness);
              },
              su: su,
            ),
          );
        },
        tooltip: 'Change Connector Style',
        su: su,
      ),
    );
    buttons.add(_buildDivider());
    buttons.add(
      _buildIconButton(
        context,
        icon: PhosphorIcons.trash(),
        onPressed: () {
          provider.deleteSelectedObject();
        },
        tooltip: 'Delete',
        color: Colors.redAccent,
        su: su,
      ),
    );
  }

  void _showLinkDialog(BuildContext context, QuillController controller) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert Link'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'https://example.com',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final url = textController.text.trim();
              if (url.isNotEmpty) {
                controller.formatSelection(LinkAttribute(url));
              }
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}

/// Toggles formatting on the entire document text.
class _WholeTextToggleButton extends StatelessWidget {
  final QuillController controller;
  final Attribute attribute;
  final IconData icon;
  final String tooltip;
  final SupabaseService su;

  const _WholeTextToggleButton({
    required this.controller,
    required this.attribute,
    required this.icon,
    required this.tooltip,
    required this.su,
  });

  bool _isWholeDocFormatted() {
    final doc = controller.document;
    final length = doc.length;
    if (length <= 1) return false;
    final styles = doc.collectAllStyles(0, length - 1);
    // Check if the attribute is present across the whole document
    for (final style in styles) {
      if (!style.containsKey(attribute.key)) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final isActive = _isWholeDocFormatted();
        return IconButton(
          icon: Icon(icon, size: 20),
          onPressed: () {
            final doc = controller.document;
            final length = doc.length;
            if (length <= 1) return;
            // Select all text, apply/remove attribute, then restore cursor
            final savedSelection = controller.selection;
            controller.updateSelection(
              TextSelection(baseOffset: 0, extentOffset: length - 1),
              ChangeSource.local,
            );
            if (isActive) {
              controller.formatSelection(Attribute.clone(attribute, null));
            } else {
              controller.formatSelection(attribute);
            }
            // Restore original selection
            controller.updateSelection(savedSelection, ChangeSource.local);
          },
          color: isActive
              ? Colors.blue
              : (su.isDark ? Colors.white : Colors.black87),
          splashRadius: 18,
          tooltip: tooltip,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
        );
      },
    );
  }
}

/// A font size dropdown that applies to the entire document.
class _FontSizeDropdown extends StatelessWidget {
  final QuillController controller;
  final SupabaseService su;

  const _FontSizeDropdown({
    required this.controller,
    required this.su,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        final style = controller.getSelectionStyle();
        final sizeAttr = style.attributes[Attribute.size.key];
        String currentLabel = 'Aa';
        if (sizeAttr != null && sizeAttr.value != null) {
          currentLabel = '${sizeAttr.value}';
        }

        return PopupMenuButton<dynamic>(
          tooltip: 'Font Size',
          onSelected: (value) {
            final doc = controller.document;
            final length = doc.length;
            if (length <= 1) return;
            final savedSelection = controller.selection;
            controller.updateSelection(
              TextSelection(baseOffset: 0, extentOffset: length - 1),
              ChangeSource.local,
            );
            if (value == 0) {
              controller.formatSelection(Attribute.clone(Attribute.size, null));
            } else {
              controller.formatSelection(Attribute.fromKeyValue('size', value));
            }
            controller.updateSelection(savedSelection, ChangeSource.local);
          },
          itemBuilder: (context) => [
            _sizeItem('Small', 'small'),
            _sizeItem('Normal', 0),
            _sizeItem('Large', 'large'),
            _sizeItem('Huge', 'huge'),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: su.isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                  color: su.isDark ? Colors.white : Colors.black87,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  PopupMenuItem<dynamic> _sizeItem(String label, dynamic value) {
    return PopupMenuItem(value: value, child: Text(label));
  }
}
