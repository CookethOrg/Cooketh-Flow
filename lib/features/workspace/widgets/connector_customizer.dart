import 'package:cookethflow/core/providers/supabase_provider.dart';
import 'package:cookethflow/core/theme/app_theme.dart';
import 'package:cookethflow/core/utils/enums.dart';
import 'package:cookethflow/features/workspace/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:provider/provider.dart';

class ConnectorCustomizer extends StatefulWidget {
  final Color initialColor;
  final ConnectionType initialType;
  final double initialThickness;
  final Function(Color, ConnectionType, double) onStyleSelected;
  final SupabaseService su;

  const ConnectorCustomizer({
    super.key,
    required this.initialColor,
    required this.initialType,
    required this.initialThickness,
    required this.onStyleSelected,
    required this.su,
  });

  @override
  _ConnectorCustomizerState createState() => _ConnectorCustomizerState();
}

class _ConnectorCustomizerState extends State<ConnectorCustomizer> {
  late Color _selectedColor;
  late ConnectionType _selectedType;
  late double _selectedThickness;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _selectedType = widget.initialType;
    _selectedThickness = widget.initialThickness;
  }

  Widget _buildModeButton(String text, ConnectionType type, SupabaseService supa) {
    bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
        widget.onStyleSelected(_selectedColor, _selectedType, _selectedThickness);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: supa.isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  Widget _buildThicknessButton(String text, double thickness,SupabaseService supa) {
    bool isSelected = _selectedThickness == thickness;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedThickness = thickness;
        });
        widget.onStyleSelected(_selectedColor, _selectedType, _selectedThickness);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style:  TextStyle(
            fontSize: 14,
            color: supa.isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  Widget _buildColorBox(Color color) {
    bool isSelected = _selectedColor == color;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
        widget.onStyleSelected(_selectedColor, _selectedType, _selectedThickness);
      },
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          border: isSelected
              ? Border.all(color: Colors.blue, width: 2)
              : Border.all(color: Colors.grey.shade300, width: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupabaseService>(
      builder: (context,supa,child) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.su.isDark ? const Color.fromRGBO(48, 48, 48, 1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(PhosphorIconsRegular.x, size: 24, color: widget.su.isDark ? Colors.white70 : Colors.black54),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
        
                Row(
                  children: [
                    _buildModeButton('Solid', ConnectionType.solid,supa),
                    const SizedBox(width: 8),
                    _buildModeButton('Dashed', ConnectionType.dashed,supa),
                    const SizedBox(width: 8),
                    _buildModeButton('Dotted', ConnectionType.dotted,supa),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    _buildThicknessButton('Thin', 1.0,supa),
                    const SizedBox(width: 8),
                    _buildThicknessButton('Medium', 2.0,supa),
                    const SizedBox(width: 8),
                    _buildThicknessButton('Thick', 4.0,supa),
                  ],
                ),
                const SizedBox(height: 20),
        
                Column(
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: secondaryColors.map((color) => _buildColorBox(color)).toList(),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: tertiaryColors.map((color) => _buildColorBox(color)).toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}