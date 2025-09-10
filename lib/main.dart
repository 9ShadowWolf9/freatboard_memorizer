import 'package:flutter/material.dart';
import 'components/bottom_bar.dart';
import 'screens/home_page.dart';
import 'screens/tuner_page.dart';
import 'screens/settings.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Color _accentColor = AppColors.accentOptions.first;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _changeAccent(Color color) {
    setState(() {
      _accentColor = color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fretboard Memorizer',
      theme: AppTheme.light(_accentColor),
      darkTheme: AppTheme.dark(_accentColor),
      themeMode: _themeMode,
      home: MainPage(
        onThemeChanged: _toggleTheme,
        onAccentChanged: _changeAccent,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final void Function(bool isDark) onThemeChanged;
  final void Function(Color color) onAccentChanged;

  const MainPage({
    super.key,
    required this.onThemeChanged,
    required this.onAccentChanged,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomePage(),
      const TunerPage(),
      SettingsPage(
        onThemeChanged: widget.onThemeChanged,
        onAccentChanged: widget.onAccentChanged,
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
