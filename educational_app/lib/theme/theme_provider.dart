import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  Color _color = Colors.blue;
  bool _initialized = false;

  Color get color => _color;
  bool get initialized => _initialized;

  ThemeProvider() {
    _loadColor();
  }

  Future<void> _loadColor() async {
    final prefs = await SharedPreferences.getInstance();
  final colorValue = prefs.getInt('themeColor') ?? Colors.blue.value;
  _color = Color(colorValue);
    _initialized = true;
    notifyListeners();
  }

  Future<void> setColor(Color color) async {
    _color = color;
    final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('themeColor', color.value);
    notifyListeners();
  }
}
