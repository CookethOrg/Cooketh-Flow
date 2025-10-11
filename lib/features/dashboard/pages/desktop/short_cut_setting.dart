// lib/features/settings/pages/shortcut_settings_page.dart
import 'package:cookethflow/features/workspace/widgets/workspace_shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ShortcutSettingsPage extends StatelessWidget {
  const ShortcutSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ShortcutManagerr>(
        builder: (context, manager, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildShortcutTile(
                context,
                manager,
                'pointer',
                'Pointer Tool',
                'Select and move objects',
                Icons.pan_tool,
              ),
              _buildShortcutTile(
                context,
                manager,
                'pan',
                'Pan Tool',
                'Move the canvas',
                Icons.pan_tool_alt,
              ),
              _buildShortcutTile(
                context,
                manager,
                'text',
                'Text Tool',
                'Add text boxes',
                Icons.text_fields,
              ),
              _buildShortcutTile(
                context,
                manager,
                'stickyNote',
                'Sticky Note',
                'Add sticky notes',
                Icons.note,
              ),
              const Divider(height: 32),
              _buildShortcutTile(
                context,
                manager,
                'reset',
                'Reset Zoom',
                'Reset canvas zoom to 100%',
                Icons.center_focus_strong,
              ),
              _buildShortcutTile(
                context,
                manager,
                'zoomIn',
                'Zoom In',
                'Increase canvas zoom',
                Icons.zoom_in,
              ),
              _buildShortcutTile(
                context,
                manager,
                'zoomOut',
                'Zoom Out',
                'Decrease canvas zoom',
                Icons.zoom_out,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShortcutTile(
    BuildContext context,
    ShortcutManagerr manager,
    String action,
    String title,
    String description,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                manager.getShortcutLabel(action),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditDialog(context, manager, action, title),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    ShortcutManagerr manager,
    String action,
    String title,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => _ShortcutEditDialog(
            action: action,
            title: title,
            manager: manager,
          ),
    );
  }
}

class _ShortcutEditDialog extends StatefulWidget {
  final String action;
  final String title;
  final ShortcutManagerr manager;

  const _ShortcutEditDialog({
    required this.action,
    required this.title,
    required this.manager,
  });

  @override
  State<_ShortcutEditDialog> createState() => _ShortcutEditDialogState();
}

class _ShortcutEditDialogState extends State<_ShortcutEditDialog> {
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  String _error = '';
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Shortcut: ${widget.title}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Press any key combination',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Focus(
              focusNode: _focusNode,
              onKeyEvent: (node, event) {
                if (event is KeyDownEvent) {
                  setState(() {
                    _pressedKeys.add(event.logicalKey);
                    _error = '';
                  });
                } else if (event is KeyUpEvent) {
                  // Keep the keys until dialog is closed
                }
                return KeyEventResult.handled;
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: Text(
                  _pressedKeys.isEmpty
                      ? 'Waiting for input...'
                      : _pressedKeys
                          .map((key) {
                            if (key == LogicalKeyboardKey.control ||
                                key == LogicalKeyboardKey.controlLeft ||
                                key == LogicalKeyboardKey.controlRight) {
                              return 'Ctrl';
                            } else if (key == LogicalKeyboardKey.shift ||
                                key == LogicalKeyboardKey.shiftLeft ||
                                key == LogicalKeyboardKey.shiftRight) {
                              return 'Shift';
                            } else if (key == LogicalKeyboardKey.alt ||
                                key == LogicalKeyboardKey.altLeft ||
                                key == LogicalKeyboardKey.altRight) {
                              return 'Alt';
                            } else if (key == LogicalKeyboardKey.meta ||
                                key == LogicalKeyboardKey.metaLeft ||
                                key == LogicalKeyboardKey.metaRight) {
                              return 'Cmd';
                            }
                            return key.keyLabel.toUpperCase();
                          })
                          .join(' + '),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _pressedKeys.clear();
                  _error = '';
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await widget.manager.resetShortcut(widget.action);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Reset to Default'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
              _pressedKeys.isEmpty
                  ? null
                  : () async {
                    try {
                      await widget.manager.updateShortcut(
                        widget.action,
                        _pressedKeys.toList(),
                      );
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      setState(() {
                        _error = e.toString().replaceFirst('Exception: ', '');
                      });
                    }
                  },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
