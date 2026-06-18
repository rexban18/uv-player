import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _darkModeKey = 'dark_mode';
  static const String _accentColorKey = 'accent_color';

  bool _isDarkMode = true;
  String _accentColorName = 'Violet';
  SharedPreferences? _prefs;

  bool get isDarkMode => _isDarkMode;
  String get accentColorName => _accentColorName;
  Color get accentColor => AppTheme.getAccentColor(_accentColorName);
  ThemeData get theme => _isDarkMode
      ? AppTheme.darkTheme(accentColor)
      : AppTheme.lightTheme(accentColor);

  ThemeProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs?.getBool(_darkModeKey) ?? true;
    _accentColorName = _prefs?.getString(_accentColorKey) ?? 'Violet';
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _prefs?.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  Future<void> setAccentColor(String colorName) async {
    if (AppTheme.accentColors.containsKey(colorName)) {
      _accentColorName = colorName;
      await _prefs?.setString(_accentColorKey, colorName);
      notifyListeners();
    }
  }
}
