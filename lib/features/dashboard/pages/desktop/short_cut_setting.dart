import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/theme/app_theme.dart';
import 'package:cookethflow/features/workspace/widgets/workspace_shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class ShortcutSettingsPage extends StatelessWidget {
  const ShortcutSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<ShortcutManagerr, SupabaseService>(
        builder: (context, manager, su, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildShortcutTile(
                context,
                manager,
                'pointer',
                'Pointer Tool',
                'Select and move objects',
                PhosphorIconsRegular.cursor,
                su,
              ),
              _buildShortcutTile(
                context,
                manager,
                'pan',
                'Pan Tool',
                'Move the canvas',
                PhosphorIconsRegular.hand,
                su,
              ),
              _buildShortcutTile(
                context,
                manager,
                'text',
                'Text Tool',
                'Add text boxes',
                PhosphorIconsRegular.textT,
                su,
              ),
              _buildShortcutTile(
                context,
                manager,
                'stickyNote',
                'Sticky Note',
                'Add sticky notes',
                PhosphorIconsRegular.note,
                su,
              ),
              const Divider(height: 32),
              _buildShortcutTile(
                context,
                manager,
                'reset',
                'Reset Zoom',
                'Reset canvas zoom to 100%',
                PhosphorIconsRegular.arrowsOutCardinal,
                su,
              ),
              _buildShortcutTile(
                context,
                manager,
                'zoomIn',
                'Zoom In',
                'Increase canvas zoom',
                PhosphorIconsRegular.magnifyingGlassPlus,
                su,
              ),
              _buildShortcutTile(
                context,
                manager,
                'zoomOut',
                'Zoom Out',
                'Decrease canvas zoom',
                PhosphorIconsRegular.magnifyingGlassMinus,
                su,
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
    SupabaseService su,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style:
              !su.isDark
                  ? AppTheme.light().textTheme.displaySmall
                  : AppTheme.dark().textTheme.displaySmall,
        ),
        subtitle: Text(
          description,
          style:
              !su.isDark
                  ? AppTheme.light().textTheme.headlineMedium
                  : AppTheme.dark().textTheme.headlineMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.light().primaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                manager.getShortcutLabel(action),
                style:
                    !su.isDark
                        ? AppTheme.light().textTheme.headlineMedium
                        : AppTheme.dark().textTheme.headlineMedium,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(PhosphorIconsRegular.pencilSimple),
              onPressed:
                  () => _showEditDialog(context, manager, action, title, su),
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
    SupabaseService su,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => _ShortcutEditDialog(
            action: action,
            title: title,
            manager: manager,
            su: su,
          ),
    );
  }
}

class _ShortcutEditDialog extends StatefulWidget {
  final String action;
  final String title;
  final ShortcutManagerr manager;
  final SupabaseService su;

  const _ShortcutEditDialog({
    required this.action,
    required this.title,
    required this.manager,
    required this.su,
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
      title: Text(
        'Edit Shortcut: ${widget.title}',
        style:
            !widget.su.isDark
                ? AppTheme.light().textTheme.displaySmall
                : AppTheme.dark().textTheme.displaySmall,
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Press any key combination',
              style:
                  !widget.su.isDark
                      ? AppTheme.light().textTheme.displaySmall
                      : AppTheme.dark().textTheme.displaySmall,
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
                  color: widget.su.isDark ? Colors.white : Colors.black,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.su.isDark ? Colors.black : Colors.white,
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
              icon: Icon(PhosphorIconsRegular.x),
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
