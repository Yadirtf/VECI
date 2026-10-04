import 'package:flutter/material.dart';

/// Tema provisional de la prueba de concepto: verde amazónico y tonos cálidos.
/// El sistema de diseño definitivo llega con HU-01-09.
class VeciTheme {
  static const verde = Color(0xFF1B7F5B);
  static const tierra = Color(0xFFB4572E);
  static const crema = Color(0xFFFFF8EE);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: verde, secondary: tierra, surface: crema);
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: crema,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
