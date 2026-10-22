import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EasyDialApp());
}

class EasyDialApp extends StatelessWidget {
  const EasyDialApp({super.key});

  static const _deepBlue = Color(0xFF0B4F9C);
  static const _warmWhite = Color(0xFFFAF8F5);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EasyDial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _deepBlue,
          primary: _deepBlue,
          surface: _warmWhite,
        ),
        scaffoldBackgroundColor: _warmWhite,
        appBarTheme: const AppBarTheme(
          backgroundColor: _warmWhite,
          foregroundColor: Color(0xFF111827),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
