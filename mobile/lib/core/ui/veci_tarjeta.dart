import 'package:flutter/material.dart';

import '../theme/veci_tokens.dart';

/// Superficie blanca con borde suave para agrupar contenido.
class VeciTarjeta extends StatelessWidget {
  const VeciTarjeta({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(VeciEspacio.l),
      decoration: BoxDecoration(
        color: VeciColores.superficie,
        borderRadius: BorderRadius.circular(VeciRadio.l),
        border: Border.all(color: VeciColores.borde),
      ),
      child: child,
    );
  }
}
