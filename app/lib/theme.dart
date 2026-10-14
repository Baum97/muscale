import 'package:flutter/material.dart';

/// Platzhalter-Farben, bis Icon und Farben festgelegt sind.
class AppColors {
  static const seed = Color(0xFF2E7D6B);

  /// Feste Farben für die Makros – in Hell und Dunkel gleich gut lesbar.
  static const protein = Color(0xFF3F7FD8);
  static const carbs = Color(0xFFE0A030);
  static const fat = Color(0xFFD0607A);
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.seed, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    cardTheme: const CardThemeData(margin: EdgeInsets.zero),
  );
}
