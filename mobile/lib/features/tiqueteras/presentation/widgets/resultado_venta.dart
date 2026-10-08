import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_sello.dart';
import '../../domain/entities/venta.dart';
import 'saldos.dart';
import 'textos_tiqueteras.dart';

/// Lo que se ve al cobrar: el sello con el saldo nuevo o el aviso de que quedó guardada.
class ResultadoDeVenta extends StatelessWidget {
  const ResultadoDeVenta({super.key, required this.resultado, required this.venta});

  final ResultadoVenta resultado;
  final VentaEnCaja venta;

  @override
  Widget build(BuildContext context) => switch (resultado) {
    VentaEnviada(:final cuenta) => Column(
      children: [
        Center(
          child: VeciSello(
            arriba: 'VENDIDA',
            cifra: '+${venta.tipo.unidades}',
            abajo: venta.tipo.unidad.plural,
            semilla: venta.ventaId,
          ),
        ),
        const SizedBox(height: VeciEspacio.l),
        SaldosYCartones(cuenta: cuenta),
      ],
    ),
    VentaGuardada() => const VeciAviso(tono: TonoAviso.aviso, mensaje: ventaGuardada),
  };
}
