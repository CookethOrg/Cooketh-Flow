import 'package:cookethflow/core/services/supabase_service.dart';
import 'package:cookethflow/core/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SupabaseService>(builder: (context, prov, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ToggleButtons(
          isSelected: const [true, false], // Default: light mode selected
          onPressed: (index) {
            if (index == 0) {
              prov.setTheme(true);
            } else {
              prov.setTheme(false);
            }
          },
          borderRadius: BorderRadius.circular(12),
          selectedColor: selectedItems,
          fillColor: textColor,
          borderColor: white,
          selectedBorderColor: Theme.of(context).colorScheme.primary,
          constraints: const BoxConstraints(
            minHeight: 40,
            minWidth: 80,
          ),
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wb_sunny, size: 20),
                  SizedBox(width: 8),
                  Text('Light'),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.nightlight_round, size: 20),
                  SizedBox(width: 8),
                  Text('Dark'),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
