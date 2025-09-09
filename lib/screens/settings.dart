import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final void Function(bool isDark) onThemeChanged;

  const SettingsPage({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SwitchListTile(
          title: const Text("Dark Mode"),
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: onThemeChanged,
        ),
      ),
    );
  }
}
