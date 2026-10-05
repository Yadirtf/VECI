import 'package:flutter/material.dart';

import '../../../../core/ui/veci_pin.dart';

/// PIN de 6 números: teclado numérico, oculto y con casillas que se perforan.
class CampoPin extends StatelessWidget {
  const CampoPin({
    super.key,
    required this.etiqueta,
    required this.controlador,
    this.ayuda,
    this.alTerminar,
  });

  final String etiqueta;
  final TextEditingController controlador;
  final String? ayuda;
  final VoidCallback? alTerminar;

  @override
  Widget build(BuildContext context) =>
      VeciPin(etiqueta: etiqueta, controlador: controlador, ayuda: ayuda, alTerminar: alTerminar);
}
