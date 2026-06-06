import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs, {required bool isDarkMode})
      : _isDarkMode = isDarkMode;

  static const _kDarkModeKey = 'is_dark_mode';

  final SharedPreferences _prefs;
  bool _isDarkMode;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  static Future<ThemeController> create() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_kDarkModeKey) ?? false;
    return ThemeController(prefs, isDarkMode: isDark);
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _prefs.setBool(_kDarkModeKey, _isDarkMode);
    notifyListeners();
  }
}

