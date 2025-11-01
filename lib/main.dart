import 'package:flutter/material.dart';
import 'components/bottom_bar.dart';
import 'screens/home_page.dart';
import 'screens/tuner_page.dart';
import 'screens/settings.dart';
import 'screens/account_page.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'components/settings_service.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SettingsService _settingsService = SettingsService();

  ThemeMode _themeMode = ThemeMode.light;
  Color _accentColor = AppColors.accentOptions.first;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    bool isDark = await _settingsService.loadThemeMode();
    Color accent = await _settingsService.loadAccent();

    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _accentColor = accent;
      _isLoaded = true;
    });
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    _settingsService.saveThemeMode(isDark);
  }

  void _changeAccent(Color color) {
    setState(() {
      _accentColor = color;
    });
    _settingsService.saveAccent(color);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const SizedBox.shrink();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fretboard Memorizer',
      theme: AppTheme.light(_accentColor),
      darkTheme: AppTheme.dark(_accentColor),
      themeMode: _themeMode,
      home: MainPage(
        onThemeChanged: _toggleTheme,
        onAccentChanged: _changeAccent,
        accentColor: _accentColor,
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final void Function(bool isDark) onThemeChanged;
  final void Function(Color color) onAccentChanged;
  final Color accentColor;

  const MainPage({
    super.key,
    required this.onThemeChanged,
    required this.onAccentChanged,
    required this.accentColor,
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
      HomePage(
        onThemeChanged: widget.onThemeChanged,
        onAccentChanged: widget.onAccentChanged,
      ),
      const TunerPage(),
      AccountPage(
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
