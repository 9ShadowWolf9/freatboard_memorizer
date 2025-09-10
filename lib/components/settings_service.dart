import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyIsDark = 'isDark';
  static const _keyAccent = 'accent';

  Future<void> saveThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsDark, isDark);
  }

  Future<void> saveAccent(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyAccent, color.value);
  }

  Future<bool> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsDark) ?? false; // default: light
  }

  Future<Color> loadAccent() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_keyAccent);
    return colorValue != null ? Color(colorValue) : Colors.blue; // default
  }
}
