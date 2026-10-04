import 'package:flutter/material.dart';

import 'veci_tokens.dart';

/// Tema de Material construido con los tokens del sistema de diseño VECI (HU-01-09):
/// letra grande, botones de 56 px y alto contraste para leer al sol.
abstract final class VeciTema {
  static ThemeData claro() {
    final esquema = ColorScheme.fromSeed(
      seedColor: VeciColores.selva,
      primary: VeciColores.selva,
      onPrimary: VeciColores.superficie,
      secondary: VeciColores.arcilla,
      tertiary: VeciColores.maiz,
      surface: VeciColores.superficie,
      onSurface: VeciColores.tinta,
      error: VeciColores.error,
    );
    return ThemeData(
      colorScheme: esquema,
      useMaterial3: true,
      scaffoldBackgroundColor: VeciColores.crema,
      textTheme: _textos(),
      appBarTheme: const AppBarTheme(
        backgroundColor: VeciColores.selvaOscuro,
        foregroundColor: VeciColores.superficie,
        titleTextStyle: TextStyle(fontSize: VeciTexto.titulo, fontWeight: VeciPeso.fuerte),
      ),
      filledButtonTheme: FilledButtonThemeData(style: _estiloBoton()),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _estiloBoton()),
      inputDecorationTheme: _campos(),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  static TextTheme _textos() => const TextTheme(
    displaySmall: TextStyle(fontSize: VeciTexto.saldo, fontWeight: VeciPeso.fuerte),
    headlineSmall: TextStyle(fontSize: VeciTexto.grande, fontWeight: VeciPeso.fuerte),
    titleLarge: TextStyle(fontSize: VeciTexto.titulo, fontWeight: VeciPeso.fuerte),
    titleMedium: TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.medio),
    bodyLarge: TextStyle(fontSize: VeciTexto.cuerpo),
    bodyMedium: TextStyle(fontSize: VeciTexto.cuerpo),
    bodySmall: TextStyle(fontSize: VeciTexto.pequeno),
    labelLarge: TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.medio),
  ).apply(bodyColor: VeciColores.tinta, displayColor: VeciColores.tinta);

  static ButtonStyle _estiloBoton() => ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size.fromHeight(VeciToque.boton)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(VeciRadio.m)),
    ),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.medio),
    ),
  );

  /// Campos de texto: etiqueta siempre visible, borde que se ve al sol y foco en verde selva.
  static InputDecorationTheme _campos() {
    OutlineInputBorder borde(Color color, double ancho) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(VeciRadio.m),
      borderSide: BorderSide(color: color, width: ancho),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: VeciColores.superficie,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.all(VeciEspacio.m),
      labelStyle: const TextStyle(fontSize: VeciTexto.cuerpo, color: VeciColores.tinta),
      enabledBorder: borde(VeciColores.borde, 2),
      focusedBorder: borde(VeciColores.selva, 3),
      errorBorder: borde(VeciColores.error, 2),
      focusedErrorBorder: borde(VeciColores.error, 3),
    );
  }
}
