import 'package:flutter/material.dart';

class AppTheme {
  static const Map<String, Color> accentColors = {
    'Violet': Color(0xFF7C4DFF),
    'Cyan': Color(0xFF00E5FF),
    'Pink': Color(0xFFFF4081),
    'Teal': Color(0xFF1DE9B6),
    'Amber': Color(0xFFFFD740),
    'Blue': Color(0xFF448AFF),
    'Red': Color(0xFFFF5252),
    'Green': Color(0xFF69F0AE),
  };

  static Color getAccentColor(String name) {
    return accentColors[name] ?? const Color(0xFF7C4DFF);
  }

  static ThemeData lightTheme(Color accent) {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFFF0F0F5),
      colorScheme: ColorScheme.light(
        primary: accent,
        secondary: accent.withOpacity(0.7),
        surface: Colors.white.withOpacity(0.7),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.5),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white.withOpacity(0.6),
        selectedItemColor: accent,
        unselectedItemColor: Colors.grey.shade600,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      iconTheme: IconThemeData(color: Colors.grey.shade800),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.black87),
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black54),
        labelLarge: TextStyle(color: Colors.white),
      ),
    );
  }

  static ThemeData darkTheme(Color accent) {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF0D0D1A),
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accent.withOpacity(0.7),
        surface: Colors.white.withOpacity(0.08),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withOpacity(0.08),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.black.withOpacity(0.4),
        selectedItemColor: accent,
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      iconTheme: IconThemeData(color: Colors.grey.shade300),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Colors.white70),
        bodyLarge: TextStyle(color: Colors.white70),
        bodyMedium: TextStyle(color: Colors.white54),
        labelLarge: TextStyle(color: Colors.white),
      ),
    );
  }
}
