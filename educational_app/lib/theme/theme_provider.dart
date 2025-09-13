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

  // Pack ARGB components into a single int for stable storage
  int _packColor(Color c) {
    final a = (c.a * 255.0).round() & 0xFF;
    final r = (c.r * 255.0).round() & 0xFF;
    final g = (c.g * 255.0).round() & 0xFF;
    final b = (c.b * 255.0).round() & 0xFF;
    return (a << 24) | (r << 16) | (g << 8) | b;
  }

  // Unpack stored int into a Color
  Color _unpackColor(int v) {
    final a = (v >> 24) & 0xFF;
    final r = (v >> 16) & 0xFF;
    final g = (v >> 8) & 0xFF;
    final b = v & 0xFF;
    return Color.fromARGB(a, r, g, b);
  }

  Future<void> _loadColor() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultPacked = _packColor(Colors.blue);
    final packed = prefs.getInt('themeColor') ?? defaultPacked;
    _color = _unpackColor(packed);
    _initialized = true;
    notifyListeners();
  }

  Future<void> setColor(Color color) async {
    _color = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeColor', _packColor(color));
    notifyListeners();
  }
}
