import 'package:flutter/material.dart';

import '../theme/veci_tokens.dart';

/// Botón principal de VECI: ocupa el ancho, mide 56 px (72 px en grande) y se toca fácil.
class VeciBoton extends StatelessWidget {
  const VeciBoton({
    super.key,
    required this.texto,
    required this.alTocar,
    this.icono,
    this.grande = false,
    this.secundario = false,
  });

  final String texto;
  final VoidCallback? alTocar;
  final IconData? icono;
  final bool grande;
  final bool secundario;

  @override
  Widget build(BuildContext context) {
    final alto = grande ? VeciToque.botonGrande : VeciToque.boton;
    final estilo = ButtonStyle(minimumSize: WidgetStatePropertyAll(Size.fromHeight(alto)));
    final etiqueta = Text(
      texto,
      style: TextStyle(fontSize: grande ? VeciTexto.titulo : VeciTexto.subtitulo),
    );
    final icon = icono == null ? null : Icon(icono, size: grande ? 32 : 24);
    if (secundario) {
      return OutlinedButton.icon(onPressed: alTocar, style: estilo, icon: icon, label: etiqueta);
    }
    return FilledButton.icon(onPressed: alTocar, style: estilo, icon: icon, label: etiqueta);
  }
}
