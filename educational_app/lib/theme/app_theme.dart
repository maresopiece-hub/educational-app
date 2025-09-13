import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light(Color primary) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      appBarTheme: AppBarTheme(backgroundColor: primary, foregroundColor: Colors.white),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: primary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: primary),
    );
  }

  static ThemeData dark(Color primary) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark),
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      appBarTheme: AppBarTheme(backgroundColor: primary, foregroundColor: Colors.white),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: primary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: primary),
    );
  }
}
