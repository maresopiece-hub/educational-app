import 'package:flutter/material.dart';

/// Minimal SettingsState ChangeNotifier for app settings.
class SettingsState extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
