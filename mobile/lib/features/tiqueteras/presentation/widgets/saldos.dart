import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_saldo.dart';
import '../../domain/entities/estado_de_cuenta.dart';
import '../../domain/reglas/reglas_venta.dart';
import 'carton_tiquetera.dart';

/// El saldo por unidad y, debajo, la pila de cartones: arriba el que vence primero.
class SaldosYCartones extends StatelessWidget {
  const SaldosYCartones({super.key, required this.cuenta, this.vacio = 'No tiene saldo vigente.'});

  final EstadoDeCuenta cuenta;
  final String vacio;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (cuenta.saldos.isEmpty) Text(vacio, style: const TextStyle(fontSize: VeciTexto.cuerpo)),
      for (final s in cuenta.saldos) ...[
        VeciSaldo(unidades: s.disponibles, singular: s.unidad.singular, plural: s.unidad.plural),
        Padding(
          padding: const EdgeInsets.only(top: VeciEspacio.xs, bottom: VeciEspacio.m),
          child: Text(
            '${s.tiqueteras == 1 ? 'En 1 tiquetera' : 'En ${s.tiqueteras} tiqueteras'} · '
            'la primera sirve hasta el ${diaLegible(s.ultimoDia)}',
            style: const TextStyle(color: VeciColores.tintaSuave),
          ),
        ),
      ],
      for (final t in cuenta.tiqueteras) CartonTiquetera(tiquetera: t),
    ],
  );
}
