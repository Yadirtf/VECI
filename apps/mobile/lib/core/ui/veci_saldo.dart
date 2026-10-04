import 'package:flutter/material.dart';

import '../theme/veci_tokens.dart';

/// Saldo de una tiquetera en grande: "12 almuerzos".
class VeciSaldo extends StatelessWidget {
  const VeciSaldo({
    super.key,
    required this.unidades,
    required this.singular,
    required this.plural,
  });

  final int unidades;
  final String singular;
  final String plural;

  @override
  Widget build(BuildContext context) {
    final unidad = unidades == 1 ? singular : plural;
    return Semantics(
      label: 'Saldo: $unidades $unidad',
      excludeSemantics: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '$unidades',
            style: const TextStyle(
              fontSize: VeciTexto.saldo,
              fontWeight: VeciPeso.fuerte,
              color: VeciColores.selvaOscuro,
            ),
          ),
          const SizedBox(width: VeciEspacio.s),
          Text(unidad, style: const TextStyle(fontSize: VeciTexto.titulo)),
        ],
      ),
    );
  }
}
