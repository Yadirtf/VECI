import 'package:flutter/material.dart';

import 'veci_formas.dart';
import 'veci_tokens.dart';

/// Tema de Material construido con los tokens del sistema de diseño VECI (HU-01-09),
/// dirección «El papelito del vecino»: fondo kraft, papelitos dentados, botones de
/// piedra con canto, campos como renglón de cuaderno y encabezado en arco.
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
        foregroundColor: VeciColores.crema,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: ArcoBorder(),
        titleTextStyle: TextStyle(fontSize: VeciTexto.titulo, fontWeight: VeciPeso.fuerte),
      ),
      cardTheme: const CardThemeData(
        color: VeciColores.superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: PapelitoBorder(side: BorderSide(color: VeciColores.borde, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(style: _estiloBoton()),
      outlinedButtonTheme: OutlinedButtonThemeData(style: _estiloBoton()),
      inputDecorationTheme: _campos(),
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  static TextTheme _textos() => const TextTheme(
    displayMedium: TextStyle(
      fontSize: VeciTexto.sello,
      fontWeight: VeciPeso.fuerte,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    displaySmall: TextStyle(
      fontSize: VeciTexto.saldo,
      fontWeight: VeciPeso.fuerte,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
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
    elevation: const WidgetStatePropertyAll(0),
    shape: WidgetStatePropertyAll(VeciFormas.piedra()),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.medio),
    ),
  );

  /// Campos como renglón de cuaderno: papel claro, línea gruesa abajo que se ve al sol,
  /// etiqueta siempre visible y foco en verde selva.
  static InputDecorationTheme _campos() {
    UnderlineInputBorder borde(Color color, double ancho) => UnderlineInputBorder(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(VeciRadio.piedraChica)),
      borderSide: BorderSide(color: color, width: ancho),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: VeciColores.superficie,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      contentPadding: const EdgeInsets.all(VeciEspacio.m),
      labelStyle: const TextStyle(
        fontSize: VeciTexto.cuerpo,
        fontWeight: VeciPeso.medio,
        color: VeciColores.tinta,
      ),
      helperStyle: const TextStyle(fontSize: VeciTexto.pequeno, color: VeciColores.tintaSuave),
      enabledBorder: borde(VeciColores.tinta, 3),
      focusedBorder: borde(VeciColores.selva, 4),
      errorBorder: borde(VeciColores.error, 3),
      focusedErrorBorder: borde(VeciColores.error, 4),
    );
  }
}
