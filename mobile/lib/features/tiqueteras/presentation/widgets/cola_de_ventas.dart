import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../domain/entities/venta.dart';
import '../../domain/reglas/reglas_venta.dart';

/// Las ventas del celular que esperan señal y las que el servidor no aceptó, con su
/// motivo y la opción de sacarlas de la cola.
class ColaDeVentas extends StatelessWidget {
  const ColaDeVentas({super.key, required this.ventas, required this.alDescartar});

  final List<VentaPorEnviar> ventas;
  final ValueChanged<String> alDescartar;

  @override
  Widget build(BuildContext context) {
    final enEspera = ventas.where((v) => v.rechazo == null).length;
    final rechazadas = ventas.where((v) => v.rechazo != null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (enEspera > 0)
          VeciAviso(
            tono: TonoAviso.aviso,
            mensaje: enEspera == 1
                ? '1 venta espera señal para enviarse.'
                : '$enEspera ventas esperan señal para enviarse.',
          ),
        for (final v in rechazadas)
          Card(
            color: VeciColores.errorFondo,
            margin: const EdgeInsets.only(top: VeciEspacio.s),
            child: ListTile(
              title: Text('${v.nombreCliente} · ${v.nombreTipo} · ${pesos(v.precio)}'),
              subtitle: Text('No se registró: ${v.rechazo}'),
              trailing: TextButton(
                onPressed: () => alDescartar(v.ventaId),
                child: const Text('Quitar'),
              ),
            ),
          ),
      ],
    );
  }
}
