import 'package:cookethflow/core/theme/colors.dart';
import 'package:cookethflow/core/helpers/responsive_layout.helper.dart' as rh;
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class NodeColourPicker extends StatelessWidget {
  const NodeColourPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkspaceProvider>(
      builder: (context, provider, child) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(
                        PhosphorIconsRegular.x,
                        size: 24,
                        color: Colors.black54,
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Mode selection buttons
                Row(
                  children: [
                    _buildModeButton(
                      'Fill',
                      PhosphorIconsRegular.square,
                      color: Colors.black,
                      // You'll need to manage the selected fill mode in the provider too
                      // For now, it's hardcoded to 'Fill' as selected
                      isSelected: true, // Assuming 'Fill' is the default/always selected mode for now
                    ),
                    const SizedBox(width: 8),
                    _buildModeButton(
                      'Transparent',
                      PhosphorIconsFill.square,
                      color: const Color.fromARGB(88, 0, 0, 0),
                      isSelected: false,
                    ),
                    const SizedBox(width: 8),
                    _buildModeButton(
                      'No Fill',
                      PhosphorIconsFill.square,
                      color: Colors.black,
                      isSelected: false,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Color grid
                Column(
                  children: [
                    // Top row
                    Wrap(
                      spacing: 12, // Horizontal gap between color boxes
                      children:
                          secondaryColors
                              .map((color) => _buildColorBox(
                                color,
                                provider,
                                isSelected: provider.currentWorkspaceColor == color, // Corrected: Check selection for secondaryColors
                              ))
                              .toList(),
                    ),
                    const SizedBox(height: 8),
                    // Bottom row
                    Wrap(
                      spacing: 12, // Horizontal gap between color boxes
                      children:
                          tertiaryColors.asMap().entries.map((entry) {
                            Color color = entry.value;
                            return _buildColorBox(
                              color,
                              provider,
                              isSelected: provider.currentWorkspaceColor == color, // Corrected: Check selection for tertiaryColors
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeButton(
    String text,
    IconData icon, {
    Color color = Colors.black,
    required bool isSelected, // Make isSelected required
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0XFFD9D9D9) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBox(
    Color color,
    WorkspaceProvider provider, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () {
        provider.changeWorkspaceColor(color);
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          border:
              isSelected
                  ? Border.all(color: Colors.blue, width: 2)
                  : Border.all(color: Colors.grey.shade300, width: 1),
        ),
      ),
    );
  }
}