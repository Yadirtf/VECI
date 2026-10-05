import 'package:flutter/material.dart';

import '../theme/veci_formas.dart';
import '../theme/veci_tokens.dart';

/// El mostrador: franja de abajo con borde en arco donde vive la acción principal,
/// al alcance del pulgar. Va como último hijo de un Column en el cuerpo del Scaffold,
/// así sube con el teclado.
class VeciMostrador extends StatelessWidget {
  const VeciMostrador({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: VeciForma.arco),
    child: Material(
      color: VeciColores.superficie,
      shape: const ArcoBorder(abajo: false, side: BorderSide(color: VeciColores.borde, width: 2)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            VeciEspacio.l,
            VeciEspacio.xs,
            VeciEspacio.l,
            VeciEspacio.m,
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: _separados()),
        ),
      ),
    ),
  );

  List<Widget> _separados() => [
    for (var i = 0; i < children.length; i++) ...[
      if (i > 0) const SizedBox(height: VeciEspacio.s),
      children[i],
    ],
  ];
}
