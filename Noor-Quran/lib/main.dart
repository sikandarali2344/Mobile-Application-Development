import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/splash_screen.dart';
import 'services/quran_storage.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final initialDarkMode = await QuranStorage.getDarkMode();
  runApp(MyApp(initialDarkMode: initialDarkMode));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialDarkMode});
  final bool initialDarkMode;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.initialDarkMode;
  }

  void _handleThemeChange(bool value) {
    QuranStorage.setDarkMode(value);
    setState(() => _darkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noor Quran',
      debugShowCheckedModeBanner: false,
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      home: SplashScreen(
        darkMode: _darkMode,
        onThemeToggle: _handleThemeChange,
      ),
    );
  }
}