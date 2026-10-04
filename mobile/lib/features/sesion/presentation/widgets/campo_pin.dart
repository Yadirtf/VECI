import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// PIN de 6 números: teclado numérico, oculto y sin letras.
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
  Widget build(BuildContext context) => TextField(
    controller: controlador,
    obscureText: true,
    keyboardType: TextInputType.number,
    maxLength: 6,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: InputDecoration(labelText: etiqueta, helperText: ayuda, counterText: ''),
    onSubmitted: (_) => alTerminar?.call(),
  );
}
