import 'package:flutter/material.dart';

import '../theme/veci_formas.dart';
import '../theme/veci_tokens.dart';

/// Un papelito arrancado del talonario: agrupa lo que VECI te quiere contar.
/// Dientes abajo y sombra dura; con [perforado], la fila de huecos de arriba.
class VeciTarjeta extends StatelessWidget {
  const VeciTarjeta({
    super.key,
    required this.child,
    this.perforado = false,
    this.color = VeciColores.superficie,
  });

  final Widget child;
  final bool perforado;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final forma = PapelitoBorder(perforado: perforado);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VeciEspacio.l).add(forma.dimensions),
      decoration: ShapeDecoration(color: color, shape: forma, shadows: VeciFormas.sombraPapel),
      child: child,
    );
  }
}
