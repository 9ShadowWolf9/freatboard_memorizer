import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  final void Function(bool isDark) onThemeChanged;
  final void Function(Color color) onAccentChanged;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.onAccentChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentAccent = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text("Dark Theme"),
              value: isDark,
              onChanged: (value) => onThemeChanged(value),
            ),
            const SizedBox(height: 20),
            const Text(
              "Accent Color",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: AppColors.accentOptions.map((color) {
                final bool isSelected = color.value == currentAccent.value;
                return GestureDetector(
                  onTap: () => onAccentChanged(color),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 28)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
